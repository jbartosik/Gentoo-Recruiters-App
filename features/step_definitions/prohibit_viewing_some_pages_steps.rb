Then /^I should be prohibited to visit (.+)/ do |page_name|
  assert_raise(Hobo::PermissionDeniedError){ visit path_to(page_name) }
end

