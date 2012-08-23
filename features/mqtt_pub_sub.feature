Feature: MQTT pub/sub
  As a MQTT developer
  In order to communicate with my "things"
  I want to subscribe and publish to topics

  @mqtt @wip
  Scenario: Subscribe and publish
    Given I subscribe to "foobar"
    When someone publishes "hello world" to "foobar"
    Then I should have received "hello world" from "foobar"
