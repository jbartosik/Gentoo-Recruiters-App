Feature: Evaluate documentation
  As recruiter
  I want recruits to give feedback on documentation
  So I'll know what should be improved

  Scenario: Recruit evaluate question documentation
    Given I am logged in as "recruit"
    And a question "question"
    When I am on show "question" question page
    And I follow "Answer it"
    And I select "Documentation Ok" from "answer[feedback]"
    And I select "Could Not Find Documentation" from "answer[feedback]"
    And I select "Documentation Insufficient" from "answer[feedback]"
    And I fill in "Some answer" for "answer[content]"
    And I press "Create Answer"
    Then I should see "The answer was created successfully" within ".flash.notice"

    Given a multiple choice content "Choose some if you can" for "question 2"
    When I am on show "question 2" question page
    And I follow "Answer it"
    And I select "Documentation Ok" from "multiple_choice_answer[feedback]"
    And I press "Create Answer"
    Then I should see "The multiple choice answer was created successfully" within ".flash.notice"
