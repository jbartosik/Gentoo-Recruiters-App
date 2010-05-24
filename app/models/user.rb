class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this

  fields do
    name          :string, :required, :unique
    email_address :email_address, :login => true
    administrator :boolean, :default => false
    role          Role, :default => 'recruit'
    timestamps
  end

  has_many    :user_categories
  has_many    :question_categories, :through => :user_categories, :accessible => true, :uniq => true
  has_many    :answers, :foreign_key => :owner_id
  has_many    :answered_questions, :through => :answers, :class_name => "Question", :source => :question

  belongs_to  :mentor, :class_name => "User"
  has_many    :recruits, :class_name => "User", :foreign_key => :mentor_id

  # This gives admin rights and recruiter role to the first sign-up.
  before_create { |user|
    if !Rails.env.test? && count == 0
      user.administrator  = true
      user.role           = :recruiter
    end }

  
  # --- Signup lifecycle --- #

  lifecycle do

    state :active, :default => true

    create :signup, :available_to => "Guest",
           :params => [:name, :email_address, :password, :password_confirmation],
           :become => :active
             
    transition :request_password_reset, { :active => :active }, :new_key => true do
      UserMailer.deliver_forgot_password(self, lifecycle.key)
    end

    transition :reset_password, { :active => :active }, :available_to => :key_holder,
               :params => [ :password, :password_confirmation ]

  end
  
  validate  :only_recruiter_can_be_administrator
  validate  :recruit_cant_mentor

  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    acting_user.administrator? ||
      (acting_user == self && only_changed?(:email_address, :crypted_password,
                                            :current_password, :password, :password_confirmation))||
      (User.user_is_recruiter?(acting_user) && only_changed?(:question_categories))
    # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
    # directly from a form submission.

  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  def self.user_is_recruiter?(user)
    user.signed_up? && user.role.is_recruiter?
  end

  def self.user_is_mentor_of?(user, recruit)
    user.signed_up? && recruit.mentor_is?(user)
  end

  def all_questions
    Question.find :all, :joins => {:question_category => :user_categories},
      :conditions => ['questions.question_category_id = user_categories.question_category_id AND user_categories.user_id = ?', id]
  end

  def unanswered_questions
    Question.find :all, :joins => {:question_category => {:user_categories => :user}},
    :conditions => [ 'users.id = ? AND NOT EXISTS ( ' +
    'SELECT * FROM answers WHERE answers.owner_id = ? AND answers.question_id = questions.id)', id, id]
  end

  def my_recruits_answers
    Answer.all :joins => :owner, :conditions => ['users.mentor_id = ?', id]
  end

  def my_recruits_answers_in_category(cat)
    Answer.all :joins => [:question, :owner], :conditions => ['questions.question_category_id = ? AND users.mentor_id = ?', cat, id]
  end

  protected

    def only_recruiter_can_be_administrator
      errors.add(:administrator, 'only recruiters can be administrators' )  if administrator and !role.is_recruiter?
    end

    def recruit_cant_mentor
      errors.add(:mentor, "recruit can't mentor" )  if mentor && mentor.role.is_recruit?
    end
end
