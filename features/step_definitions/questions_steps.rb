Given /^a question "([^\"]*)"$/ do |title|
  @question = Question.find_by_title(title)
  if @question.nil?
    @question = Question.create!( :title => title, :content => "fake")
  end
end

Given /^a question "([^\"]*)" in category "([^\"]*)"$/ do |title, category|
  Given "a question \"#{title}\""
  Given "a question category \"#{category}\""
  @question.question_category = @question_category
  @question.save!
end
