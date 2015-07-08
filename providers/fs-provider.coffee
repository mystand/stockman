fs = require 'fs'
_ = require 'underscore'

class FsProvider
  constructor: ->
    @extensions = {
#     "projectPublicKey/imagePublicKey": [extensions]
    }

  getSalt: (projectPublicKey) =>
    new Promise (resolve, reject) =>
      fs.readFile "./#{projectPublicKey}.salt", 'utf8', (err, salt) =>
        if err
          reject 'can\'t access to the project salt file'
        else
          resolve salt

  saveFile: (file, projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      fs.rename file.path, "./#{projectPublicKey}/#{imagePublicKey}.#{file.extension}", (err) =>
        if err
          reject 'can\'t move file to the target path'
        else
          resolve()

  completeFileName: (projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      extension = @_findInExtensions(projectPublicKey, imagePublicKey)
      if result?
        fileName = "./#{projectPublicKey}/#{imagePublicKey}.#{extension}"
        resolve fileName
      else
        @_reloadExtensions(projectPublicKey).then =>
          extension = @_findInExtensions(projectPublicKey, imagePublicKey)
          fileName = "./#{projectPublicKey}/#{imagePublicKey}.#{extension}"
          resolve fileName
        , reject

  deleteFile: (file, projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      @_reloadExtensions(projectPublicKey).then =>
        fileBasePath = "#{projectPublicKey}/#{imagePublicKey}"
        @extensions[fileBasePath].forEach (extension) ->
          filePath = "./#{fileBasePath}.#{extension}"
          fs.unlink filePath, (err) =>
            if err
              reject "can't remove file: #{filePath}"
            else
              resolve()

  _findInExtensions: (projectPublicKey, imagePublicKey) =>
    extensions = @extensions["#{projectPublicKey}/#{imagePublicKey}"]
    _.difference(extensions, ['json'])[0]

  _reloadExtensions: (projectPublicKey) =>
    new Promise (resolve, reject) =>
      fs.readdir "./#{projectPublicKey}", (err, files) =>
        if err
          reject "can't read the project directory: #{projectPublicKey}"
        else
          @_fillExtensions(projectPublicKey, files)
          resolve()

  _fillExtensions: (projectPublicKey, files) =>
    for fileName in files
      [baseName, extension] = fileName.split /.(\w+)$/, 2
      basePath = "#{projectPublicKey}/#{baseName}"
      @extensions[basePath] ||= []
      @extensions[basePath].push extension

module.exports = FsProvider
