require 'spec_helper.rb'
describe QuestionCategory do

  fixtures :users

  before(:each) do
    @new_category = QuestionCategory.create!(:name => "Example")
    @recruit      = users(:ron)
    @recruiter    = users(:ralph)
    @mentor       = users(:mustafa)
    @admin        = users(:ann)
    @guest      = Guest.new
  end

  include Permissions::TestPermissions

  it "should allow admin to create, edit, update and remove" do
    cud_allowed([@admin], @new_category)
  end

  it "should prohibit nonadmins to creating, editing, updating and removing" do
    cud_denied([@recruit, @mentor, @guest, @recruiter], @new_category)
  end

  it "should be allowed for everybody to view" do
    view_allowed([@recruit, @mentor, @recruiter, @admin, @guest], @new_category)
  end

  it { should validate_presence_of :name }
end
