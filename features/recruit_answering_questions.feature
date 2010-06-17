Feature: Recruit answering questions
  As a recruit I want to answer questions

  Scenario: Go to all unanswered questions listing from homepage
    Given recruit "recruit" in following categories:
      |cat1|
      |cat2|
    And I am logged in as "recruit" who is "recruit"
    When I am on the home page
    And I follow "You didn't answer yet but you should."
    Then I should be on unanswered questions page


  Scenario: See all unanswered questions listing on unanswered questions page
    Given recruit "recruit" in following categories:
      |cat1|
      |cat2|
    And following questions:
      | q1 | cat1 |
      | q2 | cat1 |
      | q3 | cat2 |
      | q4 | cat2 |
    And answer of "recruit" for question "q4"
    And I am logged in as "recruit" who is "recruit"
    When I am on the unanswered questions page
    Then I should see following:
      | q1 | q2 | q3 |
    And I should not see "q4"
