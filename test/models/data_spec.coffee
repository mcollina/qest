
helper = require("../spec_helper")

expect = require('chai').expect

describe "Data", ->

  models = null

  before -> 
    helper.globalSetup()
    models = helper.app.models

  after ->
    helper.globalTearDown()

  beforeEach (done) ->
    helper.setup(done)

  it "should have a findOrCreate method", ->
    expect(models.Data.findOrCreate).to.exist

  it "should findOrCreate a new instance with a key", (done) ->
    models.Data.findOrCreate "key", (data) =>
      done()
      expect(data).to.eql(new models.Data("key"))

  it "should findOrCreate a new instance with a key and a value", (done) ->
    models.Data.findOrCreate "aaa", "bbbb", (data) =>
      done()
      expect(data).to.eql(new models.Data("aaa", "bbbb"))

  it "should findOrCreate an old instance overriding the value", (done) ->
    models.Data.findOrCreate "aaa", "bbbb", =>
      models.Data.findOrCreate "aaa", "ccc", =>
        models.Data.find "aaa", (data) =>
          done()
          expect(data).to.eql(new models.Data("aaa", "ccc"))

  it "should emit a change event when findOrCreate does not override the value", (done) ->
    models.Data.findOrCreate "aaa", "bbbb", (oldData) =>
      models.Data.findOrCreate "aaa", "bbbb"
      oldData.on 'change', (data) => done()

  it "should provide a global event for registering for new data (fired by findOrCreate)", (done) ->
    models.Data.on "newData", (data) =>
      expect(data).to.eql(new models.Data("hello world", "ggg"))
      done()
    models.Data.findOrCreate("hello world", "ggg")

  it "should provide a global event for registering for new data (fired by save)", (done) ->
    models.Data.on "newData", (data) =>
      expect(data).to.eql(new models.Data("hello world", "ggg"))
      done()

    new models.Data("hello world", "ggg").save()

  it "should provide a find method to detected if an object exists", (done) ->
    models.Data.find "obj", (data, err) =>
      done()
      expect(err).to.eql("Record not found")

  it "should provide a find method that returns an error if there is no obj", (done) ->
    models.Data.find "obj", (data, err) =>
      done()
      expect(err).to.eql("Record not found")

  it "should provide a find method that uses a regexp for matching", ->

    results = []
    waited = ->
      models.Data.find /hello .*/, (data, err) ->
        results.push(data.getKey()) unless err?
        if results.length == 2
          expect(results).toContain("hello bob")
          expect(results).toContain("hello mark")
          done()

    createdBob = false
    createdMark = false

    models.Data.findOrCreate "hello bob", "aaa", ->
      createdBob = true
      waited() if createdBob and createdMark

    models.Data.findOrCreate "hello mark", "aaa", -> 
      createdMark = true
      waited() if createdBob and createdMark

  describe "instance", ->

    beforeEach ->
      @subject = new models.Data("key", "value")

    it "should get the key", ->
      expect(@subject.getKey()).to.eql("key")

    it "should get the key (dis)", ->
      @subject = new models.Data("aaa")
      expect(@subject.getKey()).to.eql("aaa")

    it "should get the value", ->
      expect(@subject.getValue()).to.eql("value")

    it "should get the value (dis)", ->
      @subject = new models.Data("key", "aaa")
      expect(@subject.getValue()).to.eql("aaa")

    it "should set the value", ->
      @subject.setValue("bbb")
      expect(@subject.getValue()).to.eql("bbb")

    it "should set the value (dis)", ->
      @subject.setValue("ccc")
      expect(@subject.getValue()).to.eql("ccc")

    it "should have a save method", ->
      expect(@subject.save).to.exist

    it "should register for change", (done) ->
      @subject.save =>
        @subject.on 'change', (data) =>
          expect(data.getValue()).to.eql("aaaa")
          done()

        @subject.setValue("aaaa")
        @subject.save()

    it "should save and findOrCreate", (done) ->
      @subject.save =>
        models.Data.findOrCreate @subject.getKey(), (data) =>
          done()
          expect(data).to.eql(@subject)

    it "should save and find", (done) ->
      @subject.save =>
        models.Data.find @subject.getKey(), (data) =>
          done()
          expect(data).to.eql(@subject)

    it "should not persist the value before save", (done) ->
      @subject.save =>
        @subject.setValue("ccc")
        models.Data.find @subject.getKey(), (data) ->
          done()
          expect(data.getValue()).to.not.eql("ccc")
