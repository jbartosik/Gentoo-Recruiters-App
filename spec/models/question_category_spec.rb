require 'spec_helper.rb'
describe QuestionCategory do

  include Permissions::TestPermissions

  it "should allow admin to create, edit, update and remove" do
    cud_allowed([Factory(:administrator)], Factory(:question_category))
  end

  it "should prohibit nonadmins to creating, editing, updating and removing" do
    cud_denied([Factory(:recruit), Factory(:mentor), Guest.new,
      Factory(:recruiter)], Factory(:question_category))
  end

  it "should be allowed for everybody to view" do
    view_allowed([Factory(:recruit), Factory(:mentor), Factory(:recruiter),
      Factory(:administrator), Guest.new], Factory(:question_category))
  end

  it { should validate_presence_of :name }
end
