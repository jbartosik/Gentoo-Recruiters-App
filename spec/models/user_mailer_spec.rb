require 'spec_helper.rb'
describe UserMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  fixtures :users, :questions, :answers

  before (:each) do
    @recruit  = users(:ron)
    @question = questions(:banana)
    @answer   = answers(:banana)
  end

  it "should prepare proper new answer notification" do
    notification = UserMailer.create_new_answer(@recruit.mentor, @answer)
    notification.should deliver_to(@recruit.mentor.email_address)
    notification.should deliver_from("no-reply@localhost")
    notification.should have_text(/Recruit you are mentoring - #{@recruit.name}/)
    notification.should have_text(/answered question "#{@answer.question.title}"/)
    notification.should have_text(/http:\/\/localhost:3000\/answers\/#{@answer.id}/)
    notification.should have_subject('New answer')
  end
end
