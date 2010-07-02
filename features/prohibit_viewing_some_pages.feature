Feature: Prohibit seeing some pages
  As recruiting lead
  I want to prohibit users from seeing some pages
  So they don't access information they are not supposed to

  Scenario: Hide grouped questions from guest
    Given a question "question" in group "group"
    Then I should be prohibited to visit show "question" question page
