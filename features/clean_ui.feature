Feature: Clean UI
  As application user
  I want UI to be clean
  So it will be easy to use

  Scenario: Don't show project acceptances edit to recruit editing own profile
    Given I am logged in as "recruit"
    When I am on the homepage
    And I follow "view your profile"
    And I follow "Edit User"
    Then I should not see "Project Acceptances"

  Scenario: Properly show questions by category
    Given following questions:
      |question 1|category 1|
      |question 2|category 1|
      |question 3|category 1|
      |question 4|category 2|
      |question 6|category 2|
      |question 7|category 3|
      |question 8|category 3|
      |hidden|category 3|
    And a question "hidden" in group "group"
    When I am logged in as "recruit"
    And I follow "Question Categories"
    And I follow "category 1"
    Then I should see following:
      |question 1|question 2|question 3|
    And I should not see following:
      |question 4|question 6|question 7|question 8|hidden|
    And I should not see /There are \d+/

    When I follow "Question Categories"
    And I follow "category 3"
    Then I should see following:
      |question 7|question 8|
    And I should not see following:
      |question 1|question 2|question 3|question 4|question 6|hidden|
    And I should not see /There are \d+/

  Scenario: Administrator creating new question
    Given I am logged in as administrator
    Then I should not see "Suggest Questions"

    When I follow "New Question"
    Then I should not see "Approved" within ".section.content-body"
    And I should not see "User" within ".section.content-body"
    And I should see "You will add content in next step"

    When I fill in "Question" for "question[title]"
    And I fill in "doc" for "question[documentation]"
    And I press "Create Question"
    Then I should see following:
      |Add text content|Add multiple choice content|Add email content|

  Scenario: Don't show questions with no content
    Given a question "question 0" in category "category"
    And question "question 0" has no content
    When I am logged in as "recruit"
    And I follow "Question Categories"
    And I follow "category"
    Then I should see "No questions to display"

    Given following questions:
      |question 1|category|
      |question 2|category|
      |question 3|category|
    Given email question content for "question 1"
    Given text content "something" for question "question 2"
    Given a multiple choice content "multi choice" for "question 3"
    When I follow "Question Categories"
    And I follow "category"
    Then I should see "No questions to display"
    Then I should see following:
      |question 1|question 3|question 3|
    And I should not see "question 0"

  Scenario: I should not see double Answer it
    Given a question "question"
    When I am logged in as "recruit"
    And I am on show "question" question page
    Then I should see "Answer it"
    And I should not see /Answer it(?m:.*)Answer it/

  Scenario: I should not see Answer it as Guest
    Given a question "question"
    When I am on show "question" question page
    Then I should not see "Answer it"

  Scenario: I should not see Answer it when I answered question
    Given a question "question"
    And "recruit" answered question "question"
    When I am logged in as "recruit"
    When I am on show "question" question page
    Then I should not see "Answer it"

  Scenario: Instructions when creating new email question content
    Given I am logged in as administrator
    And a question "question"
    And I am on new email question content for "question" page
    Then I should see "Enter one requirement per line."
    And I should see "Each requirement should be 'Field : regexp to match' (including spaces around colon)."
    And I should see "If you want to use colon in field and regexp then escape it with backslash."

  Scenario: Don't show '(Not Available)' on the answer page
    Given a question "question"
    And "recruit" answered question "question"
    When I am logged in as "recruit"
    And I am on answer of "recruit" for question "question" page
    Then I should not see "(Not Available)"

  Scenario: Show message telling how to start mentoring recruit on user edit page
    Given I am logged in as "mentor" who is "mentor"
    And user "recruit" who is "recruit"
    Then I should see instructions on becoming mentor for "recruit"

  Scenario: Show message telling how to start mentoring recruit on user edit page
    Given user "recruit" who is "recruit"
    Then I should see explanation that I can't become mentor for "recruit"

    Given I am logged in as "recruit2" who is "recruit"
    Then I should see explanation that I can't become mentor for "recruit"

    When I follow "Log out"
    Given I am logged in as "mentor" who is "mentor"
    And user "mentor2" is mentor of "recruit"
    Then I should see explanation that I can't become mentor for "recruit"

  Scenario: Don't show "recruit this recruit" button on non-recruit pages
    Given I am logged in as "recruiter" who is "recruiter"
    And user "recruiter2" who is "recruiter"
    When I am on show "recruiter2" user page
    Then I should not see tag <input class="button submit-button" type="submit" value="Start mentoring this recruit">

  Scenario: Don't show wrong question count on unanswered questions page
    Given I am logged in as "recruit" who is "recruit"
    And following questions:
      |q1|cat1|
      |q2|cat1|
    And user "recruit" has category "cat1"
    And answer of "recruit" for question "q1"

    When I am on unanswered questions page
    Then I should not see /There are \d+/

  Scenario: Let users know that they should use markdown
    Given I am logged in as "recruit" who is "recruit"
    And a question "question"
    When I am on answer "question" question page
    Then I should see "You can use markdown in your answer." as hint
