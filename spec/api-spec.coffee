fs = require 'fs'
request = require 'request'
assert = require('chai').assert
given = require 'mocha-testdata'

Coder = require '../src/coder'

#########
# Constants
#########

API_HOST = 'http://localhost:3333'

SALT = "0246d073-0572-48a1-9c6a-5acd1eb1e75e"
CODER = new Coder SALT
PROJECT_PRIVATE_KEY = "0246d0735acd1eb1e75e"
PROJECT_PUBLIC_KEY = (new Coder).priv2pub PROJECT_PRIVATE_KEY
IMAGE_PRIVATE_KEY = "1246d0735a2d1eb1e75e"
IMAGE_PUBLIC_KEY = CODER.priv2pub IMAGE_PRIVATE_KEY

IMAGE_PATH = './spec/fixtures/lemongrab.jpg'
IMAGE_CONTENT_TYPE = 'image/jpeg'

#########
# Helpers
#########

btoa = (string) ->
  new Buffer(string).toString('base64')

exitWithError = (error) ->
  throw "Fatal error -> #{error}"

errorFilterFor = (callback) ->
  return (error, response, body) ->
    exitWithError(error) if error?.code is 'ECONNREFUSED'
    callback(error, response, body)

uploadObject = (privateObjectKey, filePath) ->
  new Promise (resolve, reject) =>
    url = "#{API_HOST}/#{PROJECT_PRIVATE_KEY}/#{privateObjectKey}"
    options =
      url: url
      formData:
        file: fs.createReadStream filePath
    request.post options, (error, response, _) ->
      resolve response

downloadObject = (publicObjectKey, options = {}) ->
  extension = if options.extension then ".#{options.extension}" else ''
  url = "#{API_HOST}/#{PROJECT_PUBLIC_KEY}/#{publicObjectKey}#{extension}"
  new Promise (resolve, reject) =>
    request.get url, (error, response, _) ->
      resolve response

#########
# Tests
#########

describe 'Stockman api', ->
  before ->
    fs.writeFileSync "./tmp/#{PROJECT_PUBLIC_KEY}.salt", SALT

  describe 'for single picture', ->
    describe 'POST upload image', ->
      # POST http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be success', () ->
        uploadObject(IMAGE_PRIVATE_KEY, IMAGE_PATH).then (response) ->
          assert.equal response.statusCode, 200
          assert.equal response.body, '{}'

    describe 'GET download image', ->
      # GET http://v1.stockman.com/<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[/<PROCESSING_STRING>][.<EXTENSION>]
      describe 'should be success', ->

        # todo: try remove async
        given.async(
          null,
          'jpg'
        ).it 'with extension', (done, extension) ->
          uploadObject(IMAGE_PRIVATE_KEY, IMAGE_PATH).then ->
            downloadObject IMAGE_PUBLIC_KEY, extension: extension
          .then (response) ->
            assert.equal response.statusCode, 200
            assert.equal response.headers['content-type'], IMAGE_CONTENT_TYPE
            done()
          .catch (err) -> done(err)

    describe 'DELETE remove image', ->
      # DELETE http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be filled', ->
