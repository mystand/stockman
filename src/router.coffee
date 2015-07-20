fs = require 'fs'
path = require 'path'
async = require 'async'
express = require 'express'
_ = require 'underscore'
Coder = require './coder'
multer = require 'multer'
request = require 'request'
convert = require './convert'

module.exports = (config, storage) ->
  router = express.Router()
  tmpPath = path.join config.path, 'tmp'

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
    [imagePublicKeyWithExtension, processingString] = [req.params.arg2, req.params.arg1].filter (arg) -> !_.isEmpty(arg)
    {name:imagePublicKey, ext:extension} = path.parse imagePublicKeyWithExtension

    storage.getFile(projectPublicKey, imagePublicKey, extension, processingString)
    .then (fileLocation) ->
      _send res, fileLocation
    , (err) ->
      if processingString
        storage.getFile(projectPublicKey, imagePublicKey, extension).then (fileLocation) ->
          _localizeFile(fileLocation).then (localFilePath) ->
            convert(localFilePath, processingString).then (resultFilePath) ->
              storage.saveFile(resultFilePath, projectPublicKey, imagePublicKey, processingString).then (fileLocation) ->
                _send res, fileLocation
      else
        throw status: 404, error: "Can't find file"
    .catch (error) ->
      res.status(error.status).send error.error

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

  _send = (res, fileLocation) ->
    switch fileLocation.type
      when 'local'
        res.sendFile fileLocation.data
      when 'remote'
        false
        # TODO: download image to the tmp path
      when 'memory'
        false
        # TODO: save image to the tmp path
      else
        res.send status: 500, error: 'Unknown fileLocation type'

  router