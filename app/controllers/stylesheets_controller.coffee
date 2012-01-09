less = require 'less'
fs = require 'fs'
less = new less.Parser
  paths: ['.', './lib', __dirname + '/../stylesheets/']

module.exports = (app) ->
  stylesheets = {}

  app.get "/stylesheets/:name.css", (req, res) ->
    path = __dirname + "/../stylesheets/#{req.params.name}.less"
    name = req.params.name
    if stylesheets.name?
      res.header("Content-type", "text/css")
      res.send(stylesheets[name])
    else
      fs.readFile path, "utf8", (err, data) ->
        if (err)
          res.send(404)
        else
          less.parse data, (err, tree) ->
            throw err if (err)
            css = tree.toCSS(compress: process.env.NODE_ENV == "production")
            stylesheets[name] = css if process.env.NODE_ENV == "production"
            res.header("Content-type", "text/css")
            res.send(css)
