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

    # Tests on Node.js
    noflo_test:
      nodejs:
        src: ['test/*.coffee']

  # Load local tasks
  @loadTasks 'tasks'

  # Load installed tasks
  @loadNpmTasks 'grunt-coffeelint'

  @registerTask 'test', [
    'coffeelint'
    'noflo_test'
  ]
