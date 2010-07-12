Given /^email question content for "([^\"]*)"$/ do |question|
  Given "a question \"#{question}\""
  @content = @question.content
  @content = QuestionContentEmail.create!(:question => @question, :description => "Remember to replace @gentoo.org with localhost") if @content.nil?
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
  Given "user \"recruit\" has category \"questions\""
  Given "a question \"gentoo-dev-announce posting\" in category \"questions\""
  Given "email question content for \"gentoo-dev-announce posting\" with following requirements:", table(%{
    |To|gentoo-dev-announce@localhost|
    |To|gentoo-dev@localhost|
    |Reply-To|gentoo-dev@localhost|
  })
end

When /^I send wrong email announcement$/ do
  Given "user \"recruit\""

  mail          = TMail::Mail.new
  mail.subject  = 'answer for "gentoo-dev-announce posting"'
  mail.from     = @user.email_address
  mail.to       = 'gentoo-dev-announce@localhost'

  UserMailer.receive(mail.to_s)
end

When /^I send proper email announcement$/ do
  Given "user \"recruit\""

  mail          = TMail::Mail.new
  mail.subject  = 'answer for "gentoo-dev-announce posting"'
  mail.from     = @user.email_address
  mail.to       = ['gentoo-dev-announce@localhost', 'gentoo-dev@localhost']
  mail.reply_to = 'gentoo-dev@localhost'

  UserMailer.receive(mail.to_s)
end
