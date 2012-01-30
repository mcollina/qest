
child_process = require('child_process')
process = global.process
path = require('path')

run_external = (command, args=[], callback) ->
  console.log("Running #{command} #{args.join(" ")}")
  child = child_process.spawn(command, args)
  child.stdout.on "data", (data) -> process.stdout.write(data)
  child.stderr.on "data", (data) -> process.stderr.write(data)
  child.on('exit', callback) if callback?

launchSpec = (args...) ->
  child_process.exec 'find test -iname \'*spec.coffee\'', (err, stdout, stderr) ->
    files = stdout.trim().split("\n")
    run_external "./node_modules/.bin/mocha", args.concat(files)

task "spec", ->
  launchSpec()

task "spec:ci", ->
  launchSpec("--watch")
