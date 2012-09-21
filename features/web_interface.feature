Feature: Web Interface
  As QEST user
  I want to go to one of my topics

  Scenario: go to topic page
    When I open the topic "mytopic"
    Then I should see "mytopic"

  Scenario: see the published value of a topic
    Given client "A" publishes "hello world" to "mytopic" via HTTP
    When I open the topic "mytopic"
    Then I should see "hello world" in the textarea

  Scenario: receives the updates from a topic
    Given I open the topic "mytopic"
    When client "A" publishes "hello world" to "mytopic" via HTTP
    Then I should see "hello world" in the textarea

  Scenario: send the update of a topic from the web to the devices
    Given client "A" subscribe to "mytopic" via MQTT
    And I open the topic "mytopic"
    When I change the payload to "hello world"
    Then client "A" should have received "hello world" from "mytopic" via MQTT
