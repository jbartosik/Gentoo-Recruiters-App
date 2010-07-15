Feature: Multiple Choice
  As a recruiting lead
  I want the webapp to support multiple choice questions
  So that recruits get instant feedback

  Scenario: Creating Multiple Choice Questions
   Given I am logged in as administrator
   And a question "question"
   And question "question" has no content
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

  Scenario: No Feedback with some unanswered multi choice
    Given I am logged in as recruit with multiple choice questions to answer
    Given following options for "question 1":
      |correct 1|correct 2|
    When I am on the home page
    Then I should not see "You answered all multiple choice questions, but some of them wrong"
    And I should not see "You answered all multiple choice questions, correct"

  Scenario: Feedback on wrong answers
    Given I am logged in as recruit with multiple choice questions to answer
    And "recruit" chose following for "question 1":
      |correct 1|correct 2|
    And "recruit" chose following for "question 2":
      |correct 4|incorrect 1|
    When I am on the home page
    Then I should see "You answered all multiple choice questions, but some of them wrong."

  Scenario: Feedback on good answers
    Given I am logged in as recruit with multiple choice questions to answer
    And "recruit" chose following for "question 1":
      |correct 1|correct 2|
    And "recruit" chose following for "question 2":
      |correct 4|
    When I am on the home page
    Then I should see "You answered all multiple choice questions, correctly."

  Scenario: Edit existing questions
    Given I am logged in as administrator
    And recruit with multiple choice questions to answer
    When I am on show "question 1" question page
    And I follow "content"
    Then I should not see "Question" within "form"

    When I fill in "question_content_multiple_choice[options][2][content]" with "correct 3 - a bit more specific"
    And press "Save"
    Then I should see "Changes to the question content multiple choice were saved" within ".flash.notice"

    When I am on show "question 1" question page
    Then I should see "correct 3 - a bit more specific"
