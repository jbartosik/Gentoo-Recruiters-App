Feature: Multiple Choice
  As a recruiting lead
  I want the webapp to support multiple choice questions
  So that recruits get instant feedback

  Scenario: Creating Multiple Choice Questions
   Given I am logged in as administrator
   And a question "question"
   And I am on show "question" question page
   When I follow "Add multiple choice content"
   And fill in "question_content_multiple_choice[content]" with "Some question?"
   And fill in "question_content_multiple_choice[options]" with "Option 2"
   And press "Create Question Content Multiple Choice"
   Then I should see "The question content multiple choice was created successfully" within ".flash.notice"

  Scenario: Answer multiple choice Question
    Given following options for "question":
      |Option 1|Option 2|Option 3|
    And I am logged in as "recruit"
    When I am on show "question" question page
    And follow "Answer it!"
    Then I should see following:
      |Option 1|Option 2|Option 3|
    When I check "Option 2"
    And press "Create Answer"
    Then I should see "The multiple choice answer was created successfully" within ".flash.notice"
    When I am on answer of "recruit" for question "question" page
    Then the "Option 2" checkbox should be checked
    And the "Option 1" checkbox should not be checked
    And the "Option 3" checkbox should not be checked
