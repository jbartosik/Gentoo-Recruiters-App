Then /^I should see instructions on becoming mentor for "([^\"]*)"$/ do |user|
    When "I am on edit \"#{user}\" user page"
    Then "I should see \"If you want to start or stop mentoring this recruit " +
          "go back to show page for this user and click 'Start/Stop mentoring " +
          "this recruit' button.\""

    When 'I follow "show page for this user"'
    Then "I should be on show \"#{user}\" user page"
end

Then /^I should see explanation that I can't become mentor for "([^\"]*)"$/ do |user|
    When "I am on edit \"#{user}\" user page"
    Then "I should see \"You can not change mentor for this user (possible " +
          "reasons are: you're not logged in, you don't have mentor role, " +
          "someone else is mentor for this user).\""
end
