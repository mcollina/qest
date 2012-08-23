Feature: HTTP pub/sub
  As a web developer
  In order to communicate with my "things"
  I want to subscribe and publish to topics

  Scenario: GETting and PUTting
    When client "B" publishes "hello world" to "foobar" via HTTP
    Then client "A" should have received "hello world" from "foobar" via HTTP
