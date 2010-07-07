require 'spec_helper.rb'
describe QuestionGroup do

  include Permissions::TestPermissions

  it "should allow admin to create, edit, update and remove" do
    cud_allowed([Factory(:administrator)], Factory(:question_group))
  end

  it "should prohibit nonadmins to creating, editing, updating and removing" do
    cud_denied([Factory(:recruit), Factory(:mentor), Guest.new,
      Factory(:recruiter)], Factory(:question_group))
  end

  it "should be allowed for everybody to view" do
    view_allowed([Factory(:recruit), Factory(:mentor), Factory(:recruiter),
      Factory(:administrator), Guest.new], Factory(:question_group))
  end

  it "should return proper in_category results" do
    category      = Factory(:question_category)
    groups_in_cat = []
    for n in 1..5
      groups_in_cat.push Factory(:question_group)
      for i in 1..n
        Factory(:question, :question_category => category, :question_group => groups_in_cat.last)
      end
    end

    for n in 1..5
        Factory(:question, :question_group => Factory(:question_group))
    end

    groups = QuestionGroup.in_category(category.id).all
    (groups - groups_in_cat).should be_empty
    (groups_in_cat - groups).should be_empty
    groups.count.should == groups.uniq.count
  end

  it "should return proper unassociated_in_category results" do
    recruit       = Factory(:recruit)
    category      = Factory(:question_category)
    groups_in_cat = []
    for n in 1..5
      groups_in_cat.push Factory(:question_group)
      for i in 1..n
        Factory(:question, :question_category => category, :question_group => groups_in_cat.last)
      end
    end

    for n in 1..5
        Factory(:question, :question_group => Factory(:question_group))
    end

    Factory(:user_question_group, :user => recruit, :question => groups_in_cat.last.questions.first)
    groups_in_cat -= [groups_in_cat.last]

    groups = QuestionGroup.unassociated_in_category(recruit.id, category.id).all
    (groups - groups_in_cat).should be_empty
    (groups_in_cat - groups).should be_empty
    groups.count.should == groups.uniq.count
  end
end
