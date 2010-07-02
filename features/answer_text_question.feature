Feature: Answering text question
  As recruit
  I should be able to answer text question
  So my knowledge can be evaluated properly

  Scenario: Answer text question
    Given I am logged in as "recruit"
    And a question "question" in category "category"
    And text content "some question" for question "question"
    When I am on show "question" question page
    And I follow "Answer it!"
    And fill in "answer[content]" with "my answer"
    And I press "Create Answer"
    Then I should see "The answer was created successfully" within ".flash.notice"
