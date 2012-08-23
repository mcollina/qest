expect = require('chai').expect

module.exports = ->
  @World = require("../support/world").World

  @Given /^I subscribe to "([^"]*)"$/, (topic, callback) ->
    @subscribe(topic)
    callback()

  @When /^someone publishes "([^"]*)" to "([^"]*)"$/, (message, topic, callback) ->
    @publish(topic, message)
    callback()

  @Then /^I should have received "([^"]*)" from "([^"]*)"$/, (message, topic, callback) ->
    @getLastMessageFromTopic topic, (packet) ->
      expect(packet.payload).to.equal(message)
      callback()
