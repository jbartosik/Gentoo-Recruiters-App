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

  Scenario: Go to ready recruits from homepage
    Given a question "some question" in category "some cat"
    And recruit "recruit1" in following categories:
      |some cat|
    And user "recruit1" answered all questions in "some cat"
    And a user "recruit2" who is "recruit"
    And I am logged in as "recruiter" who is "recruiter"
    When I am on the home page
    And I follow "Recruits that answered all questions"
    Then I should be on ready recruits page

  Scenario: Recruit that answered assigned and ungrouped questions is ready
    Given following questions:
      |q1|cat1|grp1|
      |q2|cat1|grp1|
    And following questions:
      |q3|cat1|
      |q4|cat1|
    And user "recruit" is associated with question "q1"
    And answer of "recruit" for question "q1"
    And user "recruit" has category "cat1"
    And user "recruit" answered all questions in "cat1"
    When I am on ready recruits page
    Then I should see "recruit" within ".user .collection"

  Scenario: Recruit that answered didn't answer assigned grouped question isn't ready
    Given following questions:
      |q1|cat1|grp1|
      |q2|cat1|grp1|
    And following questions:
      |q3|cat1|
      |q4|cat1|
    And user "recruit" is associated with question "q1"
    And user "recruit" has category "cat1"
    And user "recruit" answered all questions in "cat1"
    When I am on ready recruits page
    Then I should see "No users to display" within ".empty-collection-message"
