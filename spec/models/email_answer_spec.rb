require 'spec_helper.rb'
describe EmailAnswer do
  it "should send email notification when parses answer for unrecognized question from known user" do
    recruit       = Factory(:recruit)
    question      = Factory(:question)
    mail          = TMail::Mail.new
    mail.subject  = "#{question.id + 1}-#{recruit.token}"
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

  it "should properly recognize invalid answer" do
    recruit       = Factory(:recruit)
    question      = Factory(:question)
                    Factory(:question_content_email, :question => question, :req_text => "To : test@example.com")
    mail          = TMail::Mail.new
    mail.subject  = "#{question.id}-#{recruit.token}"
    mail.from     = recruit.email_address

    EmailAnswer.answer_from_email(mail)
    Answer.last.correct.should be_false
  end

  it "should properly recognize valid answer" do
    recruit       = Factory(:recruit)
    question      = Factory(:question)
                    Factory(:question_content_email, :question => question, :req_text => "To : test@example.com")
    mail          = TMail::Mail.new
    mail.subject  = "#{question.id}-#{recruit.token}"
    mail.from     = recruit.email_address
    mail.to       = "test@example.com"

    EmailAnswer.answer_from_email(mail)
    Answer.last.correct.should be_true
  end
end
