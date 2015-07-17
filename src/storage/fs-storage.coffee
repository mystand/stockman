fs = require 'fs'
_ = require 'underscore'
path = require 'path'
Coder = require '../coder'
mkdirp = require 'mkdirp'

class FsStorage
  constructor: (@config) ->
    @path = @config.path
    @extensions = {
#     "projectPublicKey/imagePublicKey": [extensions]
    }

  getSalt: (projectPrivateKey) =>
    new Promise (resolve, reject) =>
      fs.readFile path.join(@path, 'private', "#{projectPrivateKey}.json"), (err, json) =>
        if err
          reject "can't access to the project data file: #{err}"
        else
          try
            projectData = JSON.parse json
          catch
            reject "can't parse project data file"
          if projectData.salt?
            resolve projectData.salt
          else
            reject "project data file does not contains salt"

  saveFile: (file, projectPublicKey, imagePublicKey) =>
    projectPath = path.join @path, 'public', projectPublicKey
    new Promise (resolve, reject) =>
      fs.access projectPath, fs.R_OK | fs.W_OK | fs.X_OK, (err) ->
        if err
          reject "can't access to the project dir"
        else
          resolve()
    .then ->
      filePath = path.join projectPath, "#{imagePublicKey}.#{file.extension}"
      fs.rename file.path, filePath, (err) =>
        if err
          throw "can't move file (#{file.path}) to the target path (#{filePath})"

  getFilePath: (projectPublicKey, imagePublicKey, extension) =>
    new Promise (resolve, reject) =>
      if !_.isEmpty(extension)
        resolve "#{imagePublicKey}#{extension}"
      else
        @_completeFileName(projectPublicKey, imagePublicKey).then (fileName) ->
          resolve fileName
    .then (relativeFilePath) =>
      path.resolve path.join(@path, 'public', projectPublicKey, relativeFilePath)

  deleteFile: (projectPublicKey, imagePublicKey) =>
    @_reloadExtensions(projectPublicKey).then =>
      fileBasePath = path.join projectPublicKey, imagePublicKey
      extensions = @extensions[fileBasePath]
      Promise.all _(extensions).map (extension) =>
        new Promise (resolve, reject) =>
          filePath = path.join @path, 'public', "#{fileBasePath}#{extension}"
          fs.unlink filePath, (err) =>
            if err
              reject "can't remove file: #{filePath}"
            else
              resolve()

  addProject: (name) =>
    projectPrivateKey = Coder.randomKey()
    projectPublicKey = (new Coder).priv2pub projectPrivateKey
    salt = Coder.randomSalt()
    projectPath = path.join @path, 'public', projectPublicKey
    mkdirp.sync projectPath
    mkdirp.sync path.join(@path, 'private')
    projectFile = path.join @path, 'private', "#{projectPrivateKey}.json"
    fd = fs.openSync projectFile, 'w'
    fs.writeSync fd, JSON.stringify({name: name, salt: salt, privateKey: projectPrivateKey, publicKey: projectPublicKey})
    humanPath = path.join(@path, 'human')
    mkdirp.sync humanPath
    fs.symlinkSync path.resolve(projectPath), path.join(humanPath, name)
    fs.symlinkSync path.resolve(projectFile), path.join(humanPath, name + '.json')
    {projectPrivateKey, salt}

  #  returns <filename><extension> without project's folder name
  #
  _completeFileName: (projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      extension = @_findInExtensions(projectPublicKey, imagePublicKey)
      if result?
        resolve "#{imagePublicKey}.#{extension}"
      else
        @_reloadExtensions(projectPublicKey).then =>
          extension = @_findInExtensions(projectPublicKey, imagePublicKey)
          resolve "#{imagePublicKey}#{extension}"
        , reject

  # Working with extensions

  _findInExtensions: (projectPublicKey, imagePublicKey) =>
    extensions = @extensions["#{projectPublicKey}/#{imagePublicKey}"]
    _.find extensions, (extension) -> extension != '.json'

  _reloadExtensions: (projectPublicKey) =>
    @extensions = {}
    new Promise (resolve, reject) =>
      fs.readdir path.join(@path, 'public', projectPublicKey), (err, files) =>
        if err
          reject "can't read the project directory: #{projectPublicKey}"
        else
          for fileName in files
            {name:imagePublicKey, ext:extension} = path.parse fileName
            basePath = "#{projectPublicKey}/#{imagePublicKey}"
            @extensions[basePath] ||= []
            @extensions[basePath].push extension
          resolve()

module.exports = FsStorage
