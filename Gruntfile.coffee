module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # Coding standards
    coffeelint:
      lib:
        files:
          src: ['lib/*.coffee']
        options:
          max_line_length:
            value: 80
            level: 'warn'

    # BDD tests on Node.js
    cafemocha:
      nodejs:
        src: ['test/*.coffee']
        options:
          reporter: 'spec'
          ui: 'exports'

  @loadNpmTasks 'grunt-coffeelint'
  @loadNpmTasks 'grunt-cafe-mocha'

  @registerTask 'test', [
    'coffeelint'
    'cafemocha'
  ]
