Feature: Documentation feedback
  As recruiter I want to see recruits feedback on questions documentation
  But I don't want non-recruiters to see it

  Scenario: When there is feedback see it as recruiter but not as recruit
    Given I am logged in as "recruit"
    And a question "question"
    When I am on show "question" question page
    And I follow "Answer it!"
    And I select "Documentation Ok" from "answer[feedback]"
    And press "Create Answer"

    When I am on show "question" question page
    Then I should see no pie chart with feedback

    When I follow "Log out"
    And I am logged in as "recruiter" who is "recruiter"
    When I am on show "question" question page
    Then I should see pie chart with feedback for "question"

  Scenario: Don't see recruits feedback as recruiter when there is none
    Given I am logged in as "recruiter" who is "recruiter"
    And a question "question"
    When I am on show "question" question page
    Then I should see no pie chart with feedback
