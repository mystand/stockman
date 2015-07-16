md5 = require 'MD5'

class Coder
  constructor: (@salt = '') ->

  uniq2priv: (uniqKey) =>
    Coder.uniq2priv uniqKey, @salt

  priv2pub: (privKey) =>
    Coder.priv2pub privKey, @salt

  uniq2pub: (privKey) =>
    Coder.uniq2pub privKey, @salt

  @uniq2priv: (uniqKey, salt = '') ->
    md5 uniqKey + salt

  @priv2pub: (privKey, salt = '') ->
    md5 privKey + salt

  @uniq2pub: (uniqKey, salt = '') ->
    @priv2pub @uniq2priv(uniqKey, salt), salt

  @randomKey: ->
    md5 Math.random()

  @randomSalt: ->
    md5 Math.random()

module.exports = Coder