require 'spec_helper.rb'
describe Question do

  fixtures :users, :answers, :questions, :question_categories
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

  it "should not return reference answer as answer of user" do
      questions(:apple).answer_of(@recruiter).should_not == answers(:reference_apple)
  end

  it "should send email notifications to watching recruits when created" do
    category = question_categories(:fruit)
    question = Question.new(:title => "new question", :content => "some content",
      :question_category => category)

    UserMailer.should_receive(:deliver_new_question).with(@recruit, question)

    question.save!
  end
end
