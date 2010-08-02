class Guest < Hobo::Guest
  def administrator?; false; end
  def answered_questions; []; end
  def any_pending_acceptances?; false; end
  def id; nil; end
  def mentor; nil; end
  def mentor_is?(x); false; end
  def nick; nil; end
  def project_lead; false; end
  def questions_to_approve; []; end
  def role; Role.new(:guest); end
  def token; nil; end
end
