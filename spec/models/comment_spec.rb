require 'spec_helper.rb'
describe Comment do

  include Permissions::TestPermissions

  it 'should be allow mentors to comment their recruits answers' do
    recruit     = Factory(:recruit)
    new_comment = Comment.new(:owner => recruit.mentor, :content => "content", :answer => Factory(:answer, :owner => recruit))
    new_comment.should be_creatable_by(recruit.mentor)
  end

  it 'should prohibit users other then mentor of answer owner from commenting' do
    recruit     = Factory(:recruit)
    for user in fabricate_all_roles
      new_comment = Comment.new(:owner => user, :content => "content", :answer => Factory(:answer, :owner => recruit))
      new_comment.should_not be_creatable_by(user)

      # also block attempts to comment as someone else
      new_comment = Comment.new(:owner => recruit.mentor, :content => "content", :answer => Factory(:answer, :owner => recruit))
      new_comment.should_not be_creatable_by(user)
    end
  end

  it 'should allow owner of answer, recruiters and mentor to view' do
    comment = Factory(:comment)
    view_allowed([Factory(:recruiter), comment.answer.owner,
      comment.answer.owner.mentor], comment)
  end

  it 'should prohibit other users to view, update, destroy' do
    users   = [Guest.new] + fabricate_users(:recruit, :mentor)
    comment = Factory(:comment)

    view_denied(users, comment)
    ud_denied(users, comment)
  end

  it 'should allow mentor of owner of answer to update, edit, destroy' do
    comment = Factory(:comment)
    mentor  = [comment.answer.owner.mentor]

    ud_allowed(mentor, comment)
    edit_allowed(mentor, comment)
  end

  it {should validate_presence_of :content}

  it "should send email notification to owner of answer when created" do
    answer  = Factory(:answer)
    comment = Comment.new(:owner => answer.owner.mentor, :answer => answer, :content => "some comment")

    UserMailer.should_receive(:send_later).with(:deliver_new_comment, answer.owner, comment)

    comment.save!
  end
end
