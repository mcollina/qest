
module.exports = (app) ->
  io = app.io
  Data = app.models.Data

  app.get (/^\/topics\/(.+)$/), (req, res) ->
    topic = req.params[0]

    topics = req.session.topics || []
    index = topics.indexOf(topic)
    
    if index >= 0
      topics = [].concat(topics.splice(0, index), topics.splice(index + 1, req.session.topics.length))

    topics.push(topic)
    topics.pull() if topics.length > 5

    req.session.topics = topics

    Data.find topic, (err, data) ->

      type = req.accepts(['txt', 'json', 'html'])

      if type == "html"
        res.render 'topic.hbs', topic: topic
      else if err?
        res.send 404
      else if type == 'json'
        res.contentType('json')
        try
          res.json data.value
        catch e
          res.json "" + data.value
      else if type == 'txt'
        res.send data.value
      else
        res.send 406

  app.put /^\/topics\/(.+)$/, (req, res) ->
    topic = req.params[0]
    if req.is("json")
      payload = req.body
    else
      payload = req.body.payload
    Data.findOrCreate topic, payload
    res.send 204
