Then /^I should see tag <([^<>]*)>$/ do |tag|
  /#{tag}/.match(response.body).should_not be_nil
end

Then /^I should not see tag <([^<>]*)>$/ do |tag|
  /#{tag}/.match(response.body).should be_nil
end

Then /^I should see pie chart with feedback for "([^"]*)"$/ do |question|
  Given "a question \"#{question}\""
  Then "I should see tag <iframe src=\"/questions/#{@question.id}/doc_feedback_chart\">"
end

Then /^I should see no pie chart with feedback$/ do
  Then 'I should not see tag <iframe src="/questions/\d+/doc_feedback_chart">'
end
