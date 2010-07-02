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
    (owned? && !reference && !approved) ||
    (reference && acting_user.role.is_recruiter?) ||
    (only_changed?(:approved) && owner.mentor_is?(acting_user))
  end

  def create_permitted?
    (owned_soft? && !reference)||(reference && acting_user.role.is_recruiter?)
  end

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

  def view_permitted?(field)
    owned_soft? ||
      User.user_is_recruiter?(acting_user)||
      User.user_is_mentor_of?(acting_user, owner)
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
  protected
    def notify_new_answer
      UserMailer.deliver_new_answer(owner.mentor, self)unless owner.mentor.nil?
    end

    def notify_changed_answer
      UserMailer.deliver_changed_answer owner.mentor, self
    end
end
