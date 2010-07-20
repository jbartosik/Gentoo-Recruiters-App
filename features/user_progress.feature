Feature: Recruits progress
  As recruiter
  I want to be able to see recruits progress
  In order to know how they are progressing

  Scenario: View recruits progress on show page
    Given following questions:
      |question 1|category 1|
      |question 2|category 1|
      |question 3|category 2|
    And recruit "recruit" in following categories:
      |category 1|category 2|
    And user "recruit" answered all questions in "category 1"
    And I am logged in as "recruiter" who is "recruiter"
    When I am on the homepage
    And I follow "recruit"
    Then I should see "Answered 2 of 3 questions."

  Scenario: View list of users questions
    Given following questions:
      |question 1|category 1|
      |question 2|category 1|
      |question 3|category 2|
    And recruit "recruit" in following categories:
      |category 1|category 2|
    And user "recruit" answered all questions in "category 1"
    And I am logged in as "recruiter" who is "recruiter"
    When I am on the homepage
    And I follow "recruit"
    And I follow "Questions user should answer"
    Then I should see following:
      |question 1 answered|question 2 answered|question 3|

