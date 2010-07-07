Feature: Suggest Questions
  As a recruiters lead
  I want everyone logged in to be able to suggest new questions
  So that our question battery improves easily

  Scenario: Suggest Question
    Given I am logged in as "recruit"
    And I am on the home page
    When I follow "Suggestion Questions" within ".navigation.main-nav"
    And I follow "New question"
    And I fill in "question[content]" with "Some question"
    And I fill in "question[title]" with "Some question"
    And press "Create Question"
    And I should see "The question was created successfully" within ".flash.notice"
    And I should see "Not approved."

  Scenario: Approving Questions
    Given "recruit" suggested question "question"
    And a question "some question"
    And I am logged in as administrator
    When I follow "Approve Questions" within ".navigation.main-nav"
    Then I should see "question" within ".collection.questions"
    And I should not see "some question" within ".collection.questions"
    When I follow "question"
    And follow "(Edit)"
    And check "question[approved]"
    And press "Save"
    Then I should see "Changes to the question were saved" within ".flash.notice"
    And I should not see "Not approved."

  Scenario: No questions to approve
    Given I am logged in as administrator
    Then I should not see "Approve Questions"
