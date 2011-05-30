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
    Then I should not see "Reference"

    When I press "Create Answer"
    Then I should see "The answer was created successfully" within ".flash.notice"

  Scenario: Create and edit text question
    Given I am logged in as administrator
    When I follow "New Question"
    Then I should see "Categories" within ".field-list"
    When I fill in "some question" for "question[title]"
    And I press "Create Question"
    Then I should see "The question was created successfully" within ".flash.notice"

    When I follow "Add text content"
    And I fill in "some question" for "question_content_text[content]"
    And press "Create Question Content Text"
    Then I should see "The question content text was created successfully" within ".flash.notice"

    When I am on show "some question" question page
    And I follow "content"
    And I fill in "Some question." for "question_content_text[content]"
    And press "Save"
    Then I should see "Changes to the question content text were saved" within ".flash.notice"

  Scenario: See question content when creating new answer
    Given text content "some question" for question "question"
    And I am logged in as "recruit"
    When I am on show "question" question page
    And I follow "Answer it!"
    Then I should see "fake" as question content

  Scenario: See question content when editing answer
    Given answer of "recruit" for question "example question"
    And I am logged in as "recruit"
    When I am on answer of "recruit" for question "example question" page
    Then I should see "fake" as question content
