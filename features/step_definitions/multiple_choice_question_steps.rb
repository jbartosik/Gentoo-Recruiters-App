Given /^a multiple choice content "([^\"]*)"$/ do |content|
  @content = QuestionContentMultipleChoice.find_by_content(content)
  if @content.nil?
    @content = QuestionContentMultipleChoice.create! :content => content
  end
end

Given /^a multiple choice content "([^\"]*)" for "([^\"]*)"$/ do |content, question|
  Given "a multiple choice content \"#{content}\""
  Given "a question \"#{question}\""
  @content.question = @question
  @content.save!
end

Given /^(?:|an )option "([^\"]*)" for "([^\"]*)"$/ do |opt, content|
  Given "a multiple choice content \"#{content}\""
  Option.create! :content => opt, :option_owner => @content
end

Given /^following options for "([^\"]*)":$/ do |question, table|
  Given "a multiple choice content \"#{question}\" for \"#{question}\""
  for option in table.raw.flatten
    Given "option \"#{option}\" for \"#{question}\""
  end
end
