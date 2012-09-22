Feature: Home page
  As a prospect of QEST
  I want to get the home page

  Scenario: QEST name
    When I visit "/"
    Then I should see "QEST"

  Scenario: QEST title
    When I visit "/"
    Then I should see the title "QEST"

