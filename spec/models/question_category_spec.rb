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

  it "should return proper as_select_opts" do
    c1 = Factory(:question_category)
    c2 = Factory(:question_category)
    options = [['All Categories', nil], [c1.name, c1.id], [c2.name, c2.id]]

    (options - QuestionCategory.as_select_opts).should be_empty
    (QuestionCategory.as_select_opts - options).should be_empty
    QuestionCategory.as_select_opts.count.should == QuestionCategory.as_select_opts.uniq.count
  end
end
