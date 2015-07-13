fs = require 'fs'
_ = require 'underscore'
mkdirp = require 'mkdirp'

class FsStorage
  constructor: ->
    @extensions = {
#     "projectPublicKey/imagePublicKey": [extensions]
    }
    @path = './tmp'

  getSalt: (projectPublicKey) =>
    new Promise (resolve, reject) =>
      fs.readFile @_buildPath("#{projectPublicKey}.salt"), (err, salt) =>
        if err
          reject "can't access to the project salt file"
        else
          resolve salt

  saveFile: (file, projectPublicKey, imagePublicKey) =>
    projectPath = @_buildPath projectPublicKey
    new Promise (resolve, reject) =>
      mkdirp projectPath, (err) ->
        if err
          reject "can't create dir: #{projectPath}"
        else
          resolve()
    .then () ->
      filePath = "#{projectPath}/#{imagePublicKey}.#{file.extension}"
      fs.rename file.path, filePath, (err) =>
        if err
          console.log("can't move file (#{file.path}) to the target path (#{filePath})")
          reject "can't move file (#{file.path}) to the target path (#{filePath})"
        else
          resolve()


  completeFileName: (projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      extension = @_findInExtensions(projectPublicKey, imagePublicKey)
      if result?
        fileName = @_buildPath("#{projectPublicKey}/#{imagePublicKey}.#{extension}")
        resolve fileName
      else
        @_reloadExtensions(projectPublicKey).then =>
          extension = @_findInExtensions(projectPublicKey, imagePublicKey)
          fileName = @_buildPath("#{projectPublicKey}/#{imagePublicKey}.#{extension}")
          resolve fileName
        , reject

  deleteFile: (file, projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      @_reloadExtensions(projectPublicKey).then =>
        fileBasePath = "#{projectPublicKey}/#{imagePublicKey}"
        @extensions[fileBasePath].forEach (extension) ->
          filePath = @_buildPath("#{fileBasePath}.#{extension}")
          fs.unlink filePath, (err) =>
            if err
              reject "can't remove file: #{filePath}"
            else
              resolve()

  _buildPath: (path) =>
    "#{@path}/#{path}"

  _findInExtensions: (projectPublicKey, imagePublicKey) =>
    extensions = @extensions["#{projectPublicKey}/#{imagePublicKey}"]
    _.difference(extensions, ['json'])[0]

  _reloadExtensions: (projectPublicKey) =>
    new Promise (resolve, reject) =>
      fs.readdir @_buildPath("#{projectPublicKey}"), (err, files) =>
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

  @addArguments: (parser) ->
    parser.addArgument [ '--path' ],
      help: 'Files path'
      defaultValue: '.'

module.exports = FsStorage
