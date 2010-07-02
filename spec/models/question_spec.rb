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

  it "should be allowed for everybody to view ungrouped questions" do
    view_allowed([Factory(:recruit), Factory(:mentor), Factory(:recruiter),
      Factory(:administrator), Guest.new], Factory(:question))
  end

  it "should prohibit recruits, mentors and guests grouped questions not associated to user" do
    group       = Factory(:question_group)
    view_denied([Factory(:recruit), Factory(:mentor), Guest.new], Factory(:question, :question_group => group, :user => Factory(:recruit)))
  end

  it "should allow recruits and mentors to view questions associated to user or users recruit" do
    group       = Factory(:question_group)
    question    = Factory(:question, :question_group => group)
    mentor      = Factory(:mentor)
    recruit     = Factory(:recruit, :mentor => mentor)
                  Factory(:user_question_group, :user => recruit, :question => question)

    for user in [recruit, mentor]
      question.should be_viewable_by(user)
    end
  end

  it "should allow recruiters to view all questions" do
    view_allowed([Factory(:recruiter), Factory(:administrator)],
      Factory(:question, :question_group => Factory(:question_group)))
  end

  it { should validate_presence_of :title }

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

  it "should send email notifications to watching recruits when created by recruiter" do
    category  = Factory(:question_category)
    recruit   = Factory(:recruit, :question_categories => [category])
    question  = Question.new(:title => "new question",
      :question_category => category)

    UserMailer.should_receive(:deliver_new_question).with(recruit, question)

    question.save!
  end

  it "should send email notifications to watching recruits when approved" do
    category  = Factory(:question_category)
    recruit   = Factory(:recruit, :question_categories => [category])
    question  = Factory(:question, :title => "new question",
      :question_category => category, :user => Factory(:recruit))

    UserMailer.should_receive(:deliver_new_question).with(recruit, question)
    question.approved = true
    question.save!
  end

  it "should not send email notifications to watching recruits when approved is changed" do
    category  = Factory(:question_category)
    recruit   = Factory(:recruit, :question_categories => [category])
    question  = Factory(:question, :title => "new question",
      :question_category => category, :user => Factory(:recruit), :approved => true)

    UserMailer.should_not_receive(:deliver_new_question).with(recruit, question)

    question.title = "changed"
    question.save!
  end

  it "should allow signed up users to CRUD users their own unapproved questions" do
    for user in fabricate_all_roles
      question = Question.new :user => user, :title => "fake"
      allow_all([user], question)
      question.save!
      allow_all([user], question)
    end
  end

  it "should prohibit signed up users to CUD users their own approved questions" do
    for user in fabricate_users(:recruit, :mentor)
      question = Question.new :user => user, :title => "fake", :approved => true
      question.should_not be_editable_by(user)
      question.should_not be_creatable_by(user)
      question.should_not be_destroyable_by(user)
      question.should_not be_updatable_by(user)
    end
  end

  it "should allow admins to CRUD questions someone owns" do
    for user in fabricate_all_roles
      question = Factory(:question, :user => user)
      question.save!
      allow_all([Factory(:administrator)], question)
    end
  end

  it "should allow recruiters to view questions someone owns" do
    for user in fabricate_all_roles
      question = Factory(:question, :user => user)
      question.save!
      question.should be_viewable_by(Factory(:recruiter))
    end
  end

  it "should prohibit non-recruiters to CRUD unapproved questions of someone else" do
    question = Factory(:question, :user => Factory(:recruit))
    deny_all(fabricate_users(:recruit, :mentor) + [Guest.new], question)
  end

  it "should allow owner to edit only some attributes when is new record" do
    recruit  = Factory(:recruit)
    question = Question.new :user => recruit

    question.should     be_editable_by(recruit)
    question.should     be_editable_by(recruit, :title)
    question.should     be_editable_by(recruit, :documentation)
    question.should     be_editable_by(recruit, :question_category)

    question.should_not be_editable_by(recruit, :user)
    question.should_not be_editable_by(recruit, :approved)
  end

  it "should allow owner to edit only some attributes when is existing record" do
    recruit  = Factory(:recruit)
    question = Factory(:question, :user => recruit)

    question.should     be_editable_by(recruit)
    question.should     be_editable_by(recruit, :title)
    question.should     be_editable_by(recruit, :documentation)
    question.should     be_editable_by(recruit, :question_category)

    question.should_not be_editable_by(recruit, :user)
    question.should_not be_editable_by(recruit, :approved)
  end

  it "should allow admin to edit all attributes execpt user" do
    admin = Factory(:administrator)
    question = Factory(:question, :user => Factory(:recruit))

    question.should be_editable_by(admin)
    question.should be_editable_by(admin, :title)
    question.should be_editable_by(admin, :documentation)
    question.should be_editable_by(admin, :question_category)
    question.should be_editable_by(admin, :approved)

    question.should_not be_editable_by(admin, :user)
  end
end
