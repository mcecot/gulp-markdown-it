'use strict';
var PluginError, _, gutil, markdownIt, markdownItPlugin, through;

through = require('through2');

_ = require('underscore');

gutil = require('gulp-util');

PluginError = gutil.PluginError;

markdownIt = require('markdown-it');

markdownItPlugin = function(options) {
  var default_opt, i, len, md, plugin, ref;
  if (options == null) {
    options = {};
  }
  default_opt = {
    preset: 'default',
    plugins: [],
    options: {}
  };
  options = _.extend(default_opt, options);
  md = markdownIt(options.preset, options.options);
  ref = options.plugins;
  for (i = 0, len = ref.length; i < len; i++) {
    plugin = ref[i];
    if (typeof plugin === "string") {
      md.use(require(plugin));
    } else if (plugin.constructor === Array && plugin.length === 2) {
      md.use(require(plugin[0]), plugin[1]);
    }
  }
  return through.obj(function(file, encoding, callback) {
    var err;
    if (file.isNull() || file.content === null) {
      callback(null, file);
      return;
    }
    if (file.isStream()) {
      callback(new gutil.PluginError('gulp-markdown-it', 'stream content is not supported'));
      return;
    }
    try {
      file.contents = new Buffer(md.render(file.contents.toString()));
      file.path = gutil.replaceExtension(file.path, '.html');
      this.push(file);
    } catch (error) {
      err = error;
      callback(new gutil.PluginError('gulp-markdown-it', err, {
        fileName: file.path,
        showstack: true
      }));
    }
    callback();
  });
};

'use strict';


/**
 * Module dependencies.
 */

module.exports = markdownItPlugin;
