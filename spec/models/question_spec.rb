require 'spec_helper.rb'
describe Question do

  fixtures :users, :answers, :questions
  include Permissions::TestPermissions

  before(:each) do
    @new_question = Question.create!( :title => "Example", :content => "Example")
    @recruit    = users(:ron)
    @recruiter  = users(:ralph)
    @mentor     = users(:mustafa)
    @admin      = users(:ann)
    @guest      = Guest.new
  end

  it "should allow admin to create, edit, update and remove" do
    cud_allowed([@admin], @new_question)
  end

  it "should prohibit nonadmins to creating, editing, updating and removing" do
    cud_denied([@recruit, @mentor, @guest, @recruiter], @new_question)
  end

  it "should be allowed for everybody to view" do
    view_allowed([@recruit, @mentor, @recruiter, @admin, @guest], @new_question)
  end

  it { should validate_presence_of :title }
  it { should validate_presence_of :content }

  it "should return proper answer of user" do
    for qa in [:apple, :banana]
      questions(qa).answer_of(@recruit).should == answers(qa)
      questions(qa).answer_of(@admin).should == nil
      questions(qa).answer_of(@guest).should == nil
    end
  end
end
