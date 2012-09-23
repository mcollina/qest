expect = require('chai').expect

module.exports = () ->

  this.Given /^I open the topic "([^"]*)"$/, (topic, callback) ->
    @browser.visit "/", =>
      @browser.fill "topic", topic, =>
        @browser.pressButton "GO!", callback


  this.When /^I change the payload to "([^"]*)"$/, (payload, callback) ->
    @browser.pressButton "Edit", =>
      @browser.fill "payload", payload, =>
        @browser.pressButton "Update", callback
