Feature: Clean UI
  As application user
  I want UI to be clean
  So it will be easy to use

  Scenario: Don't show project acceptances edit to recruit editing own profile
    Given I am logged in as "recruit"
    When I am on the homepage
    And I follow "view your profile"
    And I follow "Edit User"
    Then I should not see "Project Acceptances"

  Scenario: Properly show questions by category
    Given following questions:
      |question 1|category 1|
      |question 2|category 1|
      |question 3|category 1|
      |question 4|category 2|
      |question 6|category 2|
      |question 7|category 3|
      |question 8|category 3|
      |hidden|category 3|
    And a question "hidden" in group "group"
    When I am logged in as "recruit"
    And I follow "Question Categories"
    And I follow "category 1"
    Then I should see following:
      |question 1|question 2|question 3|
    And I should not see following:
      |question 4|question 6|question 7|question 8|hidden|
    And I should not see /There are \d+/

    When I follow "Question Categories"
    And I follow "category 3"
    Then I should see following:
      |question 7|question 8|
    And I should not see following:
      |question 1|question 2|question 3|question 4|question 6|hidden|
    And I should not see /There are \d+/

  Scenario: Administrator creating new question
    Given I am logged in as administrator
    When I follow "Suggestion Questions"
    And I follow "New Question"
    Then I should not see "Approved" within ".section.content-body"
    And I should not see "User" within ".section.content-body"
    And I should see "You will add content in next step"

    When I fill in "Question" for "question[title]"
    And I fill in "doc" for "question[documentation]"
    And I press "Create Question"
    Then I should see following:
      |Add text content|Add multiple choice content|

  Scenario: Don't show questions with no content
    Given a question "question" in category "category"
    And question "question" has no content
    When I am logged in as "recruit"
    And I follow "Question Categories"
    And I follow "category"
    Then I should see "No questions to display"

  Scenario: I should not see double Answer it
    Given a question "question"
    When I am logged in as "recruit"
    And I am on show "question" question page
    Then I should see "Answer it"
    And I should not see /Answer it(?m:.*)Answer it/

  Scenario: I should not see Answer it as Guest
    Given a question "question"
    When I am on show "question" question page
    Then I should not see "Answer it"

  Scenario: I should not see Answer it when I answered question
    Given a question "question"
    And "recruit" answered question "question"
    When I am logged in as "recruit"
    When I am on show "question" question page
    Then I should not see "Answer it"
