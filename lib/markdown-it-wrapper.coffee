'use strict'
MarkdownIt  = require 'markdown-it'

module.exports = (options) ->
  options = options or {}
  options.disable = options.disable or []
  options.markdownItOptions = options.markdownItOptions or {}
  md = new MarkdownIt(options.preset or 'default', options.markdownItOptions)
  if options.disable and options.disable.length
    md.core.ruler.disable options.disable
  md
