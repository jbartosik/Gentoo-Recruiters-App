require 'spec_helper.rb'
describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  it "should prepare proper new question notification" do
    question  = Factory(:question)
    recruit   = Factory(:recruit)
    notification = UserMailer.create_new_question(recruit, question)
    notification.should deliver_to(recruit.email_address)
    notification.should deliver_from("no-reply@localhost")
    notification.should have_text(/There is a new question "#{question.title}"/)
    notification.should have_text(/in category "#{question.question_category.name}" you are assigned to./)
    notification.should have_text(/http:\/\/localhost:3000\/questions\/#{question.id}/)
    notification.should have_subject('New question')
  end

  it "should prepare proper new answer notification" do
    answer = Factory(:answer)
    notification = UserMailer.create_new_answer(answer.owner.mentor, answer)
    notification.should deliver_to(answer.owner.mentor.email_address)
    notification.should deliver_from("no-reply@localhost")
    notification.should have_text(/Recruit you are mentoring - #{answer.owner.name}/)
    notification.should have_text(/answered question "#{answer.question.title}"/)
    notification.should have_text(/http:\/\/localhost:3000\/answers\/#{answer.id}/)
    notification.should have_subject('New answer')
  end

  it "should prepare proper changed answer notification" do
    answer = Factory(:answer)
    notification = UserMailer.create_changed_answer(answer.owner.mentor, answer)
    notification.should deliver_to(answer.owner.mentor.email_address)
    notification.should deliver_from("no-reply@localhost")
    notification.should have_text(/Recruit you are mentoring - #{answer.owner.name}/)
    notification.should have_text(/edited answer for question "#{answer.question.title}"/)
    notification.should have_text(/http:\/\/localhost:3000\/answers\/#{answer.id}/)
    notification.should have_subject('Changed answer')
  end

  it "should prepare proper new comment notification" do
    comment      = Factory(:comment)
    notification = UserMailer.create_new_comment(comment.answer.owner, comment)
    notification.should deliver_to(comment.answer.owner.email_address)
    notification.should deliver_from("no-reply@localhost")
    notification.should have_text(/Your mentor made a comment on your answer for question "#{comment.answer.question.title}"/)
    notification.should have_text(/http:\/\/localhost:3000\/answers\/#{comment.answer.id}/)
    notification.should have_subject('New comment')
  end

  it "should prepare proper unrecognized message email" do
    user          = Factory(:recruit)
    mail          = TMail::Mail.new
    mail.subject  = "some subject"
    mail.from     = user.email_address
    mail.to       = ["a@a.a", "b@b.b"]
    notification  = UserMailer.create_unrecognized_email(user, mail)

    notification.should have_subject("Your email sent to #{@app_name} wasn't recognized")
    notification.should deliver_from("no-reply@localhost")
    notification.should deliver_to(user.email_address)

    notification.should have_text(/You sent email to #{@app_name} with following headers:/)
    notification.should have_text(/From: #{user.email_address}/)
    notification.should have_text(/To: a@a.a, b@b.b/)
    notification.should have_text(/Subject: some subject/)
    # don't test rest of the message
    notification.should have_text(/If you are answering question check if your message has proper subject./)
  end
end
