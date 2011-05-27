Feature: Developer role
  In order to manage recruits
  I want recruits who became developers
  But can't be mentors yet
  To have developer role

  Scenario: Make user a developer
    Given I am logged in as "recruiter" who is "recruiter"
    And user "recruit" who is "recruit"
    When I am on edit "recruit" user page
    And I select "Developer" from "user[role]"
    And I press "Save"
    Then I should see "developer" as a role
