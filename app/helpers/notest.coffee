
hbs = require 'hbs'

module.exports = (app) ->
  hbs.registerHelper 'notest', (options) -> 
    if process.env.NODE_ENV != "test"
      input = options.fn(@)
      return input
    else
      return ""
