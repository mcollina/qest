Feature: MQTT pub/sub
  As a MQTT developer
  In order to communicate with my "things"
  I want to subscribe and publish to topics

  Scenario: Subscribe and publish 2 clients
    Given client "A" subscribe to "foobar" via MQTT
    When client "B" publishes "hello world" to "foobar" via MQTT
    Then client "A" should have received "hello world" from "foobar" via MQTT

  Scenario: Subscribe and publish 1 client
    Given client "A" subscribe to "foobar" via MQTT
    When client "A" publishes "hello world" to "foobar" via MQTT
    Then client "A" should have received "hello world" from "foobar" via MQTT

  Scenario: Always retains the last message
    Given client "B" publishes "aaa" to "foobar" via MQTT
    When client "A" subscribe to "foobar" via MQTT
    Then client "A" should have received "aaa" from "foobar" via MQTT

  Scenario: Subscribe and publish with pattern
    Given client "A" subscribe to "foo/#" via MQTT
    When client "B" publishes "hello world" to "foo/bar" via MQTT
    Then client "A" should have received "hello world" from "foo/bar" via MQTT
