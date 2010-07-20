class UserMailer < ActionMailer::Base
  def common(user, subject)
    @recipients = user.email_address
    @from       = "no-reply@#{ ActionMailer::Base.default_url_options[:host] }"
    @sent_on    = Time.now
    @headers    = {}
    @subject    = subject
  end

  def question_title(answer)
    answer.question.try.title || "none"
  end

  def forgot_password(user, key)
    common(user, "#{@app_name} -- forgotten password")
    @body = { :user => user, :key => key, :app_name => app_name }
  end

  def new_question(user, question)
    common(user, "New question")
    @body = { :title=> question.title, :category => question.question_category,
      :id => question.id}
  end

  def new_answer(user, answer)
    common(user, "New answer")
    @body = { :question_title=> question_title(answer), :recruit_name =>
      answer.owner.name, :id => answer.id}
  end

  def changed_answer(user, answer)
    common(user, "Changed answer")
    @body = { :question_title=> question_title(answer), :recruit_name =>
      answer.owner.name, :id => answer.id}
  end

  def new_comment(user, comment)
    common(user, "New comment")
    @body = { :question_title=> question_title(comment.answer), :id => comment.answer.id }
  end
end
