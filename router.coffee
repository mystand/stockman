fs = require 'fs'
express = require 'express'
router = express.Router()
_ = require 'underscore'
Coder = require './coder'
multer = require 'multer'
provider = new (require './providers/fs-provider')

# TODO: вынести это в либу-провайдер
fileNameHash = {}
completeFileName = (imagePublicKey, callback) ->
  if fileNameHash[imagePublicKey]
    callback fileNameHash[imagePublicKey]
#  else

multerMiddleware = multer
  dest: './tmp/'

#1) загрузка картинки
#POST <PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
router.post '/:projectPrivateKey/:imagePrivateKey', multerMiddleware, (req, res) ->
  projectPublicKey = (new Coder).priv2pub(req.params.projectPrivateKey)
  provider.getSalt(projectPublicKey).then (salt) ->
    coder = new Coder salt
    imagePublicKey = coder.priv2pub req.params.imagePrivateKey
    provider.saveFile req.files.file, projectPublicKey, imagePublicKey
  .then ->
    res.send {}
  .catch (error) ->
    res.send error: error

#2) просмотр картинки
#GET http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PUBLIC_KEY>/<OBJECT_PUBLIC_KEY>/<OBJECT_VERSION>
router.get '/:projectPublicKey/:imagePublicKeyWithExtension', (req, res) ->
  [imagePublicKey, extension] = req.params.imagePublicKeyWithExtension.split(/.(\w+)$/, 2)
  fileName = "./#{req.params.projectPublicKey}/#{req.params.imagePublicKey}"
  unless extension
    fileName = completeFileName(fileName)

  res.sendFile

#3) удаление картинки
#DELETE http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>
router.delete '/:projectId/:categoryPrivateKey/:objectPrivateKey', (req, res) ->
  req.object.deleted = yes
  req.db.collection('objects').save req.object, (errors, result) ->
    res.send req.object

module.exports = router