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

Given /^reference choice for "([^"]*)":$/ do |content, table|
  Given "a multiple choice content \"#{content}\""
  Given 'user "recruiter"'

  user = @user.name
  table = table.raw.flatten
  ans   = @content.options.inject(Array.new) do |res, cur|
    res.push cur.id if table.include?(cur.content)
    res
  end
  Given "answer of \"#{user}\" for question \"#{content}\""
  @answer.options   = ans
  @answer.reference = true
  @answer.save!
end

Given /^"([^"]*)" chose following for "([^"]*)":$/ do |user, content, table|
  Given "a multiple choice content \"#{content}\""
  Given "answer of \"#{user}\" for question \"#{content}\""

  table = table.raw.flatten
  ans   = @content.options.inject(Array.new) do |res, cur|
    res.push cur.id if table.include?(cur.content)
    res
  end

  @answer.options = ans
  @answer.save!
end

Given /^recruit with multiple choice questions to answer$/ do
  Given "following questions:", table(%{
      |question 1|cat|
      |question 2|cat|
  })
  Given 'following options for "question 1":', table(%{
      |correct 1|correct 2|correct 3|
  })
  Given 'following options for "question 2":', table(%{
      |incorrect 1|incorrect 2|correct 4|
  })
  Given 'user "recruit" has category "cat"'
  Given 'reference choice for "question 1":', table(%{
      |correct 1|correct 2|
  })
  Given 'reference choice for "question 2":', table(%{
      |correct 4|
  })
end

Given /^I am logged in as recruit with multiple choice questions to answer$/ do
  Given "recruit with multiple choice questions to answer"
  Given 'I am logged in as "recruit"'
end
