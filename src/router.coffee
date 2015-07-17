fs = require 'fs'
path = require 'path'
express = require 'express'
_ = require 'underscore'
Coder = require './coder'
multer = require 'multer'

module.exports = (config, storage) ->

  router = express.Router()

  multerMiddleware = multer
    dest: "#{config.path}/tmp"

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
    projectPublicKey = (new Coder).priv2pub(req.params.projectPrivateKey)
    storage.getSalt(req.params.projectPrivateKey).then (salt) ->
      coder = new Coder salt
      imagePublicKey = coder.priv2pub req.params.imagePrivateKey
      storage.saveFile req.files.file, projectPublicKey, imagePublicKey
    .then ->
      res.send {}
    .catch (error) ->
      log.error error.stack
      res.status(500).send error: error.toString()

  #2) просмотр картинки
  #GET <PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[.<EXTENSION>]
  router.get '/:projectPublicKey/:imagePublicKeyWithExtension', (req, res) ->
#    log.info "GET #{req.path}"
    {name:imagePublicKey, ext:extension} = path.parse req.params.imagePublicKeyWithExtension
    storage.getFilePath(req.params.projectPublicKey, imagePublicKey, extension).then (filePath) ->
      res.sendFile filePath
    .catch (error) ->
      log.error error
      res.status(500).send error: error

  #3) удаление картинки
  #DELETE <PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
  router.delete '/:projectPrivateKey/:imagePrivateKey', (req, res) ->
#    log.info "DELETE #{req.path}"
    projectPublicKey = (new Coder).priv2pub(req.params.projectPrivateKey)
    storage.getSalt(req.params.projectPrivateKey).then (salt) ->
      imagePublicKey = (new Coder salt).priv2pub req.params.imagePrivateKey
      storage.deleteFile projectPublicKey, imagePublicKey
    .then ->
      res.send {}
    .catch (error) ->
      res.send error: error