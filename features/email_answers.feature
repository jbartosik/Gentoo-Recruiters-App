Feature: gentoo-dev-announce
  As a recruiting lead
  I want recruits to send actual emails instead of writing
  So that they learn in practice

  Scenario: Testing gentoo-dev-announce-posting
    Given recruit that should answer gentoo-dev-announce posting question
    And I am logged in as "recruit"
    When I send wrong email announcement
    And I am on show "gentoo-dev-announce posting" question page
    And I follow "View you answer"
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
