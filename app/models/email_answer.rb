class EmailAnswer < Answer
  fields do
    correct :boolean
  end

  # Users can't change Email answers - app does it internally
  multi_permission(:create, :update, :destroy, :edit){ false }

  # Creates new answer/ updates old answer
  # expects user to send email from address [s]he has given to app
  # and title in format "answer for \"#{question.title}\""
  def self.answer_from_email(email)
    user = User.find_by_email_address(email.from)
    return if user.nil?

    tile_prefix   = 'answer for '
    question      = Question.find_by_title email.subject[(tile_prefix.size + 1)..-2]
    return if     question.nil?
    return unless question.content.class == QuestionContentEmail

    # Fetch existing answer, if it doesn't exist create a new one
    # them mark it as incorrect (if it passes all tests it will be correct)
    answer          = question.answer_of(user)
    answer          = EmailAnswer.new(:question => question, :owner => user) if answer.nil?
    answer.correct  = false
    answer.save!

    for condition in question.content.req_array
      val     = email.send(condition[0].downcase.sub('-','_'))  # Value we're testing
      cond    = /#{condition[1]}/i                              # Regexp value should match
      passed  = false                                           # Was test passed

      val = ['']  if val.class == NilClass
      val = [val] if val.class == String

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
