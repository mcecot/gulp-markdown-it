# module dependencies
should = require 'should'
gutil = require 'gulp-util'
path = require 'path'

# const
PLUGIN_NAME = 'gulp-markdown-it'
ERRS =
  MSG:
    'msg param needs to be a string, dummy'
  STREAM:
    'stream content is not supported'
  PRESET:
    "Error: Wrong `markdown-it` preset \"wrong\", check name"

# SUT
markdownIt = require '../'

createFakeFile = (content) ->
  content = content ? '# Headline\n'+
    'Simple Paragraph, but **Strong**'
  file = new gutil.File
    path: 'test/fixture/sample.md',
    cwd: './test/',
    base: './test/fixture/',
    contents: new Buffer content
  return file

describe 'gulp-markdown-it', ->
  describe 'markdownIt()', ->
    it 'should pass through empty files', (done) ->
      dataCounter = 0

      fakeFile = createFakeFile()
      fakeFile.contents = null

      stream = markdownIt()

      stream.on 'data', (newFile) ->
        should.exist(newFile)
        should.exist(newFile.path)
        should.exist(newFile.relative)
        should.not.exist(newFile.contents)
        newFile.path.should.equal fakeFile.path
        ++dataCounter

      stream.once 'end', ->
        dataCounter.should.equal 1
        done()

      stream.write fakeFile
      stream.end()

    it 'should pass through a file', (done) ->
      dataCounter = 0

      fakeFile = createFakeFile()
      stream = markdownIt()

      stream.on 'data', (newFile) ->
        should.exist(newFile)
        should.exist(newFile.path)
        should.exist(newFile.relative)
        should.exist(newFile.contents)
        newFile.path.should.equal 'test/fixture/sample.html'
        newFile.relative.should.equal 'sample.html'
        newFile.contents.toString().should.equal(
          '<h1>Headline</h1>\n<p>Simple Paragraph, '+
          'but <strong>Strong</strong></p>\n'
        )

        ++dataCounter


      stream.once 'end', ->
        dataCounter.should.equal 1
        done()

      stream.write fakeFile
      stream.end()

    it 'should pass through two files', (done) ->
      dataCounter = 0

      fakeFile = createFakeFile()
      fakeFile2 = createFakeFile()


      stream = markdownIt()

      stream.on 'data', (newFile) ->
        ++dataCounter

      stream.once 'end', ->
        dataCounter.should.equal 2
        done()

      stream.write fakeFile
      stream.write fakeFile2
      stream.end()

    it 'should use options', (done) ->
      dataCounter = 0
      fakeFile = createFakeFile('(c)')
      stream = markdownIt
        options:
          typographer: true

      stream.on 'data', (newFile) ->
        ++dataCounter
        newFile.contents.toString().should.equal(
          '<p>©</p>\n'
        )

      stream.once 'end', ->
        dataCounter.should.equal 1
        done()

      stream.write fakeFile
      stream.end()

    it 'should optionally activate plugins', (done) ->
      fakeFile = createFakeFile('[X] check')
      stream = markdownIt({
        plugins: ['markdown-it-checkbox']
      })

      stream.on 'data', (newFile) ->
        newFile.contents.toString().should.equal(
          '<p><input type="checkbox" id="checkbox0" checked="true">'+
          '<label for="checkbox0">check</label></p>\n'
        )
        done()

      stream.write fakeFile
      stream.end()

    it 'should optionally use plugin options', (done) ->
      fakeFile = createFakeFile('[X] check')
      stream = markdownIt({
        plugins: [['markdown-it-checkbox',{divWrap: true}]]
      })

      stream.on 'data', (newFile) ->
        newFile.contents.toString().should.equal(
          '<p><div class="checkbox">'+
          '<input type="checkbox" id="checkbox0" checked="true">'+
          '<label for="checkbox0">check</label></div></p>\n'
        )
        done()

      stream.write fakeFile
      stream.end()

    describe 'errors', ->
      describe 'are thrown', ->
        it 'if configuration is just wrong', (done) ->
          try
            stream = markdownIt({
              preset: 'wrong'
            })
          catch e
            should( e.toString() ).equal ERRS.PRESET
            done()

      describe 'are emitted', ->
        it 'if file content is stream', (done) ->
          fakeFile = new gutil.File
            path: './test/fixture/file.js',
            cwd: './test/',
            base: './test/fixture/',
            contents: process.stdin

          stream = markdownIt()

          stream.on 'error', (e) ->
            should(e.plugin).equal PLUGIN_NAME
            should(e.message).equal ERRS.STREAM
            done()

          stream.write fakeFile
          stream.end()
