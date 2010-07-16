Feature: gentoo-dev-announce
  As a recruiting lead
  I want recruits to send actual emails instead of writing
  So that they learn in practice

  Scenario: Testing gentoo-dev-announce-posting
    Given recruit that should answer gentoo-dev-announce posting question
    And I am logged in as "recruit"
    When I send wrong email announcement
    And I am on show "gentoo-dev-announce posting" question page
    Then I should see "Your answer should have subject (without quotes)"
    Then I should see subject for email "recruit" should send to answer "gentoo-dev-announce posting"

    When I follow "View you answer"
    Then I should see "Email you sent didn't match requirements"

    When I send proper email announcement
    And I am on show "gentoo-dev-announce posting" question page
    Then I should see "Remember to replace @gentoo.org with localhost"

    When I follow "View you answer"
    Then I should see "You sent proper email"

  Scenario: Don't see answer it link on email question page
    Given recruit that should answer gentoo-dev-announce posting question
    And I am logged in as "recruit"
    And I am on show "gentoo-dev-announce posting" question page
    Then I should not see "Answer it"

  Scenario: Protect from forged responses
    Given recruit that should answer gentoo-dev-announce posting question
    And someone sends forged answer
    And I am logged in as "recruit"
    And I am on show "gentoo-dev-announce posting" question page
    Then I should not see "View you answer"

 Scenario: Don't show answering subject to guest
    Given recruit that should answer gentoo-dev-announce posting question
    When I am on show "gentoo-dev-announce posting" question page
    Then I should not see "Your answer should have subject (without quotes)"

  Scenario: Create and edit email question
    Given I am logged in as administrator
    When I follow "Suggestion questions"
    And I follow "New question"
    And I fill in "some question" for "question[title]"
    And I press "Create Question"
    Then I should see "The question was created successfully" within ".flash.notice"

    When I follow "Add email content"
    And I fill in "some question" for "question_content_email[description]"
    And I fill in "To : me" for "question_content_email[req_text]"
    And press "Create Question Content Email"
    Then I should see "The question content email was created successfully" within ".flash.notice"

    When I am on show "some question" question page
    And I follow "content"
    And I fill in "Some question." for "question_content_email[description]"
    And press "Save"
    Then I should see "Changes to the question content email were saved" within ".flash.notice"
