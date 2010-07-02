Given /^text content "([^"]*)" for question "([^"]*)"$/ do |content, question|
  Given "a question \"#{question}\""
  QuestionContentText.create! :question => @question, :content => content
end
