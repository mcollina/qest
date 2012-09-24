

hbs = require 'hbs'

module.exports = (app) ->
  hbs.registerHelper 'json', (context) -> 
    new hbs.SafeString(JSON.stringify(context))
