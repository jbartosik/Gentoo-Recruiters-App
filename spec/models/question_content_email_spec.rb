require 'spec_helper.rb'
describe QuestionContentEmail do
  it "should properly return empty reuqirements" do
    Factory(:question_content_email).req_array.should == []
  end

  it "should properly return requirements as string and as html" do
    content = Factory(:question_content_email)
    content.req_text = "To : example@example.com\nReply-to : reply@example.com"
    content.req_text.should == "To : example@example.com\nReply-to : reply@example.com\n"
    content.req_html.should == "To : example@example.com<br/>\nReply-to : reply@example.com\n"
  end
end
