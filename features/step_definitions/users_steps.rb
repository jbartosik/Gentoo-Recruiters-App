Given /^user "([^\"]*)"$/ do |user_name|
  @user      = User.find_by_name(user_name)
  if @user.nil?
    @user = User.create!( :name => user_name, :email_address => "#{user_name}@users.org",
      :password => "secret", :password_confirmation => "secret", :nick => user_name)
  end
end

Given /^(?:|a )user "([^\"]*)" who is "([^\"]*)"$/ do |user, role|
  Given "user \"#{user}\""
  @user.role = Role.new(role)
  @user.save!
end

Given /^user "([^\"]*)" has category "([^\"]*)"$/ do |user_name, category_name|
  Given "user \"#{user_name}\""
  Given "a question category \"#{category_name}\""
  unless @user.question_categories.include?(@question_category)
    @user.question_categories.push(@question_category)
  end
  @user.save!
end

Given /^"([^\"]*)" answered question "([^\"]*)"$/ do |user, question|
  Given "user \"#{user}\""
  And   "a question \"#{question}\""
  unless @question.answered?(@user)
    Answer.create!( :question => @question, :owner => @user, :content => "fake" )
  end
end

Given /^user "([^\"]*)" answered all questions in "([^\"]*)"$/ do |user_name,  category_name|
  Given "a question category \"#{category_name}\""
  for q in @question_category.questions
    if q.question_group.nil?
      Given "\"#{user_name}\" answered question \"#{q.title}\""
    end
  end
end

Given /^(?:|a )recruit "([^\"]*)" in following categories:$/ do |recruit, fields|
  Given "user \"#{recruit}\" who is \"recruit\""
  fields.raw.flatten.each do |name|
    Given "user \"#{recruit}\" has category \"#{name}\""
  end
end

Given /^user "([^\"]*)" is mentor of "([^\"]*)"$/ do |mentor, recruit|
  Given "user \"#{mentor}\" who is \"mentor\""
  @mentor = @user
  Given "user \"#{recruit}\""
  @recruit = @user
  @recruit.mentor = @mentor
  @recruit.save!
end

Given /^I am logged in as "([^\"]*)"$/ do |login|
  Given "I am on login page"
  And   "user \"#{login}\""
  When  "I fill in \"login\" with \"#{login}@users.org\""
  And   "I fill in \"password\" with \"secret\""
  And   "I press \"Log in\""
end

Given /^I am logged in as "([^\"]*)" who is "([^\"]*)"$/ do |login, role|
  Given "user \"#{login}\" who is \"#{role}\""
  Given "I am logged in as \"#{login}\""
end

Given /^I am logged in as administrator$/ do
  Given "user \"admin\" who is \"recruiter\""
  @user.administrator = true
  @user.save!
  Given "I am logged in as \"admin\""
end

Given /^"([^"]*)" suggested question "([^"]*)"$/ do |user, question|
  Given "user \"#{user}\""
  Given "a question \"#{question}\""
  @question.user = @user
  @question.approved = false
  @question.save!
end

Given /^user "([^"]*)" is associated with question "([^"]*)"$/ do |user, question|
  Given "user \"#{user}\""
  Given "a question \"#{question}\""
  UserQuestionGroup.create! :user => @user, :question => question
end
