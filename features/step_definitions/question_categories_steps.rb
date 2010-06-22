Given /^a question category "([^\"]*)"$/ do |name|
  @question_category = QuestionCategory.find_by_name(name)
  if @question_category.nil?
    @question_category = QuestionCategory.create!(:name => name)
  end
end
