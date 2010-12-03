class Receiver
  def self.receive(text)
    # For now email answers for questions are only emails app receives
    # so try use any received email as answer.
    EmailAnswer.answer_from_email(Mail::Message.new(text))
  end
end
