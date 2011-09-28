{
  'as a role' => '.role-tag.view.user-role',
  'as hint' => '.input-help',
  'as question content' => '.view.question-content'
}.
each do |within, selector|
  Then /^I should( not)? see "([^"]*)" #{within}$/ do |negation, text|
    Then %Q{I should#{negation} see "#{text}" within "#{selector}"}
  end
end
