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

  def new_question(user, question)
    common(user)
    @subject    = "New question"
    @body       = { :title=> question.title, :category => question.question_category,
      :id => question.id}
  end

  def new_answer(user, answer)
    common(user)
    @subject    = "New answer"
    @body       = { :question_title=> question_title(answer), :recruit_name =>
      answer.owner.name, :id => answer.id}
  end

  def changed_answer(user, answer)
    common(user)
    @subject    = "Changed answer"
    @body       = { :question_title=> question_title(answer), :recruit_name =>
      answer.owner.name, :id => answer.id}
  end

  def new_comment(user, comment)
    common(user)
    @subject    = "New comment"
    @body       = { :question_title=> question_title(comment.answer), :id => comment.answer.id }
  end

  def receive(email)
    EmailAnswer.answer_from_email(email) if /answer/.match(email.subject)
  end
end
