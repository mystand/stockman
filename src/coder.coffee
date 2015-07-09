md5 = require 'MD5'

class Coder
  constructor: (@salt = '') ->

  uniq2priv: (uniqKey) =>
    md5 uniqKey + @salt

  uniq2pub: (uniqKey) =>
    md5 @uniq2priv(uniqKey) + @salt

  priv2pub: (privKey) =>
    md5 privKey + @salt

module.exports = Coder