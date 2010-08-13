require 'permissions/owned_model.rb'
require 'permissions/set.rb'
# Model storing answers for questions with text content.
# Hooks:
#  * After creation notification is sent to mentor of owner of the answer
#  * After update notification is sent to mentor of owner of the answer
#  * If content of answer was changed it becomes un-approved
#
# Validations:
#  * There can be only one reference answer for each question
#  * User can give only one non-reference answer for each question
class Answer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content   HoboFields::MarkdownString, :null => false, :default => ''
    approved  :boolean, :default => false
    reference :boolean, :default => false
    feedback  HoboFields::EnumString.for('', 'Documentation ok',
                  'Could not find documentation', 'Documentation insufficient'),
                  :default => ''
    timestamps
  end

  attr_readonly :reference
  belongs_to    :question, :null => false
  has_many      :comments

  named_scope   :of_mentored_by, lambda { |mentor| {
    :joins => :owner, :conditions => { 'users.mentor_id', mentor } } }

  named_scope   :in_category, lambda { |category| {
    :joins => :question, :conditions => { 'questions.question_category_id', category} } }

  validates_uniqueness_of :question_id, :scope => :reference, :if => :reference
  validates_uniqueness_of :question_id, :scope => :owner_id, :unless => :reference

  owned_model owner_class = "User"

  before_validation do |record|
    record.approved = false if record.content_changed?
  end

  after_create :notify_new_answer
  after_update :notify_changed_answer

  multi_permission :update, :destroy do
    # It's fine to change correct, because it's ignored in non-email answers
    # and email answers have separate permissions
    (owned? && !reference && !approved) ||
    (reference && acting_user.role.is_recruiter?) ||
    (only_changed?(:approved, :correct) && owner.mentor_is?(acting_user))
  end

  def create_permitted?
    (owned_soft? && !reference)||(reference && acting_user.role.is_recruiter?)
  end

  # Proper edit permissions can't be deduced, because we need to access value
  # of some fields to set them
  def edit_permitted?(field)
    owned_soft? ||
    owner.mentor_is?(acting_user) ||
    (reference && acting_user.signed_up? && acting_user.role.is_recruiter?)
  end

  def content_edit_permitted?
    owned_soft? ||
    (reference && acting_user.signed_up? && acting_user.role.is_recruiter?)
  end

  def feedback_edit_permitted?
    owned_soft?
  end

  def approved_edit_permitted?
    owner.mentor_is?(acting_user)
  end

  def reference_edit_permitted?
    acting_user.role.is_recruiter?
  end

  def view_permitted?(field)
    owned_soft? ||
      acting_user.role.is_recruiter? ||
      owner._?.mentor_is?(acting_user)
  end

  # Returns hash containing updated answer attributes.
  def self.update_from(params)
    ans     = Answer.find(params['id'])
    result  = ans.attributes

    params[ans.class.to_s.underscore]._?.each{ |u| result[u[0]] = u[1] }

    result
  end

  # Returns new answer deducing type and attributes from params
  def self.new_from(params)
    for klass in [Answer, MultipleChoiceAnswer]
      name = klass.to_s.underscore
      return klass.new(params[name]) if params.include? name
    end
  end

  # Returns wrong answers of given user
  def self.wrong_answers_of(uid)
    MultipleChoiceAnswer.find_by_sql ["SELECT ans.* FROM answers ans, answers ref WHERE
      ref.reference = ? AND ans.question_id = ref.question_id AND
      ans.content != ref.content AND ans.owner_id = ?", true, uid]
  end

  protected
    # Sends email notification about new answer to mentor of owner
    def notify_new_answer
      UserMailer.deliver_new_answer(owner.mentor, self) unless owner._?.mentor.nil?
    end

    # Sends email notification about changed answer to mentor of owner
    def notify_changed_answer
      UserMailer.deliver_changed_answer(owner.mentor, self) unless owner._?.mentor.nil?
    end

end
