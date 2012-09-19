expect = require('chai').expect

module.exports = () ->
  @World = require("../support/world").World

  @When /^I visit "([^"]*)"$/, (url, callback) ->
    @browser.visit url, callback

  @Then /^I should see "([^"]*)"$/, (text, callback) ->
    expect(@browser.text("body")).to.include(text)
    callback()

  @Then /^I should see "([^"]*)" in the textarea$/, (text, callback) ->
    doneWaiting = =>
      expect(@browser.field("textarea").value).to.include(text)
      callback()

    if @browser.field("textarea").value.indexOf(text) != -1
      callback()
    else
      setTimeout(doneWaiting, 50)


  @Then /^I should see the title "([^"]*)"$/, (text, callback) ->
    expect(@browser.text("title")).to.equal(text)
    callback()
