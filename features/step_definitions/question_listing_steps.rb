Given /^a recruit with some answered and unanswered questions$/ do
  Given "following questions:", table(%{
  |q1|cat1|grp1|
  |q2|cat1|grp1|
  })
  Given "following questions:", table(%{
  |q3|cat1|
  |q4|cat1|
  })

  Given "user \"recruit\" is associated with question \"q1\""
  Given "answer of \"recruit\" for question \"q3\""
  And "user \"recruit\" has category \"cat1\""
  And "user \"recruit\" has category \"cat2\""
end

Given /^I am logged in as recruit with some answered and unanswered questions$/ do
  Given "I am logged in as \"recruit\""
  Given "a recruit with some answered and unanswered questions"
end
