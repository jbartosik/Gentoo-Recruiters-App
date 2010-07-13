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

  def unrecognized_email(user, email)
    common(user, "Your email sent to #{@app_name} wasn't recognized")

    fields          = [:subject, :from, :to].inject(String.new) do |res, cur|
      field_name    = cur.to_s.camelize
      field_content = email.send(cur)

      if field_content.class == Array # string with comma-separated values
        field_content = field_content.inject(String.new){ |r,c| r += "#{c.to_s}, " }
        field_content = field_content[0..-3]
      end

      res += "#{field_name}: #{field_content}\n"
    end

    @body = { :email => email, :app_name => @app_name, :fields => fields }
  end

  def receive(email)
    # For now email answers for questions are only emails app receives
    # so try use any received email as answer.
    EmailAnswer.answer_from_email(email)
  end
end
