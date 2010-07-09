Given /^(?:|a )answer of "([^\"]*)" for question "([^\"]*)"$/ do |user, question|
  Given "a question \"#{question}\""
  Given "user \"#{user}\""
  @answer = @question.answer_of @user
  if @answer.nil?
    if @question.content.nil?
    @answer = Answer.create!(:owner => @user, :question => @question, :content => "fake")
    else
      @answer = @question.content.new_answer_of(@user)
    end
  end
end
