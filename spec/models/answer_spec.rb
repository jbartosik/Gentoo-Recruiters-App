require 'spec_helper.rb'
describe 'Question' do

  fixtures :users
  include Permissions::TestPermissions

  before( :each) do
    @recruit    = users(:ron)
    @recruiter  = users(:ralph)
    @mentor     = users(:mustafa)
    @admin      = users(:ann)
    @guest      = Guest.new
    @users      = [@recruit, @mentor, @recruiter, @admin]
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
      view_denied(@users - [user, @recruiter, @admin] + [@guest], @new_answer)
    end
  end
  
  it 'should be allowed for recruiters to view all answers' do
    for user in @users
      @new_answer = Answer.create!(:owner => user)
      view_allowed([@recruiter, @admin], @new_answer)
    end
  end
end
