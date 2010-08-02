class Question < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title         :string, :null => false
    documentation :string
    approved      :boolean, :default => false
    timestamps
  end

  attr_readonly         :user
  validates_presence_of :title
  validates_length_of   :title, :minimum => 2
  #allow empty documentation and no category
  #maybe add a page for not complete questions

  belongs_to  :user, :creator => true
  belongs_to  :question_category
  belongs_to  :question_group
  has_many    :answers
  has_one     :reference_answer, :class_name => "Answer", :conditions => ["answers.reference = ?", true]
  has_many    :user_question_groups
  has_one     :question_content_text
  has_one     :question_content_multiple_choice
  has_one     :question_content_email

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
    # Don't allow viewing some fields on creation
    return false if new_record? && [:user, :approved].include?(field)

    # Unapproved questions can be seen only by recruiters and owner
    if !approved
      return user_is?(acting_user) || acting_user.role.is_recruiter?
    end

    # Allow viewing ungrouped questions to everybody
    return true if question_group.nil?

    # Deny viewing grouped qestions to guests, so we can assume that
    # acting_user is valid User instance in next tests
    return false unless acting_user.signed_up?

    # Allow viewing all questions to recruiters
    return true if acting_user.role.is_recruiter?

    # Allow viewing grouped question if it's associated with user
    return true if (UserQuestionGroup.find_by_user_and_question(acting_user.id, id).count) > 0

    # Allow viewing grouped question if one of user's recruits is associated with it
    return true if (UserQuestionGroup.find_by_mentor_and_question(acting_user.id, id).count) > 0

    false
  end

  named_scope :unanswered_ungrouped, lambda { |uid|{
      :joins => {:question_category => :user_categories},
      :conditions => [ 'user_categories.user_id = ? AND questions.question_group_id IS NULL ' +
      'AND NOT EXISTS (' +
      'SELECT * FROM answers WHERE answers.owner_id = ? AND answers.question_id = questions.id)',
      uid,uid]}}

  named_scope :unanswered_grouped, lambda { |uid|{
      :joins => :user_question_groups,
      :conditions => [ 'user_question_groups.user_id = ? AND NOT EXISTS (
      SELECT * FROM answers WHERE answers.owner_id = ? AND answers.question_id = questions.id)',
      uid, uid]}}

  named_scope :user_questions_in_group, lambda { |user_id, group_id| {
      :joins => {:user_question_groups => :user}, :conditions =>
      ['questions.question_group_id = ? AND users.id = ?', group_id, user_id]}}

  named_scope :id_is_not, lambda { |id|{
      :conditions => ['questions.id != ?', id]}}

  named_scope :ungrouped_questions_of_user, lambda { |user_id|{
    :joins => {:question_category => :user_categories},
    :conditions => ['user_categories.user_id = ? AND questions.question_group_id IS NULL', user_id]}}

  named_scope :grouped_questions_of_user, lambda { |user_id|{
      :joins => {:user_question_groups => :user}, :conditions =>
      ['users.id = ?', user_id]}}

  named_scope :suggested_questions, lambda { |user_id|{
    :conditions => { :user_id => user_id, :approved => false }}}

  named_scope :unanswered, lambda { |uid|{
      :joins => {:question_category => {:user_categories => :user}},
      :conditions => [ 'users.id = ? AND NOT EXISTS ( ' +
      'SELECT * FROM answers WHERE answers.owner_id = ? AND answers.question_id = questions.id)', uid, uid]}}

  named_scope   :with_content, :include => [:question_content_text,
    :question_content_multiple_choice, :question_content_email], :conditions =>
    'question_content_texts.id IS NOT NULL OR question_content_multiple_choices.id
    IS NOT NULL OR question_content_emails.id IS NOT NULL'

  named_scope :questions_to_approve, :conditions => { :approved => false }

  named_scope   :multiple_choice, :joins => :question_content_multiple_choice

  def answered?(user)
    answers.owner_is(user).not_reference.count > 0 if user.signed_up?
  end

  def answer_of(user)
    answers.owner_is(user).not_reference.first if user.signed_up?
  end

  def content
    question_content_text ||
      question_content_multiple_choice ||
      question_content_email
  end

  before_create{ |question|
    if question.user._?.administrator? || question.user_id.nil?
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
