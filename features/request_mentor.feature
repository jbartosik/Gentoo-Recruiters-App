Feature: Request Mentor
  As a recruit
  I want to use the webapp to apply for a mentor
  so that I will get assigned one

  Scenario: Listing contributions
    Given I am logged in as "recruit"
    And I am on edit "recruit" user page
    When I fill in "user[contributions]" with "some contributions"
    And I press "Save"
    Then I should see "Changes to your account were saved" within ".flash.notice"
    And I should see "some contributions" within ".contributions-tag.view.user-contributions"

  Scenario: Unassigned Recruit listing for Mentors
    Given I am logged in as "mentor" who is "mentor"
    And user "recruit1" who is "recruit"
    And user "recruit2" who is "recruit"
    And user "mentor" is mentor of "recruit3"
    When I am on the home page
    And I follow "See mentorless recruits"
    Then I should see "recruit1" within ".collection.users"
    And I should see "recruit1" within ".collection.users"
    But I should not see "recruit3" within ".collection.users"

  Scenario: Become mentor of mentorless recruit then stop mentoring
    Given I am logged in as "mentor" who is "mentor"
    And user "recruit" who is "recruit"
    And I am on show "recruit" user page
    When I press "Start mentoring this recruit"
    Then I should see "Changes to the user were saved" within ".flash.notice"
    And I should see "Mentor mentor"

    And I am on show "recruit" user page
    When I press "Stop mentoring this recruit"
    Then I should see "Changes to the user were saved" within ".flash.notice"
    And I should see "Mentor (Not Available) "
