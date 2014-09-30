{spawn, exec} = require 'child_process'

task 'build', 'continually build the amqp-dsl library with --watch', ->
  coffee = spawn 'coffee', ['-cw', '--no-header', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'install', 'install dependencies', ->
  npm = spawn 'npm', ['install']
  npm.stdout.on 'data', (data) -> console.log data.toString().trim()

task 'doc', 'rebuild the documentation', ->
  exec([
    'rm -r docs'
    './node_modules/docco/bin/docco src/*.coffee examples/*.coffee'
  ].join(' && '), (err) ->
    throw err if err
  )

task 'test', 'run tests', ->
  npm = spawn 'npm', ['test']
  npm.stdout.on 'data', (data) -> console.log data.toString().trim()
