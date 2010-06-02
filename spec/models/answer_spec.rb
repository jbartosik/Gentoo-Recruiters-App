require 'spec_helper.rb'
describe Answer do

  fixtures :users, :questions, :answers
  include Permissions::TestPermissions

  before( :each) do
    @recruit    = users(:ron)
    @recruiter  = users(:ralph)
    @mentor     = users(:mustafa)
    @admin      = users(:ann)
    @guest      = Guest.new
    @users      = [@recruit, @mentor, @recruiter, @admin]

    @question       = questions(:apple)
    @recruit_ans_q  = answers(:apple)
    @ans            = answers(:banana)
  end

  it 'any user (not guest) should be allowed to create, read, update and delete owned answers' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      cud_allowed([user], @new_answer)
      view_allowed([user], @new_answer)
    end
  end

  it 'should be prohibited to create, update and delete answers someone else owns' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      ud_denied(@users - [user , user.mentor] + [@guest], @new_answer)
      # updatable_by? blocks changing db
      # mentor is covered in separate test
    end
  end

  it 'should be creatable by any logged in user' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      @new_answer.should be_creatable_by user
    end
  end

  it 'should not be creatable by guest' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      @new_answer.should_not be_creatable_by @guest
    end
  end

  it 'should allow owner to edit answer as whole and content field' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      @new_answer.should be_editable_by user
      @new_answer.should be_editable_by user, :content
    end
  end

  it 'should prohibited editing of non-reference answer as whole and content field to non-owners' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      edit_denied(users - [user], @new_answer)
      edit_denied(users - [user], @new_answer, :content)
    end
  end

  it 'should be prohibited for non-recruiters to view answers someone else owns' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      view_denied(@users - [user, @recruiter, @admin, @mentor] + [@guest], @new_answer)
    end
  end
  
  it 'should be allowed for recruiters to view all answers' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      view_allowed([@recruiter, @admin], @new_answer)
    end
  end

  it "should be viewable by mentor of it's owner" do
   @new_answer = Answer.create!(:owner => @recruit)
   view_allowed([@mentor], @new_answer)
  end

  it { should belong_to(:question) }
  it { should have_readonly_attribute(:owner) }

  it "should prohibit CUD and view of reference ans to non-recruiters" do
    @new_answer = Answer.create!(:owner => @recruiter)
    @new_answer.reference = true
    cud_denied([@recruit], @new_answer)
    @new_answer.should_not be_viewable_by(@recruit)
  end

  it "should allow CUD, view and edit of reference answers to recruiters" do
    @new_answer = Answer.create!(:owner => @admin)
    @new_answer.reference = true
    cud_allowed([@recruiter, @admin], @new_answer)
    edit_allowed([@recruiter, @admin], @new_answer)
    edit_allowed([@recruiter, @admin], @new_answer, :content)
  end

  it "should allow mentor of owner to approve and disapprove" do
    for i in 1..2
      @ans.approved = !@ans.approved
      @ans.should be_updatable_by(@ans.owner.mentor)
      @ans.should be_editable_by(@ans.owner.mentor)
      @ans.should be_editable_by(@ans.owner.mentor, :approved)
    end
  end

  it "should prohibit mentor of owner to edit content" do
    @ans.content    = "changed"
    @ans.should_not be_updatable_by(@ans.owner.mentor)
  end

  it "should prohibit owner to save changed answer as approved" do
    @ans.content          = "changed"
    @ans.approved.should  be_true
    @ans.should_not       be_updatable_by(@ans.owner)
  end

  it "should allow owner to save changed answer as unapproved" do
    @ans.content                  = "changed"
    @ans.approved                 = false
    @ans.approved_changed?.should be_true
    @ans.should                   be_updatable_by(@ans.owner)
  end
end
