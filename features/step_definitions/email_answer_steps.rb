Given /^email question content for "([^\"]*)"$/ do |question|
  Given "a question \"#{question}\""
  @content = @question.content
  unless @content.is_a? QuestionContentEmail
    @content.try.destroy
    @content = QuestionContentEmail.create!(:question => @question, :description => "Remember to replace @gentoo.org with localhost")
    @question.reload
  end
end

Given /^email question content for "([^\"]*)" with following requirements:$/ do |question, table|
  Given "email question content for \"#{question}\""
  res = table.raw.inject(String.new) do |res, cur|
    cur[0].sub!(':', '\:')
    cur[1].sub!(':', '\:')
    res += "#{cur[0]} : #{cur[1]}\n"
    res
  end
  @content.req_text = res
  @content.save!
end

Given /^recruit that should answer gentoo-dev-announce posting question$/ do
  Given 'user "recruit" has category "questions"'
  Given 'a question "gentoo-dev-announce posting" in category "questions"'
  Given 'email question content for "gentoo-dev-announce posting" with following requirements:', table(%{
    |To|gentoo-dev-announce@localhost|
    |To|gentoo-dev@localhost|
    |Reply-To|gentoo-dev@localhost|
  })
end

When /^I send wrong email announcement$/ do
  Given 'user "recruit"'
  Given 'a question "gentoo-dev-announce posting"'

  mail          = TMail::Mail.new
  mail.subject  = "#{@question.id}-#{@user.token}"
  mail.from     = @user.email_address
  mail.to       = ['gentoo-dev-announce@localhost']

  Receiver.receive(mail.to_s)
end

When /^I send proper email announcement$/ do
  Given 'user "recruit"'

  mail          = TMail::Mail.new
  mail.from     = @user.email_address
  mail.subject  = "#{@question.id}-#{@user.token}"
  mail.to       = ['gentoo-dev-announce@localhost', 'gentoo-dev@localhost']
  mail.reply_to = 'gentoo-dev@localhost'

  Receiver.receive(mail.to_s)
end

When /^someone sends forged answer$/ do
  Given 'user "recruit"'

  mail          = TMail::Mail.new
  mail.from     = @user.email_address
  mail.to       = ['gentoo-dev-announce@localhost', 'gentoo-dev@localhost']
  mail.reply_to = 'gentoo-dev@localhost'

  Given 'user "forger"'
  mail.subject  = "#{@question.id}-#{@user.token}"

  Receiver.receive(mail.to_s)
end

Then /^I should see subject for email "([^"]+)" should send to answer "([^"]+)"$/ do |user, question|
  Given "user \"#{user}\""
  Given "a question \"#{question}\""
  Then "I should see \"#{@question.id}-#{@user.token}\""
end
