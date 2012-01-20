
describe "Data", ->

  afterEach ->
    @models.Data.reset?()

  it "should have a findOrCreate method", ->
    expect(@models.Data.findOrCreate).toBeDefined()

  it "should findOrCreate a new instance with a key", ->
    called = false
    @models.Data.findOrCreate "key", (data) =>
      called = true
      expect(data).toEqual(new @models.Data("key"))

    waitsFor((-> called), 500)

  it "should findOrCreate a new instance with a key and a value", ->
    called = false
    @models.Data.findOrCreate "aaa", "bbbb", (data) =>
      called = true
      expect(data).toEqual(new @models.Data("aaa", "bbbb"))

    waitsFor((-> called), 500)

  it "should findOrCreate an old instance overriding the value", ->
    called = false
    @models.Data.findOrCreate "aaa", "bbbb", =>
      @models.Data.findOrCreate "aaa", "ccc", =>
        @models.Data.find "aaa", (data) =>
          called = true
          expect(data).toEqual(new @models.Data("aaa", "ccc"))

    waitsFor((-> called), 500)

  it "should emit a change event when findOrCreate does not override the value", ->
    called = false
    @models.Data.findOrCreate "aaa", "bbbb", (oldData) =>

      oldData.on 'change', (data) => called = true

      @models.Data.findOrCreate "aaa", "bbbb"

    waitsFor((-> called), 500)

  it "should provide a global event for registering for new data (fired by findOrCreate)", ->
    called = false
    @models.Data.on "newData", (data) =>
      called = true
      expect(data).toEqual(new @models.Data("hello world", "ggg"))

    waitsFor((-> called), 500)

    @models.Data.findOrCreate("hello world", "ggg")

  it "should provide a global event for registering for new data (fired by save)", ->
    called = false
    @models.Data.on "newData", (data) =>
      called = true
      expect(data).toEqual(new @models.Data("hello world", "ggg"))

    waitsFor((-> called), 500)

    new @models.Data("hello world", "ggg").save()

  it "should provide a find method to detected if an object exists", ->

    called = false
    @models.Data.find "obj", (data, err) =>
      called = true
      expect(err).toEqual("Record not found")

    waitsFor((-> called), 500)

  it "should provide a find method that returns an error if there is no obj", ->

    called = false

    @models.Data.find "obj", (data, err) =>
      called = true
      expect(err).toEqual("Record not found")

    waitsFor((-> called), 500)

  it "should provide a find method that uses a regexp for matching", ->

    createdBob = false
    @models.Data.findOrCreate("hello bob", "aaa", (-> createdBob = true))

    createdMark = false
    @models.Data.findOrCreate("hello mark", "aaa", (-> createdMark = true))

    waitsFor((-> createdBob and createdMark), 500)

    results = []
    runs =>
      @models.Data.find /hello .*/, (data, err) ->
        results.push(data.getKey()) unless err?

    waitsFor((-> results.length == 2), 500)

    runs =>
      expect(results).toContain("hello bob")
      expect(results).toContain("hello mark")


  describe "instance", ->

    beforeEach ->
      @subject = new @models.Data("key", "value")

    it "should get the key", ->
      expect(@subject.getKey()).toEqual("key")

    it "should get the key (dis)", ->
      @subject = new @models.Data("aaa")
      expect(@subject.getKey()).toEqual("aaa")

    it "should get the value", ->
      expect(@subject.getValue()).toEqual("value")

    it "should get the value (dis)", ->
      @subject = new @models.Data("key", "aaa")
      expect(@subject.getValue()).toEqual("aaa")

    it "should set the value", ->
      @subject.setValue("bbb")
      expect(@subject.getValue()).toEqual("bbb")

    it "should set the value (dis)", ->
      @subject.setValue("ccc")
      expect(@subject.getValue()).toEqual("ccc")

    it "should have a save method", ->
      expect(@subject.save).toBeDefined()

    it "should register for change", ->
      called = false

      @subject.on 'change', (data) ->
        called = true
        expect(data.getValue()).toEqual("aaaa")

      waitsFor((-> called), 500)

      @subject.setValue("aaaa")
      @subject.save()

    it "should save and findOrCreate", ->
      called = false
      @subject.save =>
        @models.Data.findOrCreate @subject.getKey(), (data) =>
          called = true
          expect(data).toEqual(@subject)

      waitsFor((-> called), 500)

    it "should save and find", ->
      called = false
      @subject.save =>
        @models.Data.find @subject.getKey(), (data) =>
          called = true
          expect(data).toEqual(@subject)

      waitsFor((-> called), 500)

    it "should not persist the value before save", ->
      called = false
      @subject.save =>
        @subject.setValue("ccc")
        @models.Data.find @subject.getKey(), (data) ->
          called = true
          expect(data.getValue()).toNotEqual("ccc")

      waitsFor((-> called), 500)
