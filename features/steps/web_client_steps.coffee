expect = require('chai').expect

module.exports = () ->
  @World = require("../support/world").World

  this.Given /^I open the topic "([^"]*)"$/, (topic, callback) ->
    @browser.visit "/", =>
      @browser.fill "topic", topic, =>
        @browser.pressButton "GO!", callback
