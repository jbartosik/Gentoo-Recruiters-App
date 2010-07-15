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
