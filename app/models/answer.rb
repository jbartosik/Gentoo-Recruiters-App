require 'permissions/owned_model.rb'
require 'permissions/set.rb'
class Answer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content   :text
    approved  :boolean, :default => false
    reference :boolean, :default => false
    timestamps
  end
  attr_readonly :reference
  belongs_to    :question
  has_many      :comments

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

  def approved_edit_permitted?
    owner.mentor_is?(acting_user)
  end

  def reference_edit_permitted?
    acting_user.try.role.try.is_recruiter?
  end

  def view_permitted?(field)
    owned_soft? ||
      User.user_is_recruiter?(acting_user)||
      User.user_is_mentor_of?(acting_user, owner)
  end

  def self.update_from(params)
   ans = Answer.find(params['id'])

  if ans.class == Answer
    update = params["answer"] || []
  elsif ans.class == MultipleChoiceAnswer
    params["multiple_choice_answer"] = {} unless params["multiple_choice_answer"]
    params["multiple_choice_answer"]["options"] = params["options"].inject(Array.new){ |a, cur| a.push cur.to_i }
    update = params["multiple_choice_answer"]
  end

   result = ans.attributes

   for u in update
    result[u[0]] = u[1]
   end

   result
  end

  def self.new_from(params)

    if params.include? "answer"
      Answer.new params["answer"]
    elsif params.include? "multiple_choice_answer"
      ans_hash            = params["multiple_choice_answer"]
      new_ans             = MultipleChoiceAnswer.new  ans_hash
      new_ans.options     = params["options"].inject(Array.new){ |a, cur| a.push cur.to_i }
      return new_ans
    end

  end

  def self.wrong_answers_of(uid)
    Answer.find_by_sql ["SELECT ans.* FROM answers ans, answers ref WHERE
      ref.reference = 't' AND ans.question_id = ref.question_id AND
      ans.content != ref.content AND ans.owner_id = ?", uid]
  end

  protected
    def notify_new_answer
      UserMailer.deliver_new_answer(owner.mentor, self) unless owner.mentor.nil?
    end

    def notify_changed_answer
      UserMailer.deliver_changed_answer(owner.mentor, self) unless owner.mentor.nil?
    end

end
