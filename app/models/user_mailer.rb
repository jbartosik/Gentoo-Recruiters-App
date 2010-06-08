class UserMailer < ActionMailer::Base
  def common(user)
    @recipients = user.email_address
    @from       = "no-reply@#{ ActionMailer::Base.default_url_options[:host] }"
    @sent_on    = Time.now
    @headers    = {}
  end

  def question_title(answer)
    if answer.question.nil?
      "none"
    else
      answer.question.title
    end
  end

  def forgot_password(user, key)
    common(user)
    @subject    = "#{@app_name} -- forgotten password"
    @body       = { :user => user, :key => key, :app_name => app_name }
  end

  def new_answer(user, answer)
    common(user)
    @subject    = "New answer"
    @body       = { :question_title=> question_title(answer), :recruit_name =>
      answer.owner.name, :id => answer.id}
  end
end
