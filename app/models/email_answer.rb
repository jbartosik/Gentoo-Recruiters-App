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
# Model storing answers for questions with email content.
# No user is allowed to do anything except viewing.
class EmailAnswer < Answer
  fields do
    correct :boolean
  end

  # Users can't change Email answers - app does it internally
  multi_permission(:create, :update, :destroy, :edit){ false }

  # Creates new answer/ updates old answer
  # expects user to send email from address [s]he has given to app
  # and title in format "#{question.id}-#{user.token}"
  def self.answer_from_email(email)
    user = User.find_by_email_address(email.from)
    return if user.nil?

    subject       = /^([0-9]+)-(\w+)$/.match(email.subject)
    return if subject.nil?
    return unless user.token == subject.captures[1]

    question      = Question.first :conditions => { :id => subject.captures[0] }

    if(question.nil? || !question.content.is_a?(QuestionContentEmail))
      UserMailer.send_later(:deliver_unrecognized_email, user, email)
      return
    end

    # Fetch existing answer, if it doesn't exist create a new one
    # them mark it as incorrect (if it passes all tests it will be correct)
    answer          = question.answer_of(user)
    answer          = EmailAnswer.new(:question => question, :owner => user) if answer.nil?
    answer.correct  = false
    answer.save!

    for condition in question.content.req_array
      val     = email.send(condition[0].downcase.sub('-', '_'))  # Value we're testing
      cond    = /#{condition[1]}/i                              # Regexp value should match
      passed  = false                                           # Was test passed

      val = ['']  if val.is_a? NilClass
      val = [val] if val.is_a? String

      for v in val
        if v.match(cond)
          # Test passed
          passed = true
          break
        end
      end

      return unless passed
    end

    # passed all test - mark it and return answer
    answer.correct  = true
    answer.save!
    answer
  end
end
