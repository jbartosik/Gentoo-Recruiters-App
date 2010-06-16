Feature: Viewing recruits who answered all questions
  As a recruiter
  I want to be able to see recruits with all questions answered and approved by mentors
  so that I can start the review process with them

  Scenario: View Listing
    Given a question "some question" in category "some cat"
    And recruit "recruit1" in following categories:
      |some cat|
    And user "recruit1" answered all questions in "some cat"
    And a user "recruit2" who is "recruit"
    When I am on ready recruits page
    Then I should see "recruit1" within ".user .collection"
    And I should see "recruit2" within ".user .collection"

