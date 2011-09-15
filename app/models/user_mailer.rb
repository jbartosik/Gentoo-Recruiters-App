#    Gentoo Recruiters Web App - to help Gentoo recruiters do their job better
#   Copyright (C) 2010 Joachim Filip Bartosik
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, version 3 of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
class UserMailer < ActionMailer::Base
  def common(user, subject)
    @recipients = user.email_address
    @from       = "no-reply@#{ ActionMailer::Base.default_url_options[:host] }"
    @sent_on    = Time.now
    @headers    = {}
    @subject    = subject
  end

  def question_title(answer)
    answer.question._?.title || "none"
  end

  def forgot_password(user, key)
    common(user, "#{@app_name} -- forgotten password")
    @body = { :user => user, :key => key, :app_name => @app_name,
              :host => default_url_options[:host],
              :port => default_url_options[:port] }
  end

  def new_question(user, question)
    common(user, "New question")
    @body = { :title=> question.title, :id => question.id}
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

  def new_user(to, new_user)
    user = User.new :email_address => to
    common(user, "New user")
    @body = { :name => new_user.name, :id => new_user.id }
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
end
