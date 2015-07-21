Coder = require './coder'
path = require 'path'
fs = require 'fs'
_ = require 'underscore'
imagemagick = require 'imagemagick-native'

class Wizard
  constructor: (@tmpPath) ->

  PROCESSORS:
    w: (options, argument) ->
      options.width = argument

    h: (options, argument) ->
      options.height = argument

  turnTo: (src, processingString) =>
    ext = path.extname src
    tmpFilePath = path.join @tmpPath, "#{Coder.randomKey()}#{ext}"
    convertOptions =
      format: ext.replace('.', ''),
      quality: 100

    for parameter in processingString.split(',')
      [key, argument] = parameter.split '_'
      processor = @PROCESSORS[key]
      processor(convertOptions, argument) if _.isFunction(processor)

    new Promise (resolve, reject) =>
      fs.readFile src, (error, data) ->
        options = _.extend {srcData: data}, convertOptions

        fs.writeFile tmpFilePath, imagemagick.convert(options), (err) ->
          if err then reject(status: 500, error: err) else resolve(tmpFilePath)

module.exports = Wizard