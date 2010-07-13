require 'spec_helper.rb'
describe EmailAnswer do
  it "should send email notification when parses answer for unrecognized question from known user" do
    recruit       = Factory(:recruit)
    mail          = TMail::Mail.new
    mail.subject  = "some subject"
    mail.from     = recruit.email_address

    UserMailer.should_receive(:deliver_unrecognized_email).with(recruit, mail)
    EmailAnswer.answer_from_email(mail)
  end

  it "should send email notification when parses answer for non-email question from known user" do
    recruit       = Factory(:recruit)
    question      = Factory(:question)
    mail          = TMail::Mail.new
    mail.subject  = "#{question.id}-#{recruit.token}"
    mail.from     = recruit.email_address

    UserMailer.should_receive(:deliver_unrecognized_email).with(recruit, mail)
    EmailAnswer.answer_from_email(mail)
  end
end
