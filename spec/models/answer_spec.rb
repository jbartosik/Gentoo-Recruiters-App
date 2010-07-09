require 'spec_helper.rb'
describe Answer do

  include Permissions::TestPermissions

  it 'any user (not guest) should be allowed to create, read, update and delete owned answers' do
    for user in fabricate_all_roles
      new_answer = Factory(:answer, :owner => user)
      cud_allowed([user], new_answer)
      view_allowed([user], new_answer)
    end
  end

  it 'should be prohibited to create, update and delete answers someone else owns' do
    for user in fabricate_all_roles
      ud_denied(fabricate_all_roles + [Guest.new], Factory(:answer, :owner => user))
      # updatable_by? blocks changing db
      # mentor is covered in separate test
    end
  end

  it 'should be creatable by any logged in user' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      new_answer.should be_creatable_by user
    end
  end

  it 'should not be creatable by guest' do
    Factory(:answer).should_not be_creatable_by Guest.new
  end

  it 'should allow owner to edit answer as whole and content field' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      new_answer.should be_editable_by user
      new_answer.should be_editable_by user, :content
    end
  end

  it 'should prohibited editing of non-reference answer as whole and content field to non-owners' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      edit_denied(fabricate_all_roles, new_answer)
      edit_denied(fabricate_all_roles, new_answer, :content)
    end
  end

  it 'should be prohibited for non-recruiters to view answers someone else owns' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      view_denied(fabricate_users(:recruit, :mentor)+ [Guest.new], new_answer)
    end
  end

  it 'should be allowed for recruiters to view all answers' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      view_allowed(fabricate_users(:recruiter, :administrator), new_answer)
    end
  end

  it "should be viewable by mentor of it's owner" do
    mentor  = Factory(:mentor)
    recruit = Factory(:recruit, :mentor => mentor)
    new_answer = Factory(:answer, :owner => recruit)
    view_allowed([mentor], new_answer)
  end

  it { should belong_to(:question) }
  it { should have_readonly_attribute(:owner) }

  it "should prohibit CUD and view of reference ans to non-recruiters" do
    new_answer  = Factory(:answer, :reference => true)
    cud_denied(fabricate_users(:recruit, :mentor), new_answer)
    view_denied(fabricate_users(:recruit, :mentor), new_answer)
  end

  it "should allow CUD, view and edit of reference answers to recruiters" do
    new_answer  = Factory(:answer, :reference => true)
    cud_allowed(fabricate_users(:recruiter, :administrator), new_answer)
    edit_allowed(fabricate_users(:recruiter, :administrator), new_answer)
    edit_allowed(fabricate_users(:recruiter, :administrator), new_answer, :content)
  end

  it "should allow mentor of owner to approve and disapprove" do
    r = recruit_with_answers_in_categories(nil, 1, 1)
    answer = r.all_answers.first
    for i in 1..2
      answer.approved = !answer.approved
      answer.should be_updatable_by(r.mentor)
      answer.should be_editable_by(r.mentor)
      answer.should be_editable_by(r.mentor, :approved)
      answer.save!
    end
  end

  it "should prohibit mentor of owner to edit content" do
    answer  = Factory(:answer)

    answer.content      = "changed"
    answer.should_not   be_updatable_by(answer.owner.mentor)
  end

  it "should prohibit owner to save changed answer as approved" do
    answer  = Factory(:answer)

    answer.approved = true
    answer.save!

    answer.content  = "changed"
    answer.should_not be_updatable_by(answer.owner)
  end

  it "should allow owner to save changed answer as unapproved" do
    answer  = Factory(:answer)

    answer.approved = true
    answer.save!

    answer.content  = "changed"
    answer.approved = false
    answer.should be_updatable_by(answer.owner)
  end

  it "should mark questions with changed content as unapproved" do
    answer  = Factory(:answer)

    answer.approved = true
    answer.save!

    answer.content  = "changed"
    answer.save!
    answer.approved.should be_false
  end

  it "should send email notification to mentor when created" do
    question  = Factory(:question)
    recruit   = Factory(:recruit)

    #can't use Factory Girl here, because we want to save it after setting expectation to get email
    answer    = Answer.new(:owner => recruit, :question => question, :content => "Some answer.")

    UserMailer.should_receive(:deliver_new_answer).with(recruit.mentor, answer)

    answer.save!
  end

  it "should send email notification to mentor when changed" do
    answer = Factory(:answer)
    UserMailer.should_receive(:deliver_changed_answer).with(answer.owner.mentor, answer)
    answer.content = "changed"
    answer.save!
  end

  it "shouldn't try to send notifications to mentor of mentorless recruit" do
    recruit =  Factory(:recruit, :mentor => nil)
    UserMailer.should_not_receive(:deliver_changed_answer)
    answer  = Factory(:answer, :owner => recruit)
    answer.save!
    answer.content = "changed"
    answer.save!
  end
end
