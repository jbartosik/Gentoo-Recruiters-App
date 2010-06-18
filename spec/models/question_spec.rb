require 'spec_helper.rb'
describe Question do

  include Permissions::TestPermissions

  it "should allow admin to create, edit, update and remove" do
    cud_allowed([Factory(:administrator)], Factory(:question))
  end

  it "should prohibit nonadmins to creating, editing, updating and removing" do
    cud_denied([Factory(:recruit), Factory(:mentor), Guest.new,
      Factory(:recruiter)], Factory(:question))
  end

  it "should be allowed for everybody to view" do
    view_allowed([Factory(:recruit), Factory(:mentor), Factory(:recruiter),
      Factory(:administrator), Guest.new], Factory(:question))
  end

  it { should validate_presence_of :title }
  it { should validate_presence_of :content }

  it "should return proper answer of user" do
    question  = Factory(:question)
    answer1   = Factory(:answer, :question => question)
    answer2   = Factory(:answer, :question => question)

    for answer in [answer1, answer1]
      question.answer_of(answer.owner).should == answer
    end

    question.answer_of(Factory(:recruit)).should        == nil
    question.answer_of(Factory(:mentor)).should         == nil
    question.answer_of(Factory(:recruiter)).should      == nil
    question.answer_of(Factory(:administrator)).should  == nil
    question.answer_of(Guest.new).should                == nil
  end

  it "should not return reference answer as answer of user" do
      question  = Factory(:question)
      recruiter = Factory(:recruiter)
      reference = Factory(:answer, :question => question, :reference => true, :owner => recruiter)
                  Factory(:answer, :question => question, :owner => recruiter)
      question.answer_of(recruiter).should_not == reference
  end

  it "should send email notifications to watching recruits when created" do
    category  = Factory(:question_category)
    recruit   = Factory(:recruit, :question_categories => [category])
    question  = Question.new(:title => "new question", :content => "some content",
      :question_category => category)

    UserMailer.should_receive(:deliver_new_question).with(recruit, question)

    question.save!
  end
end
