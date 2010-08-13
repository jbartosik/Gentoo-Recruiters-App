# Model storing answers for questions with multiple choice content.
class MultipleChoiceAnswer < Answer
  # Returns RichTypes::CheckList describing given answer
  def options
    if @options.nil?
      @options          = RichTypes::CheckList.new(question.content.options)
      @options.options  = content.to_s
    end
    @options
  end

  # Sets new answer
  def options=(what)
    self.options
    @options.options = what
    self.content = @options.to_s
  end
end
