require 'spec_helper.rb'
describe QuestionGroup do

  include Permissions::TestPermissions

  it "should prohibit CRUD to all users" do
    deny_all(fabricate_all_roles + [Guest.new]){ |user|
      UserQuestionGroup.new :user => user, :question => Factory(:question,
        :question_group => Factory(:question_group))}
  end

  it "should be valid if question has group and user isn't associated with any other question from that group" do
    user  = Factory(:recruit)
    group = Factory(:question_group)

    user_q_group = UserQuestionGroup.new :user => user, :question =>
      Factory(:question, :question_group => group)
    user_q_group.should be_valid
    user_q_group.save!
    user_q_group.should be_valid

    Factory(:user_question_group, :user => user, :question =>
      Factory(:question, :question_group => Factory(:question_group)))

    user_q_group.should be_valid
  end

  it "should be invalid if question has no group" do
    user  = Factory(:recruit)

    user_q_group = UserQuestionGroup.new :user => user, :question =>
      Factory(:question, :question_group => nil)
    user_q_group.should_not be_valid
  end

  it "should be invalid if user is associated with other question from that group" do
    user  = Factory(:recruit)
    group = Factory(:question_group)

    Factory(:user_question_group, :user => user, :question =>
      Factory(:question, :question_group => group))

    user_q_group = UserQuestionGroup.new :user => user, :question =>
      Factory(:question, :question_group => group)
    user_q_group.should_not be_valid
  end
end
