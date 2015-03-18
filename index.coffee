'use strict'
through = require 'through2'
gutil = require 'gulp-util'
{PluginError} = gutil
markdownIt  = require 'markdown-it'

createPluginError = (message) ->
  new PluginError 'gulp-markdown-it', message

markdownItPlugin = (opt = {}) ->
  preset = opt.preset ? 'default'
  plugins = opt.plugins ? []
  options = opt.options ? {}
  md = markdownIt(preset,options)
  for plugin in plugins
    md.use(require plugin)
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
