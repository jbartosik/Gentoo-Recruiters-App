Given /^(?:|a )comment "([^\"]*)" of "([^\"]*)" for answer of "([^\"]*)" for question "([^\"]*)"$/ do |comment, mentor, user, question|
  Given "user \"#{mentor}\" is mentor of \"#{user}\""
  Given "answer of \"#{user}\" for question \"#{question}\""
  Comment.create! :owner => @mentor, :answer => @answer, :content => comment
end
