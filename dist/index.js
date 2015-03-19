'use strict';
var PluginError, createPluginError, gutil, markdownIt, markdownItPlugin, through;

through = require('through2');

gutil = require('gulp-util');

PluginError = gutil.PluginError;

markdownIt = require('markdown-it');

createPluginError = function(message) {
  return new PluginError('gulp-markdown-it', message);
};

markdownItPlugin = function(opt) {
  var i, len, md, options, plugin, plugins, preset, ref, ref1, ref2;
  if (opt == null) {
    opt = {};
  }
  preset = (ref = opt.preset) != null ? ref : 'default';
  plugins = (ref1 = opt.plugins) != null ? ref1 : [];
  options = (ref2 = opt.options) != null ? ref2 : {};
  md = markdownIt(preset, options);
  for (i = 0, len = plugins.length; i < len; i++) {
    plugin = plugins[i];
    md.use(require(plugin));
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
    } catch (_error) {
      err = _error;
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
