Feature: Viewing answers of recruits
  As recruiter or mentor
  I want to view answer of recruits
  So I can evaluate their knowledge

  Scenario: Mentor viewing all answers of recruit [s]he is mentoring
    Given I am logged in as mentor with two recruits who answered some questions
    When I am on the homepage
    And I follow "answers"
    Then I should see following:
      |Answer of recruit1 for q1|
      |Answer of recruit1 for q2|
      |Answer of recruit2 for q3|
      |Answer of recruit2 for q4|

  Scenario: Mentor viewing answers of recruit [s]he is mentoring by category
    Given I am logged in as mentor with two recruits who answered some questions
    When I am on the homepage
    And I follow "cat1"
    Then I should see following:
      |Answer of recruit1 for q1|
      |Answer of recruit1 for q2|
    And I should not see following:
      |Answer of recruit2 for q3|
      |Answer of recruit2 for q4|

  Scenario: Mentor viewing answer of recruit [s]he is mentoring
    Given I am logged in as mentor with two recruits who answered some questions
    When I am on the homepage
    And I follow "cat1"
    And I follow "Answer of recruit1 for q1"
    Then I should be on answer of "recruit1" for question "q1" page
    And I should see "fake" within ".view.answer-content"
