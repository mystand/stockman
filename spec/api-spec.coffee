fs = require 'fs'
request = require 'request'
assert = require('chai').assert
given = require 'mocha-testdata'
_ = require 'underscore'

Coder = require '../src/coder'

app = require '../src/app'

#########
# Constants
#########

API_HOST = 'http://localhost'
API_PORT = 8888

SINGLE_IMAGE_UNIQ_KEY = 'test image'
SINGLE_IMAGE_PATH = './spec/fixtures/lemongrab.jpg'
SINGLE_IMAGE_CONTENT_TYPE = 'image/jpeg'

PROJECT_NAME = "project-#{Date.now()}"

#########
# Global variables
#########

serverStarted = false
salt = null
projectPrivateKey = null
coder = null

#########
# Helpers
#########

btoa = (string) ->
  new Buffer(string).toString('base64')

exitWithError = (error) ->
  throw "Fatal error -> #{error}"

errorFilterFor = (callback) ->
  (error, response, body) ->
    exitWithError(error) if error?.code is 'ECONNREFUSED'
    callback(error, response, body)

uploadImage = (imageUniqKey, filePath) ->
  imagePrivateKey = coder.uniq2priv imageUniqKey
  new Promise (resolve, reject) =>
    url = "#{API_HOST}:#{API_PORT}/#{projectPrivateKey}/#{imagePrivateKey}"
    options =
      url: url
      formData:
        file: fs.createReadStream filePath
    request.post options, (error, response) ->
      resolve response

downloadImage = (imagePublicKey, extension) ->
  url = "#{API_HOST}:#{API_PORT}/#{projectPrivateKey}/#{imagePublicKey}#{extension}"
  new Promise (resolve, reject) =>
    request.get url, (error, response) ->
      resolve response

#createProject

#########
# Tests
#########

describe 'Stockman server', ->
  before ->
    app(['--path', 'test-area', 'add-project', PROJECT_NAME])
    .then (result) ->
      {salt, projectPrivateKey} = result
      coder = new Coder salt
    .then ->
      app(['--path', 'test-area', 'start', '--port', API_PORT]).then (result) ->
        serverStarted = result

  describe 'should have created a project', ->
    it "salt must be filled", ->
      assert.notOk _.isEmpty(salt)
    it "project private key must be filled", ->
      assert.notOk _.isEmpty(projectPrivateKey)

  describe 'should be started', ->
    it "server should return 'Stockman listen #{API_PORT} port...' on start", ->
      assert.equal serverStarted, "Stockman listen #{API_PORT} port..."

  describe 'should be friendly', ->
    describe 'GET /hello', ->
      # POST http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it "should be success and return 'hello'", (done) ->
        request.get {url: "#{API_HOST}:#{API_PORT}/hello"}, (error, response) ->
          assert.equal response.statusCode, 200
          assert.equal response.body, 'hello'
          done()

  describe 'for single picture', ->
    describe 'POST upload image', ->
      # POST /<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
      it 'should be success', () ->
        uploadImage(SINGLE_IMAGE_UNIQ_KEY, SINGLE_IMAGE_PATH).then (response) ->
          assert.equal response.statusCode, 200
          assert.equal response.body, '{}'

    describe 'GET download image', ->
      # GET /<PROJECT_PUBLIC_KEY>/<IMAGE_PUBLIC_KEY>[/<PROCESSING_STRING>][.<EXTENSION>]
      describe 'should be success', ->

        # todo: try remove async
        given.async(undefined, 'jpg')
        .it 'with extension', (done, extension) ->
          uploadImage(SINGLE_IMAGE_UNIQ_KEY, SINGLE_IMAGE_PATH).then ->
            imageUniqKey = coder.uniq2pub SINGLE_IMAGE_UNIQ_KEY
            downloadImage imageUniqKey, extension
          .then (response) ->
            assert.equal response.statusCode, 200
            assert.equal response.headers['content-type'], SINGLE_IMAGE_CONTENT_TYPE
            done()
          .catch (err) -> done(err)
#
#    describe 'DELETE remove image', ->
#      # DELETE http://v1.stockman.com/<PROJECT_PRIVATE_KEY>/<IMAGE_PRIVATE_KEY>
#      it 'should be filled', ->