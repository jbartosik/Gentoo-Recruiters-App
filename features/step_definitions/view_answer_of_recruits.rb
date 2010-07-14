Given /^I am logged in as mentor with two recruits who answered some questions$/ do
    Given 'I am logged in as "mentor" who is "mentor"'
    And 'user "mentor" is mentor of "recruit1"'
    And 'user "mentor" is mentor of "recruit2"'
    And 'following questions:', table(%{
      |q1|cat1|
      |q2|cat1|
      |q3|cat2|
      |q4|cat2|
    })
    And 'user "recruit1" has category "cat1"'
    And 'user "recruit1" has category "cat2"'
    And 'user "recruit2" has category "cat1"'
    And 'user "recruit2" has category "cat2"'
    And 'user "recruit1" answered all questions in "cat1"'
    And 'user "recruit2" answered all questions in "cat2"'
end
