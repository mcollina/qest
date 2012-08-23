expect = require('chai').expect

module.exports = () ->
  @World = require("../support/world").World

  @When /^I visit "([^"]*)"$/, (url, callback) ->
    @browser.visit url, callback

  @Then /^I should see "([^"]*)"$/, (text, callback) ->
    expect(@browser.text("body")).to.include(text)
    callback()

  @Then /^I should see the title "([^"]*)"$/, (text, callback) ->
    expect(@browser.text("title")).to.equal(text)
    callback()

  @When /^client "([^"]*)" publishes "([^"]*)" to "([^"]*)" via HTTP$/, (client, message, topic, callback) ->
    @getHTTPClient client, (client) ->
      client.publish(topic, message, callback)

  @Then /^client "([^"]*)" should see "([^"]*)" in "([^"]*)" via HTTP$/, (client, message, topic, callback) ->
    @getHTTPClient client, (client) ->
      client.getLastMessageFromTopic topic, (lastMessage) ->
        expect(lastMessage).to.equal(message)
        callback()
