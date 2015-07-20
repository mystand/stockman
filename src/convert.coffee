convert = (src, processingString) ->
  new Promise (resolve, reject) ->
    ext = path.extname localFilePath
    tmpFilePath = path.join tmpPath, "#{Coder.randomKey()}#{ext}"
    resolve tmpFilePath

module.exports = convert