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
