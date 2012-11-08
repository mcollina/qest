
helper = require("../spec_helper")

expect = require('chai').expect
async = require("async")

describe "Data", ->

  models = null

  before -> 
    helper.globalSetup()
    models = helper.app.models

  after ->
    helper.globalTearDown()

  beforeEach (done) ->
    helper.setup(done)
  
  afterEach (done) ->
    helper.tearDown(done)

  it "should have a findOrCreate method", ->
    expect(models.Data.findOrCreate).to.exist

  it "should findOrCreate a new instance with a key", (done) ->
    models.Data.findOrCreate "key", (err, data) =>
      expect(data).to.eql(new models.Data("key"))
      done()

  it "should findOrCreate a new instance with a key and a value", (done) ->
    models.Data.findOrCreate "aaa", "bbbb", (err, data) =>
      expect(data).to.eql(new models.Data("aaa", "bbbb"))
      done()

  it "should findOrCreate an old instance overriding the value", (done) ->
    models.Data.findOrCreate "aaa", "bbbb", =>
      models.Data.findOrCreate "aaa", "ccc", =>
        models.Data.find "aaa", (err, data) =>
          expect(data).to.eql(new models.Data("aaa", "ccc"))
          done()

  it "should publish an update when calling findOrCreate", (done) ->
    models.Data.subscribe "aaa", (data) =>
      done()
    models.Data.findOrCreate "aaa", "bbbb"

  it "should allow subscribing in the create step", (done) ->
    models.Data.findOrCreate "aaa", (err, data) =>
      models.Data.subscribe "aaa", (curr) ->
        done() if curr.value == "ccc"

      data.value = "ccc"
      data.save()

  it "should allow unsubscribing in the create step", (done) ->
    models.Data.findOrCreate "aaa", (err, data) =>
      func = -> throw "This should never be called"

      models.Data.subscribe "aaa", func
      models.Data.unsubscribe "aaa", func

      models.Data.subscribe "aaa", (curr) ->
        done()

      data.save()

  it "should provide a find method that returns an error if there is no obj", (done) ->
    models.Data.find "obj", (err, data) =>
      expect(err).to.eql("Record not found")
      done()

  it "should provide a find method that uses a regexp for matching", (done) ->
    results = []

    async.parallel([
      async.apply(models.Data.findOrCreate, "hello bob", "aaa"),
      async.apply(models.Data.findOrCreate, "hello mark", "aaa"),
    ], ->
      models.Data.find /hello .*/, (err, data) ->
        results.push(data.key) unless err?
        if results.length == 2
          expect(results).to.contain("hello bob")
          expect(results).to.contain("hello mark")
          done()
    )

  it "should provide a subscribe method that works for new topics", (done) ->
    results = []
    models.Data.subscribe "hello/*", (data) ->
      results.push(data.key)
      if results.length == 2
        expect(results).to.contain("hello/bob")
        expect(results).to.contain("hello/mark")
        done()

    async.parallel([
      async.apply(models.Data.findOrCreate, "hello/bob", "aaa"),
      async.apply(models.Data.findOrCreate, "hello/mark", "aaa"),
    ])

  describe "instance", ->

    it "should get the key", ->
      subject = new models.Data("key", "value")
      expect(subject.key).to.eql("key")

    it "should get the key (dis)", ->
      subject = new models.Data("aaa")
      expect(subject.key).to.eql("aaa")

    it "should get the value", ->
      subject = new models.Data("key", "value")
      expect(subject.value).to.eql("value")

    it "should get the value (dis)", ->
      subject = new models.Data("key", "aaa")
      expect(subject.value).to.eql("aaa")

    it "should get the redisKey", ->
      subject = new models.Data("key", "value")
      expect(subject.redisKey).to.eql("topic:key")

    it "should get the redisKey (dis)", ->
      subject = new models.Data("aaa/42", "value")
      expect(subject.redisKey).to.eql("topic:aaa/42")

    it "should accept an object as value in the constructor", ->
      obj = { hello: 42 }
      subject = new models.Data("key", obj)
      expect(subject.value).to.eql(obj)

    it "should export its value as JSON", ->
      obj = { hello: 42 }
      subject = new models.Data("key", obj)
      expect(subject.jsonValue).to.eql(JSON.stringify(obj))

    it "should export its value as JSON when setting the value", ->
      obj = { hello: 42 }
      subject = new models.Data("key")
      subject.value = obj
      expect(subject.jsonValue).to.eql(JSON.stringify(obj))

    it "should set the value", ->
      subject = new models.Data("key")
      subject.value = "bbb"
      expect(subject.value).to.eql("bbb")

    it "should set the value (dis)", ->
      subject = new models.Data("key")
      subject.value = "ccc"
      expect(subject.value).to.eql("ccc")

    it "should set the json value", ->
      subject = new models.Data("key")
      subject.jsonValue = JSON.stringify("ccc")
      expect(subject.value).to.eql("ccc")

    it "should have a save method", ->
      subject = new models.Data("key")
      expect(subject.save).to.exist

    it "should save an array", (done) ->
      subject = new models.Data("key")
      subject.value = [1, 2]
      subject.save =>
        done()

    it "should support subscribing for change", (done) ->
      subject = new models.Data("key")
      subject.save =>
        models.Data.subscribe subject.key, (data) =>
          expect(data.value).to.equal("aaaa")
          done()

        subject.value = "aaaa"
        subject.save()

    it "should register for change before creation", (done) ->
      subject = new models.Data("key")
      models.Data.subscribe subject.key, (data) =>
        expect(data.value).to.equal("aaaa")
        done()

      subject.value = "aaaa"
      subject.save()

    it "should save and findOrCreate", (done) ->
      subject = new models.Data("key")
      subject.save =>
        models.Data.findOrCreate subject.key, (err, data) =>
          expect(data).to.eql(subject)
          done()

    it "should save and find", (done) ->
      subject = new models.Data("key")
      subject.save =>
        models.Data.find subject.key, (err, data) =>
          expect(data).to.eql(subject)
          done()

    it "should not persist the value before save", (done) ->
      subject = new models.Data("key")
      subject.save =>
        subject.value = "ccc"
        models.Data.find subject.key, (err, data) ->
          expect(data.value).to.not.eql("ccc")
          done()
