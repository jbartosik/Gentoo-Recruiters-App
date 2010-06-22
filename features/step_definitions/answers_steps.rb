Given /^(?:|a )answer of "([^\"]*)" for question "([^\"]*)"$/ do |user, question|
  Given "a question \"#{question}\""
  Given "user \"#{user}\""
  @answer = @question.answer_of @user
  if @answer.nil?
    @answer = Answer.create!( :owner => @user, :question => @question, :content => "fake")
  end
end
