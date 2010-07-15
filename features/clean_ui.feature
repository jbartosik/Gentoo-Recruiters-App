Feature: Clean UI
  As application user
  I want UI to be clean
  So it will be easy to use

  Scenario: Don't show project acceptances edit to recruit editing own profile
    Given I am logged in as "recruit"
    When I am on the homepage
    And I follow "See your profile"
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
