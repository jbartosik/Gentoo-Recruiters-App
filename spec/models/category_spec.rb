require 'spec_helper.rb'
describe Category do

  include Permissions::TestPermissions

  it "should allow admin to create, edit, update and remove" do
    cud_allowed([Factory(:administrator)], Factory(:category))
  end

  it "should prohibit nonadmins to creating, editing, updating and removing" do
    cud_denied([Factory(:recruit), Factory(:mentor), Guest.new,
      Factory(:recruiter)], Factory(:category))
  end

  it "should be allowed for everybody to view" do
    view_allowed([Factory(:recruit), Factory(:mentor), Factory(:recruiter),
      Factory(:administrator), Guest.new], Factory(:category))
  end

  it { should validate_presence_of :name }

  it "should return proper as_select_opts" do
    c1 = Factory(:category)
    c2 = Factory(:category)
    options = [['All Categories', nil], [c1.name, c1.id], [c2.name, c2.id]]

    (options - Category.as_select_opts).should be_empty
    (Category.as_select_opts - options).should be_empty
    Category.as_select_opts.count.should == Category.as_select_opts.uniq.count
  end
end
