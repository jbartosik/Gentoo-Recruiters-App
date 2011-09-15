Given /^text content "([^"]*)" for question "([^"]*)"$/ do |content, question|
  Given "a question \"#{question}\""
  @question.content._?.destroy
  QuestionContentText.create! :question => @question, :content => content
end
