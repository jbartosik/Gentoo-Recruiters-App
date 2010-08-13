require 'spec_helper.rb'
describe QuestionContentMultipleChoice do
  it "should prepare proper new answer of user" do
    recruit = Factory(:recruit)
    q       = Factory(:question)
    Factory(:question_content_multiple_choice, :question => q)
    q.reload
    ans = q.content.new_answer_of(recruit)
    ans.owner_is?(recruit).should be_true
    ans.question_is?(q).should be_true
    ans.is_a?(MultipleChoiceAnswer).should be_true
  end
end
