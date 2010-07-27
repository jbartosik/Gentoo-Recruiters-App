Feature: Project Lead Approval
  As a recruiter
  I usually require an approval from a single project lead
  so that I am sure project leads for things like KDE are aware of them

  Scenario: Approval Need Marking
    Given I am logged in as "recruiter" who is "recruiter"
    And user "recruit" who is "recruit"
    When I am on edit "recruit" user page
    Then I should see "+" within ".input-many.project-acceptances"

  Scenario: Project lead go to recruits waiting for acceptance page
    Given pending project acceptance of "recruit" by "some_project_lead"
    When I am logged in as "some_project_lead"
    And I am on the home page
    And I follow "Recruits waiting for your acceptance"
    Then I should be on recruits waiting for your acceptance page

  Scenario: Project lead view recruits waiting for acceptance
    Given pending project acceptance of "recruit1" by "some_project_lead"
    And pending project acceptance of "recruit2" by "some_project_lead"
    When I am logged in as "some_project_lead"
    And I am on recruits waiting for your acceptance page
    Then I should see "recruit1" within ".collection.project.acceptances"

  Scenario: Go to edit project acceptance from view recruits waiting for acceptance page
    Given pending project acceptance of "recruit1" by "some_project_lead"
    When I am logged in as "some_project_lead"
    And I am on recruits waiting for your acceptance page
    And I follow "(edit)"
    Then I should be on project acceptance of "recruit1" by "some_project_lead" edit page

  Scenario: Edit project acceptance
    Given pending project acceptance of "recruit1" by "some_project_lead"
    And I am logged in as "some_project_lead"
    And I am on project acceptance of "recruit1" by "some_project_lead" edit page
    When I check "project_acceptance[accepted]"
    And press "Save"
    Then I should see "Changes to the project acceptance were saved" within ".flash.notice"

  Scenario: Project acceptance on recruit page
    Given accepted project acceptance of "recruit" by "some_project_lead"
    And I am logged in as "recruit"
    When I am on "recruit" user page
    Then I should see "Accepted by some_project_lead" within ".project-acceptances"

  Scenario: Do not have useless index
    When I am on the home page
    Then I should not see "Project Acceptances" within ".navigation.main-nav"

    When I am logged in as "recruit"
    Then I should not see "Project Acceptances" within ".navigation.main-nav"

  Scenario: View my project acceptances on homepage
    Given pending project acceptance of "recruit" by "some project lead"
    And accepted project acceptance of "recruit" by "other project lead"
    When I am logged in as "recruit"
    And I am on the home page
    Then I should see "Waiting for acceptance by some project lead"
    And I should see "Accepted by other project lead"

  Scenario: View my project acceptances in user profile
    Given pending project acceptance of "recruit" by "some project lead"
    And accepted project acceptance of "recruit" by "other project lead"
    When I am logged in as "recruiter" who is "recruiter"
    And I am on the home page
    And I follow "recruit"
    Then I should see "Waiting for acceptance by some project lead"
    And I should see "Accepted by other project lead"

  Scenario: Project lead add project acceptance to recruit
    Given project lead "lead"
    And I am logged in as "lead"
    And user "recruit"
    When I am on show "recruit" user page
    And I press "This recruit needs your acceptance"
    Then I should see "The project acceptance was created successfully" within ".flash.notice"

    When I am on show "recruit" user page
    Then I should see "Waiting for acceptance by lead"
