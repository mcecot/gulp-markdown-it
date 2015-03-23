'use strict'
through       = require 'through2'
_             = require 'underscore'
gutil         = require 'gulp-util'
{PluginError} = gutil
markdownIt  = require 'markdown-it'

markdownItPlugin = (options = {}) ->
  default_opt =
    preset: 'default'
    plugins: []
    options: {}
  options = _.extend default_opt, options
  md      = markdownIt(options.preset,options.options)
  for plugin in options.plugins
    if(typeof plugin == "string")
      md.use require(plugin)
    else if (plugin.constructor == Array && plugin.length == 2)
      md.use require(plugin[0]), plugin[1]

  through.obj (file, encoding, callback) ->

    if file.isNull() || file.content == null
      callback null, file
      return

    if file.isStream()
      callback new (gutil.PluginError)(
        'gulp-markdown-it',
        'stream content is not supported'
      )
      return

    try
      file.contents = new Buffer(md.render(file.contents.toString()))
      file.path = gutil.replaceExtension(
        file.path, '.html'
      )
      @push file

    catch err
      # @emit 'error', new gutil.PluginError(
      #   'gulp-markdown-it', err, {fileName: file.path, showstack: true}
      # )
      callback new (gutil.PluginError)(
        'gulp-markdown-it',
        err,
        {fileName: file.path, showstack: true}
      )
    callback()
    return

'use strict'

###*
# Module dependencies.
###
module.exports = markdownItPlugin
