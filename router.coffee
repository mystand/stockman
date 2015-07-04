express = require 'express'
router = express.Router()
_ = require 'underscore'
Coder = require './coder'

multer = require 'multer'
multerMiddleware = multer
  dest: './tmp/'
#  changeDest: (dest, req, res) ->
#    console.log req.projectPublicKey
#    "./#{req.projectPublicKey}/"
#  rename: (fieldname, filename, req, res) ->
#    req.imagePublicKey
#    console.log req.imagePublicKey

router.param 'projectPrivateKey', (req, res, next, projectPrivateKey) ->
  req.coder = new Coder 'SALT1'
  req.projectPublicKey = projectPrivateKey
  next()

router.param 'projectPublicKey', (req, res, next, projectPublicKey) ->
  req.projectPublicKey = projectPublicKey
  next()

router.param 'imagePrivateKey', (req, res, next, imagePrivateKey) ->
  req.imagePublicKey = imagePrivateKey
  next()

router.param 'imagePublicKey', (req, res, next, imagePublicKey) ->
  req.imagePublicKey = imagePublicKey
  next()

router.get '/:mikle', (req, res) ->
  res.send "#{req.params.mikle}"

#1) загрузка картинки
#POST <PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
router.post '/:projectPrivateKey/:imagePrivateKey', multerMiddleware, (req, res) ->
  params = _.extend({}, req.params, req.files)

  console.log req.projectPublicKey
  console.log req.imagePublicKey

  if _.isEmpty(params)
    res.send 'empty params'
    return

  res.send 'OK'

#2) просмотр картинки
#GET http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PUBLIC_KEY>/<OBJECT_PUBLIC_KEY>/<OBJECT_VERSION>
router.get '/:projectId/:categoryPublicKey/:objectPublicKey/:objectVersion', (req, res) ->
  res.send req.object

#3) удаление картинки
#DELETE http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>
router.delete '/:projectId/:categoryPrivateKey/:objectPrivateKey', (req, res) ->
  req.object.deleted = yes
  req.db.collection('objects').save req.object, (errors, result) ->
    res.send req.object

module.exports = router