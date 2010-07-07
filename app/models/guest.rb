class Guest < Hobo::Guest

  def administrator?
    false
  end

  def questions_to_approve
    []
  end
end
