require 'spec_helper.rb'
describe Question do

  fixtures :users
  include Permissions::TestPermissions

  before(:each) do
    @new_question = Question.create!( :title => "Example", :content => "Example")
    @recruit    = users(:ron)
    @recruiter  = users(:ralph)
    @mentor     = users(:mustafa)
    @admin      = users(:ann)
    @guest      = Guest.new
  end

  it "should be allowed for recruiters to create, edit, update and remove" do
    cud_allowed([@admin, @recruiter], @new_question)
  end

  it "should be prohibited for nonrecruiters to create, edit, update and remove" do
    cud_denied([@recruit, @mentor, @guest], @new_question)
  end

  it "should be allowed for everybody to view" do
    view_allowed([@recruit, @mentor, @recruiter, @admin, @guest], @new_question)
  end

  it { should validate_presence_of :title }
  it { should validate_presence_of :content }
end
