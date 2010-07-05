Feature: Description of question groups
  As Guest
  I want to see description of each question group
  So I will know how to prepare to answer questions

  Scenario: Go to question categories listing page
    Given I am on the home page
    When I follow "Question Groups" within ".navigation.main-nav"
    Then I should be on question groups index page

  Scenario: View question groups listings in by categories
    Given following questions:
      |q1|cat1|grp1|
      |q2|cat1|grp2|
      |q3|cat2|grp3|
    And I am on question groups index page
    And I should see following:
      |grp1|grp2|grp3|
    When I select "cat1" from "id[]"
    And press "view in this category"
    Then I should see following:
      |grp1|grp2|
    And I should not see "grp3"

  Scenario: View description of question group
    Given a question "question" in category "cat"
    And a question "question" in group "group"
    And I am on question groups index page
    When I follow "group"
    Then I should see "Description of group"
