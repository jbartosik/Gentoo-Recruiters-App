require 'spec_helper.rb'
describe UserCategory do

  fixtures :users, :question_categories, :user_categories
  include Permissions::TestPermissions

  before( :each) do
    @recruit    = users(:ron)
    @recruiter  = users(:ralph)
    @mentor     = users(:mustafa)
    @admin      = users(:ann)
    @guest      = Guest.new
    @users      = [@recruit, @mentor, @recruiter, @admin]

    @fruit      = question_categories(:fruit)

    @recruit_cat= user_categories(:ron_fruit)
  end

  it "should allow logged in users to CUD, edit and view their categories" do
    allow_all(users) do |user|
      UserCategory.create(:user => user, :question_category => @fruit)
    end
  end

  it "should prohibit guests to CUD, edit and view user categories" do
    deny_all([@guest], @recruit_cat)
  end

  it "should allow recruiters to CUD, edit and view categories of anyone" do
    allow_all([@recruiter, @admin], @recruit_cat)
  end

  it "should allow mentors of users to view categories but prohibit everything else" do
    mentor = @recruit_cat.user.mentor
    @recruit_cat.should     be_viewable_by(mentor)
    @recruit_cat.should_not be_destroyable_by(mentor)
    @recruit_cat.should_not be_updatable_by(mentor)
    @recruit_cat.should_not be_editable_by(mentor)
  end

  it "should deny other users to CUD, edit and view user categories" do
    deny_all(users - [@recruit, @admin, @recruiter, @mentor], @recruit_cat)
  end
end
