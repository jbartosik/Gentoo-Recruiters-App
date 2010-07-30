Feature: Reference answers
  As recruiter
  I want to be able to record and edit reference answers
  So answers of recruits can be compared against them
  And Recruits can get instant feedback on their answers for multiple choice questions

  Scenario: Record reference answer for text question and edit it as different recruiter
    Given I am logged in as "recruiter1" who is "recruiter"
    And text content "some question?" for question "question"
    When I am on show "question" question page
    And I follow "Answer it"
    And I check "answer[reference]"
    And I fill in "some answer" for "answer[content]"
    And I press "Create Answer"
    Then I should see "The answer was created successfully" within ".flash.notice"

    When I follow "Log out"
    And I am logged in as "other-recruiter" who is "recruiter"
    And I am on show "question" question page
    And I follow "View reference answer"
    And I follow "(Edit)"
    And I fill in "some other answer" for "answer[content]"
    And I press "Save"
    Then I should see "Changes to the answer were saved" within ".flash.notice"

  Scenario: Record reference answer for multiple choice question and edit it as different recruiter
    Given I am logged in as "recruiter1" who is "recruiter"
    And a multiple choice content "question" for "question"
    And following options for "question":
      |Opt 1|Opt 2|Opt 3|
    When I am on show "question" question page
    And I follow "Answer it"
    And I check "multiple_choice_answer[reference]"
    And I check "Opt 1"
    And I press "Create Answer"
    Then I should see "The multiple choice answer was created successfully" within ".flash.notice"

    When I follow "Log out"
    And I am logged in as "other-recruiter" who is "recruiter"
    And I am on show "question" question page
    And I follow "View reference answer"
    And I follow "(Edit)"
    And I check "Opt 2"
    And I press "Save"
    Then I should see "Changes to the multiple choice answer were saved" within ".flash.notice"
