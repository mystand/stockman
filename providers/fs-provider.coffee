fs = require 'fs'

class FsProvider
  constructor: ->
    @extensions = {}

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

  completeFileName: (fileName) =>
    new Promise (resolve, reject) =>
      result = @_findInExtensions(fileName)
      return resolve(result) if result?
      @_reloadExtensions().then () =>
        resolve @_findInExtensions(fileName)


  _findInExtensions: (fileName) =>
    @extensions[fileName]

  _reloadExtensions: (projectPublicKey) =>
    new Promise (resolve, reject) =>
      fs.readdir './', (err, files) =>
        if err
          reject 'can\'t read the project directory'
        else
          for file in files
            console.log file


module.exports = FsProvider
