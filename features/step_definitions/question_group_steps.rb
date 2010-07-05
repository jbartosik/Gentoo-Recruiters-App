Given /^question group "([^"]*)"$/ do |name|
  @question_group = QuestionGroup.find_by_name(name)
  if @question_group.nil?
    @question_group = QuestionGroup.create! :name => name, :description => "Description of #{name}"
  end
end
