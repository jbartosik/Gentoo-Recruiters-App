Given /^project lead "([^"]+)"$/ do |nick|
  Given "user \"#{nick}\""
  @user.update_attribute :project_lead, true
end
