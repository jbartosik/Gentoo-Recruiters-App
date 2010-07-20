Feature: Mentor comments for recruit answers
  As a mentor
  I want to be able to comment answers of my recruits
  so they can improve their answers

  Scenario: Go to add comment page from answer page
    Given user "mentor" is mentor of "recruit"
    And answer of "recruit" for question "example question"
    And I am logged in as "mentor"
    And I am on answer of "recruit" for question "example question" page
    When I follow "Comment this answer"
    Then I should be on new comment for answer of "recruit" for question "example question"

  Scenario: Add comment
    Given user "mentor" is mentor of "recruit"
    And answer of "recruit" for question "example question"
    And I am logged in as "mentor"
    And I am on new comment for answer of "recruit" for question "example question"
    When I fill in "comment_content" with "some comment"
    And press "Create Comment"
    Then I should be on newest comment page
    And I should see "some comment"

  Scenario: View comment on answer page
    Given a comment "example comment" of "mentor" for answer of "recruit" for question "example question"
    And I am logged in as "recruit"
    And I am on answer of "recruit" for question "example question" page
    Then I should see "mentor:"
    And I should see "example comment"
