Given /^project acceptance of "([^\"]*)" by "([^\"]*)"$/ do |user, nick|
  Given "user \"#{user}\""
  @acceptance = ProjectAcceptance.first :conditions => { :user_id => @user.id, :accepting_nick => nick }
  if @acceptance.nil?
    @acceptance = ProjectAcceptance.create! :user => @user, :accepting_nick => nick
  end
end

Given /^pending project acceptance of "([^\"]*)" by "([^\"]*)"$/ do |user, nick|
  Given "project acceptance of \"#{user}\" by \"#{nick}\""
  @acceptance.accepted = false
  @acceptance.save!
end

Given /^accepted project acceptance of "([^\"]*)" by "([^\"]*)"$/ do |user, nick|
  Given "project acceptance of \"#{user}\" by \"#{nick}\""
  @acceptance.accepted = true
  @acceptance.save!
end
