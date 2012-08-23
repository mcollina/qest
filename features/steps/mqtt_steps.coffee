expect = require('chai').expect

module.exports = ->
  @World = require("../support/world").World

  @Given /^I subscribe to "([^"]*)" via MQTT$/, (topic, callback) ->
    @mqttSubscribe(topic)
    callback()

  @When /^someone publishes "([^"]*)" to "([^"]*)" via MQTT$/, (message, topic, callback) ->
    @mqttPublish(topic, message)
    callback()

  @Then /^I should have received "([^"]*)" from "([^"]*)" via MQTT$/, (message, topic, callback) ->
    @mqttGetLastMessageFromTopic topic, (packet) ->
      expect(packet.payload).to.equal(message)
      callback()
