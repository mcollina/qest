Feature: HTTP pub/sub
  As a web developer
  In order to communicate with my "things"
  I want to subscribe and publish to topics

  Scenario: GETting and PUTting
    When client "B" publishes "hello world" to "foobar" via HTTP
    Then client "A" should have received "hello world" from "foobar" via HTTP

  Scenario: GETting and PUTting JSON
    When client "B" publishes "[ 42, 43 ]" to "foobar" via HTTP_JSON
    Then client "A" should have received "[42,43]" from "foobar" via HTTP_JSON

  Scenario: GETting and PUTting plain text
    When client "B" publishes "hello world" to "foobar" via HTTP_TXT
    Then client "A" should have received "hello world" from "foobar" via HTTP_TXT

  Scenario: PUTting JSON and reading from MQTT
    Given client "A" subscribe to "foobar" via MQTT
    When client "B" publishes "[ 42, 43 ]" to "foobar" via HTTP_JSON
    Then client "A" should have received "[42,43]" from "foobar" via MQTT
