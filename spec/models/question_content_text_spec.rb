require 'spec_helper.rb'
describe QuestionContentText do
  it "should prepare proper new anser of user" do
    recruit = Factory(:recruit)
    q       = Factory(:question)
    Factory(:question_content_text, :question => q)
    q.reload
    ans = q.content.new_answer_of(recruit)
    ans.owner_is?(recruit).should be_true
    ans.question_is?(q).should be_true
    ans.is_a?(Answer).should be_true
  end
end
