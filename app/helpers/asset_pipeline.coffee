hbs = require 'hbs'
path = require 'path'
Mincer  = require('mincer')

module.exports = (app) ->
  environment = new Mincer.Environment()
  environment.appendPath('app/assets/js')
  environment.appendPath('app/assets/css')

  app.use("/assets", Mincer.createServer(environment))

  # dummy helper that injects extension
  rewrite_extension = (source, ext) ->
    source_ext = path.extname(source)
    if (source_ext == ext) 
      source 
    else
      (source + ext)

  # returns a list of asset paths
  find_asset_paths = (logicalPath, ext) ->
    asset = environment.findAsset(logicalPath)
    paths = []

    if (!asset)
      return null

    if ('production' != process.env.NODE_ENV && asset.isCompiled)
      asset.toArray().forEach (dep) ->
        paths.push('/assets/' + rewrite_extension(dep.logicalPath, ext) + '?body=1')
    else
      paths.push('/assets/' + rewrite_extension(asset.digestPath, ext))

    return paths

  hbs.registerHelper 'js', (logicalPath) ->
    paths = find_asset_paths(logicalPath, ".js")

    if (!paths) 
      # this will help us notify that given logicalPath is not found
      # without "breaking" view renderer
      return new hbs.SafeString("<script type=\"application/javascript\">alert('Javascript file
        #{JSON.stringify(logicalPath).replace(/"/g, '\\"')}
        not found.')</script>")

    result = paths.map (path) ->
      "<script type=\"application/javascript\" src=\"#{path}\"></script>"
    new hbs.SafeString(result.join("\n"))

  hbs.registerHelper 'css', (logicalPath) ->
    paths = find_asset_paths(logicalPath, ".css")

    if (!paths) 
      # this will help us notify that given logicalPath is not found
      # without "breaking" view renderer
      return new hbs.SafeString("<script type=\"application/javascript\">alert('CSS file
        #{JSON.stringify(logicalPath).replace(/"/g, '\\"')}
        not found.')</script>")

    result = paths.map (path) ->
      '<link rel="stylesheet" type="text/css" href="' + path + '" />'
    new hbs.SafeString(result.join("\n"))
