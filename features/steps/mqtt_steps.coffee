expect = require('chai').expect

module.exports = ->
  @World = require("../support/world").World

  @Given /^client "([^"]*)" subscribe to "([^"]*)" via MQTT$/, (client, topic, callback) ->
    @getMQTTClient client, (client) -> client.subscribe(topic)
    callback()

  @When /^client "([^"]*)" publishes "([^"]*)" to "([^"]*)" via MQTT$/, (client, message, topic, callback) ->
    @getMQTTClient client, (client) -> client.publish(topic, message)
    callback()

  @Then /^client "([^"]*)" should have received "([^"]*)" from "([^"]*)" via MQTT$/, (client, message, topic, callback) ->
    @getMQTTClient client, (client) ->
      client.getLastMessageFromTopic topic, (packet) ->
        expect(packet.payload).to.equal(message)
        callback()
