fs = require 'fs'
express = require 'express'
router = express.Router()
_ = require 'underscore'
Coder = require './coder'
multer = require 'multer'
provider = new (require './providers/fs-provider')

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
#GET <PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[.<EXTENSION>]
router.get '/:projectPublicKey/:imagePublicKeyWithExtension', (req, res) ->
  [imagePublicKey, extension] = req.params.imagePublicKeyWithExtension.split(/.(\w+)$/, 2)
  if !extension?
    provider.completeFileName(req.params.projectPublicKey, imagePublicKey).then (fileName) ->
      res.sendFile fileName
  else
    fileName = "./#{req.params.projectPublicKey}/#{req.params.imagePublicKey}"
    res.sendFile fileName

#3) удаление картинки
#DELETE <PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
router.delete '/:projectPrivateKey/:imagePrivateKey', (req, res) ->
  projectPublicKey = (new Coder).priv2pub(req.params.projectPrivateKey)
  provider.getSalt(projectPublicKey).then (salt) ->
    imagePublicKey = (new Coder salt).priv2pub req.params.imagePrivateKey
    provider.deleteFile projectPublicKey, imagePublicKey
  .then ->
    res.send {}
  .catch (error) ->
    res.send error: error

module.exports = router