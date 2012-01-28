
module.exports = (app) ->
  app.get '/', (req, res) ->
    req.session.topics ||= []
    res.render 'home.hbs', topics: req.session.topics
