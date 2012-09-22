expect = require('chai').expect

module.exports = ->
  @World = require("../support/world").World

  @Given /^client "([^"]*)" subscribe to "([^"]*)" via ([^ ]*)$/, (client, topic, protocol, callback) ->
    @getClient protocol, client, (client) -> 
      client.subscribe(topic)
      callback()

  @When /^client "([^"]*)" publishes "([^"]*)" to "([^"]*)" via ([^ ]*)$/, (client, message, topic, protocol, callback) ->
    @getClient protocol, client, (client) -> 
      client.publish topic, message, callback

  @Then /^client "([^"]*)" should have received "([^"]*)" from "([^"]*)" via ([^ ]*)$/, (client, message, topic, protocol, callback) ->
    @getClient protocol, client, (client) ->
      client.getLastMessageFromTopic topic, (lastMessage) ->
        expect(lastMessage).to.equal(message)
        callback()
