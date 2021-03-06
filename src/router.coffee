fs = require 'fs'
path = require 'path'
async = require 'async'
express = require 'express'
_ = require 'underscore'
Coder = require './coder'
multer = require 'multer'
request = require 'request'
Wizard = require './wizard'

module.exports = (config, storage) ->
  router = express.Router()
  tmpPath = path.join config.path, 'tmp'
  wizard = new Wizard tmpPath

  multerMiddleware = multer
    dest: tmpPath

  log =
    info: console.log
    error: (message) ->
      console.log "ERROR: #{message}"

  router.get '/hello', (req, res) ->
    res.send 'hello'

  #1) загрузка картинки
  #POST <PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
  router.post '/:projectPrivateKey/:imagePrivateKey', multerMiddleware, (req, res) ->
#    log.info "POST #{req.path}"
    projectPublicKey = Coder.priv2pub(req.params.projectPrivateKey)
    storage.getSalt(req.params.projectPrivateKey).then (salt) ->
      coder = new Coder salt
      imagePublicKey = coder.priv2pub req.params.imagePrivateKey
      storage.saveFile req.files.file.path, projectPublicKey, imagePublicKey
    .then ->
      res.send {}
    .catch (error) ->
      log.error error.stack
      res.status(500).send error: error.toString()

  #2) просмотр картинки
  #GET <PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[.<EXTENSION>]
  router.get '/:projectPublicKey/:arg1/:arg2?', (req, res) ->
    projectPublicKey = req.params.projectPublicKey
    [imagePublicKeyWithExtension, processingStringWithExtension] = [req.params.arg1, req.params.arg2].filter (arg) -> !_.isEmpty(arg)

    if processingStringWithExtension
      imagePublicKey = imagePublicKeyWithExtension
      {name:processingString, ext:extension} = path.parse processingStringWithExtension
    else
      {name:imagePublicKey, ext:extension} = path.parse imagePublicKeyWithExtension

    storage.getFile(projectPublicKey, imagePublicKey, extension, processingString)
    .catch ->
      if processingString
        storage.getFile(projectPublicKey, imagePublicKey, extension).then (fileLocation) ->
          _localizeFile(fileLocation).then (localFilePath) ->
            wizard.turnTo(localFilePath, processingString).then (resultFilePath) ->
              storage.saveFile(resultFilePath, projectPublicKey, imagePublicKey, processingString).then (fileLocation)
      else
        throw status: 404, error: "Can't find file"
    .then (fileLocation) ->
      _send res, fileLocation, projectPublicKey, imagePublicKey, extension, processingString
    .catch (error) ->
      res.status(error.status || 500).send error.error || 'Unexpected error'

  #3) удаление картинки
  #DELETE <PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
  router.delete '/:projectPrivateKey/:imagePrivateKey', (req, res) ->
#    log.info "DELETE #{req.path}"
    projectPublicKey = Coder.priv2pub(req.params.projectPrivateKey)
    storage.getSalt(req.params.projectPrivateKey).then (salt) ->
      imagePublicKey = (new Coder salt).priv2pub req.params.imagePrivateKey
      storage.deleteFile projectPublicKey, imagePublicKey
    .then ->
      res.send {}
    .catch (error) ->
      res.status(error.status).send error.error

  _localizeFile = (fileLocation) ->
    new Promise (resolve, reject) ->
      switch fileLocation.type
        when 'local'
          resolve fileLocation.data
        when 'remote'
          false # TODO: download image to the tmp path
        when 'memory'
          false # TODO: save image to the tmp path
        else
          reject status: 500, error: 'Unknown fileLocation type'

  _send = (res, fileLocation, projectPublicKey, imagePublicKey, extension, processingString) ->
    switch fileLocation.type
      when 'local'
        realExtension = path.extname fileLocation.data
        if realExtension == extension
          res.sendFile fileLocation.data
        else
          res.redirect '/' + _([projectPublicKey, imagePublicKey, extension, processingString]).compact().join('/') + realExtension
      when 'remote'
        res.redirect fileLocation.data
      when 'memory'
        realExtension = path.extname fileLocation.data
        if realExtension == extension
          fileLocation.data.pipe res
        else
          res.redirect '/' + _([projectPublicKey, imagePublicKey, extension, processingString]).compact().join('/') + realExtension
      else
        res.send status: 500, error: 'Unknown fileLocation type'

  router