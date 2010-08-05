Feature: OpenID
  As an user
  I don't want to have to manage passwords

  Scenario: Use OpenID to register and login
    Given I am on the homepage
    And openid is always succesfull
    When I follow "Sign up"
    And I follow "sign up using OpenID"
    And I fill in "login" with "https://example.com/id"
    And I press "Log in"

    # I should be on edit form for my user
    When I fill in "user[name]" with "Example name"
    And I fill in "user[email_address]" with "addr@example.com"
    And I press "Save"
    Then I should see "Changes to your account were saved" within ".flash.notice"

    When I follow "Log out"
    And I follow "Log in"
    And I follow "log in using openID"
    And I fill in "login" with "https://example.com/id"
    And I press "Log in"
    Then I should see "Welcome, Example name"

  Scenario: User with invalid accounts can only edit their accounts
    Given I am on the homepage
    And openid is always succesfull
    When I follow "Sign up"
    And I follow "sign up using OpenID"
    And I fill in "login" with "https://example.com/id"
    And I press "Log in"

    When I am on the homepage
    Then I should be on edit "" user page
    And I should see "Please set data for your account"
