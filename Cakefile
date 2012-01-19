
child_process = require('child_process')
process = global.process
path = require('path')

run_external = (command, args=[], callback) ->
  console.log("Running #{command} #{args.join(" ")}")
  child = child_process.spawn(command, args)
  child.stdout.on "data", (data) -> process.stdout.write(data)
  child.stderr.on "data", (data) -> process.stderr.write(data)
  child.on('exit', callback) if callback?

task "spec", ->
  run_external "./node_modules/jasmine-node/bin/jasmine-node", ["--coffee", "."]

task "ci", ->
  run_external "./node_modules/jasmine-node/bin/jasmine-node", ["--autotest", "--coffee", "."]
