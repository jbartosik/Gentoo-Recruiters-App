Given /^a category "([^\"]*)"$/ do |name|
  @category = Category.find_by_name(name) || Category.create!(:name => name)
end
