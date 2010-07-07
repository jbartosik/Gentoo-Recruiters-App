Feature: Viewing question listings
  As recruit
  I want to see listings of questions
  To answer them

  Scenario: View listing of all questions I should answer
    Given I am logged in as recruit with some answered and unanswered questions
    When I am on all my questions page
    Then I should see following:
    |q1|q3|q4|
    And I should not see "q2"

  Scenario: View listing of all questions I answered
    Given I am logged in as recruit with some answered and unanswered questions
    When I am on my answered questions page
    Then I should see "q3"
    And I should not see following:
      |q1|q2|q4|

  Scenario: View listing of all questions I didn't answer yet
    Given I am logged in as recruit with some answered and unanswered questions
    When I am on my unanswered questions page
    Then I should see following:
      |q1|q4|
    And I should not see following:
      |q2|q3|
