Coder = require './coder'
path = require 'path'
fs = require 'fs'

class Wizard
  constructor: (@tmpPath) ->

  turnTo: (src, processingString) =>
    new Promise (resolve, reject) =>
      ext = path.extname src
      tmpFilePath = path.join @tmpPath, "#{Coder.randomKey()}#{ext}"
      reader = fs.createReadStream src
      writer = fs.createWriteStream tmpFilePath
      reader.on 'end', =>
        writer.end()
        resolve tmpFilePath
      reader.pipe writer

module.exports = Wizard