fs = require 'fs'
_ = require 'underscore'
path = require 'path'
Coder = require '../coder'
mkdirp = require 'mkdirp'
recursiveReaddir = require 'recursive-readdir'

class FsStorage
  constructor: (@config) ->
    @path = @config.path
    mkdirp.sync path.join(@path, folder) for folder in ['public', 'private', 'human']
    @db = @_fillDb()
  # projectPublicKey:
  #   imagePublicKey:
  #     origin: fullPath
  #     processingString: fullPath

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

  saveFile: (filePath, projectPublicKey, imagePublicKey, processingString) =>
    projectPath = path.join @path, 'public', projectPublicKey
    new Promise (resolve, reject) =>
      fs.access projectPath, fs.R_OK | fs.W_OK | fs.X_OK, (err) ->
        if err
          reject status: 404, error: "can't access to the project dir"
        else
          resolve()
    .then =>
      new Promise (resolve, reject) =>
        if _.isEmpty processingString
          resolve()
        else
          mkdirp path.join(projectPath, imagePublicKey), (err) =>
            if err
              reject status: 500, error: "can't make image directory"
            else
              resolve()
    .then =>
      new Promise (resolve, reject) =>
        extension = path.extname filePath
        fileName = _.compact([imagePublicKey, processingString]).join('/')
        destFilePath = path.join projectPath, "#{fileName}#{extension}"
        fs.rename filePath, destFilePath, (err) =>
          if err
            reject status: 500, error: "can't move file (#{file.path}) to the target path (#{filePath})"
          else
            @db[projectPublicKey] ||= {}
            @db[projectPublicKey][imagePublicKey] ||= {}
            @db[projectPublicKey][imagePublicKey][processingString || 'origin'] = destFilePath
            resolve type: 'local', data: destFilePath

  getFile: (projectPublicKey, imagePublicKey, extension, processingString = '') =>
    filePath = if extension
      path.join([@path, 'public', projectPublicKey, imagePublicKey, processingString]...) + extension
    else
      @db[projectPublicKey]?[imagePublicKey]?[processingString || 'origin']

    new Promise (resolve, reject) =>
      return reject(status: 404, error: "file does not exists") unless filePath
      fs.access filePath, fs.R_OK, (err) ->
        if err
          reject status: 404, error: "file does not exists"
        else
          resolve type: 'local', data: path.resolve(filePath)

  deleteFile: (projectPublicKey, imagePublicKey) =>
    new Promise (resolve, reject) =>
      imageData = @db[projectPublicKey]?[imagePublicKey]
      if imageData
        resolve imageData
      else
        reject status: 404, error: "can't find by public key: #{imagePublicKey}"
    .then (imageData) =>
      Promise.all _(imageData).values().map (filePath) =>
        new Promise (resolve, reject) =>
          fs.unlink filePath, (err) =>
            if err
              reject status: 500, error: "can't remove file: #{filePath}"
            else
              resolve()
    .then =>
      new Promise (resolve, reject) =>
        dirPath = path.join(@path, 'public', projectPublicKey, imagePublicKey)
        fs.access dirPath, fs.F_OK, (err) =>
          if err
            resolve()
          else
            fs.rmdir dirPath, (err) =>
              if !err then resolve() else reject(status: 500, error: "can't remove directory: #{dirPath}")

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

  _fillDb: =>
    res = {}
    for project in fs.readdirSync path.join(@path, 'public')
      res[project] = {}
      for image in fs.readdirSync(path.join @path, 'public', project)
        imagePublicKey = path.parse(image).name
        res[project][imagePublicKey] = {}
        filePath = path.join @path, 'public', project, image
        stat = fs.statSync filePath
        if stat.isDirectory()
          for processingString in fs.readdirSync(filePath)
            name = path.parse(processingString).name
            res[project][imagePublicKey][name] = path.join filePath, processingString
        else
          res[project][imagePublicKey].origin = filePath
    res

module.exports = FsStorage
