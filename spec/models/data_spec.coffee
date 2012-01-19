
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

    it "should save and find", ->
      called = false
      @subject.save =>
        @models.Data.findOrCreate @subject.getKey(), (data) =>
          called = true
          expect(data).toEqual(@subject)

      waitsFor((-> called), 500)

    it "should not persist the value before save", ->
      called = false
      @subject.save =>
        @subject.setValue("ccc")
        @models.Data.findOrCreate @subject.getKey(), (data) ->
          called = true
          expect(data.getValue()).toNotEqual("ccc")

      waitsFor((-> called), 500)
