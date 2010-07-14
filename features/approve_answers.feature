Feature: Approving recruit answers
  As mentor
  I want to be able to approve and disapprove answers of my recruits
  So they will know if they should work more on them

  Scenario: Mentor approves and then disapproves text answer of his/her recruit
    Given I am logged in as mentor with two recruits who answered some questions
    When I am on the homepage
    And I follow "answers"
    And I follow "Answer of recruit1 for q1"
    Then I should see "Not approved"

    When I follow "(Edit)"
    And I check "answer[approved]"
    And I press "Save"
    Then I should see "Changes to the answer were saved" within ".flash.notice"

    When I am on the homepage
    And I follow "answers"
    And I follow "Answer of recruit1 for q1"
    Then I should see "Approved"

    When I follow "(Edit)"
    And I uncheck "answer[approved]"
    And I press "Save"
    Then I should see "Changes to the answer were saved" within ".flash.notice"
    Then I should see "Not approved"
