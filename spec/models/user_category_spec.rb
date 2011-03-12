require 'spec_helper.rb'
describe UserCategory do

  include Permissions::TestPermissions

  it "should allow logged in users to CUD, edit and view their categories" do
    for user in fabricate_all_roles
      user_category = Factory(:user_category, :user => user)
      user_category.should be_viewable_by(user)
      user_category.should be_creatable_by(user)
      user_category.should be_updatable_by(user)
      user_category.should be_destroyable_by(user)
      user_category.should be_editable_by(user)
    end
  end

  it "should prohibit guests to CUD, edit and view user categories" do
    deny_all([Guest.new], Factory(:user_category))
  end

  it "should allow recruiters to CUD, edit and view categories of anyone" do
    allow_all(fabricate_users(:recruiter, :administrator), Factory(:user_category))
  end

  it "should allow mentors of users to view categories but prohibit everything else" do
    user_cat = Factory(:user_category)
    mentor = user_cat.user.mentor
    user_cat.should     be_viewable_by(mentor)
    user_cat.should_not be_destroyable_by(mentor)
    user_cat.should_not be_updatable_by(mentor)
    user_cat.should_not be_editable_by(mentor)
  end

  it "should deny other users to CUD, edit and view user categories" do
    deny_all(fabricate_users(:recruit, :mentor) + [Guest.new], Factory(:user_category))
  end

  it "should allow everybody to view contributons" do
    for u in fabricate_all_roles + [Guest.new]
      Factory(:recruit).should be_viewable_by(u, :contributions)
    end
  end

  it "should allow to edit and update users own contributons" do
    recruit = Factory(:recruit)
    recruit.should        be_editable_by(recruit, :contributions)
    recruit.contributions = "changed"
    recruit.should        be_updatable_by(recruit)
  end

  it "should allow admins to edit and update users contributons" do
    recruit = Factory(:recruit)
    recruit.should        be_editable_by(Factory(:administrator), :contributions)
    recruit.contributions = "changed"
    recruit.should        be_updatable_by(Factory(:administrator))
  end

  it "should prohibit non-admins to edit and update someone else contributons" do
    recruit = Factory(:recruit)
    for u in fabricate_users(:recruit, :mentor, :recruiter) + [Guest.new]
      recruit.should_not    be_editable_by(u, :contributions)
      recruit.contributions = "changed"
      recruit.should_not    be_updatable_by(u)
    end
  end

  it "should associate user with one question from each group from category on creation" do
    category      = Factory(:category)
    groups_in_cat = []
    for n in 1..5
      groups_in_cat.push Factory(:question_group)
      for i in 1..n
        Factory(:question_category,
                :category => category,
                :question => Factory(:question, :question_group => groups_in_cat.last))
      end
    end

    for n in 1..5
        Factory(:question, :question_group => Factory(:question_group))
    end

    recruit = Factory(:recruit)
              Factory(:user_category, :user => recruit, :category => category)

    for group in groups_in_cat
      has_question_from_group = group.questions.inject(false) do |result, question|
        result |= (UserQuestionGroup.find_by_user_and_question(recruit.id, question.id).count > 0)
      end

      has_question_from_group.should be_true
    end
  end
end
