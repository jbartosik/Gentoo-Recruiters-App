require 'spec_helper.rb'
describe Receiver do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  it "should pass received emails to EmailAnswer#answer_from_email" do
    mail = "Some text"
    EmailAnswer.should_receive(:answer_from_email)
    Receiver.receive(mail.to_s)
  end
end
