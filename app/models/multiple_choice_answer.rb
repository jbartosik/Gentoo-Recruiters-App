class MultipleChoiceAnswer < Answer
  def options
    if @options.nil?
      @options          = RichTypes::CheckList.new(question.content.options)
      @options.options  = content.to_s
    end
    @options
  end

  def options=(what)
    self.options
    @options.options = what
    self.content = @options.to_s
  end
end
