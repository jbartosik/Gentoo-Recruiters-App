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
      ud_denied(@users - [user] + [@guest], @new_answer)
      #updatable_by? blocks changing db
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
  it { should validate_uniqueness_of(:question_id).scoped_to(:owner_id) }
  it { should have_readonly_attribute(:owner) }
end
