
hbs = require 'hbs'

module.exports = (app) ->
  hbs.registerHelper 'markdown', (options) ->
    input = options.fn(@)
    result = require( "markdown" ).markdown.toHTML(input)
    return result
