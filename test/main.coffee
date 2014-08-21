# global describe, it

fs = require("fs")
es = require("event-stream")
should = require("should")
require "mocha"
delete require.cache[require.resolve("../")]

gutil = require("gulp-util")
indent = require("../")
describe "gulp-indent", ->

  expectedFiles = 

    spaces: new gutil.File
      path: "test/expected/spaces.txt"
      cwd: "test/"
      base: "test/expected"
      contents: fs.readFileSync("test/expected/spaces.txt")

    tabs:new gutil.File
      path: "test/expected/tabs.txt"
      cwd: "test/"
      base: "test/expected"
      contents: fs.readFileSync("test/expected/tabs.txt")

  it "should produce expected files via buffer", (done) ->

    origin_file = new gutil.File
      path: "test/fixtures/origin.txt"
      cwd: "test/"
      base: "test/fixtures"
      contents: fs.readFileSync("test/fixtures/origin.txt")

    space_stream = indent()

    space_stream.on "error", (err) ->
      should.exist err
      done err
      return

    space_stream.on "data", (newFile) ->
      should.exist newFile
      should.exist newFile.contents
      String(newFile.contents).should.equal String(expectedFiles.spaces.contents)
      
      tab_stream = indent(tabs:true)

      tab_stream.on "error", (err) ->
        should.exist err
        done err
        return

      tab_stream.on "data", (newFile) ->
        should.exist newFile
        should.exist newFile.contents
        String(newFile.contents).should.equal String(expectedFiles.tabs.contents)
        done()
        return
        
      origin_file.contents = fs.readFileSync("test/fixtures/origin.txt")

      tab_stream.write origin_file
      tab_stream.end()


    space_stream.write origin_file
    space_stream.end()


    return

  it "should error on stream", (done) ->
    srcFile = new gutil.File(
      path: "test/fixtures/origin.txt"
      cwd: "test/"
      base: "test/fixtures"
      contents: fs.createReadStream("test/fixtures/origin.txt")
    )
    stream = indent()
    stream.on "error", (err) ->
      should.exist err
      done()
      return

    stream.on "data", (newFile) ->
      newFile.contents.pipe es.wait((err, data) ->
        done err
        return
      )
      return

    stream.write srcFile
    stream.end()
    return

  return
