Feature: MQTT pub/sub
  As a MQTT developer
  In order to communicate with my "things"
  I want to subscribe and publish to topics

  @mqtt
  Scenario: Subscribe and publish
    Given I subscribe to "foobar" via MQTT
    When someone publishes "hello world" to "foobar" via MQTT
    Then I should have received "hello world" from "foobar" via MQTT
