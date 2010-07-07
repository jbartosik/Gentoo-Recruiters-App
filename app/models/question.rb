class Question < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title         :string
    content       :text
    documentation :string
    approved      :boolean, :default => false
    timestamps
  end

  attr_readonly         :user
  validates_presence_of :title, :content
  #allow empty documentation and no category
  #maybe add a page for not complete questions

  belongs_to  :user, :creator => true
  belongs_to  :question_category
  has_many    :answers
  has_one     :reference_answer, :class_name => "Answer", :conditions => ["answers.reference = ?", true]
  include Permissions::AnyoneCanViewAdminCanChange

  multi_permission :create, :update, :destroy do
    # Allow changes if user is administrator
    return true if acting_user.administrator?

    # if user owns question and it isn't approved yet
    if !approved && user_is?(acting_user)
      # everything is changed when it's a new record
      return true if new_record?

      # when it's not new record allow changing only some properties
      return only_changed?(:title, :content, :documentation, :question_category)
    end

    false
  end

  def view_permitted?(field)
    # Unapproved questions can be seen only by recruiters and owner
    if !approved
      return user_is?(acting_user) || acting_user.try.role.try.is_recruiter?
    end

    true
  end

  named_scope   :suggested_questions, lambda { |user_id|{
    :conditions => { :user_id => user_id, :approved => false }}}

  named_scope  :unanswered, lambda { |uid|{
      :joins => {:question_category => {:user_categories => :user}},
      :conditions => [ 'users.id = ? AND NOT EXISTS ( ' +
      'SELECT * FROM answers WHERE answers.owner_id = ? AND answers.question_id = questions.id)', uid, uid]}}

  named_scope   :questions_to_approve, :conditions => { :approved => false }

  def answered?(user)
    user.signed_up? && user.answered_questions.include?(self)
  end

  def answer_of(user)
    answers.owner_is(user).not_reference.first if user.signed_up?
  end

  before_create{ |question|
    if question.user.try.role.try.is_recruiter || question.user_id.nil?
      question.approved = true
    end
  }
  after_create  :notify_new_question
  after_update  :notify_approved_question

  protected
    def notify_new_question
      # If question category isn't assigned don't try to access it
      if question_category && approved
        for user in question_category.users
          UserMailer.deliver_new_question user, self
        end
      end
    end

    def notify_approved_question
      if question_category && !approved_was && approved
        notify_new_question
      end
    end

end
