require 'spec_helper.rb'
describe UserCategory do

  include Permissions::TestPermissions

  it "should allow logged in users to CUD, edit and view their categories" do
    for user in fabricate_all_roles
      user_category = Factory(:user_category, :user => user)
      user_category.should be_viewable_by(user)
      user_category.should be_creatable_by(user)
      user_category.should be_updatable_by(user)
      user_category.should be_destroyable_by(user)
      user_category.should be_editable_by(user)
    end
  end

  it "should prohibit guests to CUD, edit and view user categories" do
    deny_all([Guest.new], Factory(:user_category))
  end

  it "should allow recruiters to CUD, edit and view categories of anyone" do
    allow_all(fabricate_users(:recruiter, :administrator), Factory(:user_category))
  end

  it "should allow mentors of users to view categories but prohibit everything else" do
    user_cat = Factory(:user_category)
    mentor = user_cat.user.mentor
    user_cat.should     be_viewable_by(mentor)
    user_cat.should_not be_destroyable_by(mentor)
    user_cat.should_not be_updatable_by(mentor)
    user_cat.should_not be_editable_by(mentor)
  end

  it "should deny other users to CUD, edit and view user categories" do
    deny_all(fabricate_users(:recruit, :mentor) + [Guest.new], Factory(:user_category))
  end
end
