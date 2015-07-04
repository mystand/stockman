express = require 'express'
router = express.Router()
_ = require 'underscore'
Coder = require './coder'

multer = require 'multer'
multerMiddleware = multer dest: './uploads/'

router.get '/:mikle', (req, res) ->
  res.send "#{req.params.mikle}"


router.param 'projectPrivateKey', (req, res, next, projectId) ->
router.param 'projectPublicKey', (req, res, next, projectId) ->
  req.db.collection('projects').findOne {_id: projectId}, (err, result) ->
    req.project = result
    req.coder = new Coder req.project.salt
    next()

fillCategory = (req, res, next, categoryPublicKey) ->
  req.category = _(req.project.categories).find((c) -> req.coder.uniq2pub(c.uniqKey) == categoryPublicKey)
  next()

router.param 'categoryPublicKey', fillCategory
router.param 'categoryPrivateKey', (req, res, next, categoryPrivateKey) ->
  fillCategory(req, res, next, req.coder.priv2pub(categoryPrivateKey))

fillObject = (req, res, next, objectPublicKey) ->
  req.db.collection('objects').findOne {
    projectId: req.project._id,
    categoryId: req.category._id,
    objectPublicKey: objectPublicKey
  }, {sort: {_id: -1}, fields: {_id: 0}}, (err, object) ->
    req.objectPublicKey = objectPublicKey
    req.object = if !object? || object.deleted
      {projectId: req.project._id, categoryId: req.category._id, objectPublicKey: req.objectPublicKey}
    else
      object
    next()

router.param 'objectPublicKey', fillObject
router.param 'objectPrivateKey', (req, res, next, objectPrivateKey) ->
  fillObject(req, res, next, req.coder.priv2pub(objectPrivateKey))

#1) просмотр картинки
#GET http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PUBLIC_KEY>/<OBJECT_PUBLIC_KEY>/<OBJECT_VERSION>
router.get '/:projectId/:categoryPublicKey/:objectPublicKey/:objectVersion', (req, res) ->
  res.send req.object

#2) загрузка картинки
#POST http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>
router.post '/:projectId/:categoryPrivateKey/:objectPrivateKey', multerMiddleware, (req, res) ->
  params = _.extend({}, req.params, req.files)

  if _.isEmpty(params)
    res.send 'empty params'
    return

  object = processors[req.category.type](req.category, req.object, params)
  req.db.collection('objects').save object, (errors, result) ->
    res.send {success: 1}

#3) удаление картинки
#DELETE http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>
router.delete '/:projectId/:categoryPrivateKey/:objectPrivateKey', (req, res) ->
  req.object.deleted = yes
  req.db.collection('objects').save req.object, (errors, result) ->
    res.send req.object

##4) загрузка картинки в галерею
##POST http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>
#router.post '/:projectId/:categoryPrivateKey/:objectPrivateKey', (req, res) ->
#  res.status(404).send('Not implemented yet');
#
##5) получение списка картинок галереи
##GET http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PUBLIC_KEY>/<OBJECT_PUBLIC_KEY>
#router.get '/:projectId/:categoryPublicKey/:objectPublicKey', (req, res) ->
#  res.status(404).send('Not implemented yet');
#
##6) удаление галереи
##DELETE http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>
#router.delete '/:projectId/:categoryPrivateKey/:objectPrivateKey', (req, res) ->
#  res.status(404).send('Not implemented yet');
#
#  #7) удаление картинки из галереи
#  #DELETE http://v1.stockman.com/<PROJECT_ID>/<CATEGORY_PRIVATE_KEY>/<OBJECT_PRIVATE_KEY>/<ITEM_KEY>
#  router.delete '/:projectId/:categoryPrivateKey/:objectPrivateKey/itemKey', (req, res) ->
#  res.status(404).send('Not implemented yet');

module.exports = router