Feature: Returning developer
  As the recruiting lead
  I want returning developers to answer all questions added since they initially answered their quizzes
  so that their knowledge is up to date

   Scenario: Recruiter going to mentor edit page
    Given user "mentor" who is "mentor"
    And I am logged in as "recruiter" who is "recruiter"
    And I am on "mentor" user page
    When I follow "Edit User"
    Then I should be on edit "mentor" user page

  Scenario: Recruiter change role from mentor to recruit
    Given user "ex-mentor" who is "mentor"
    And I am logged in as "recruiter" who is "recruiter"
    And I am on edit "ex-mentor" user page
    When I select "Recruit" from "user[role]"
    And I press "Save"
    Then I should be on "ex-mentor" user page
    And I should see "recruit" within ".role-view"
