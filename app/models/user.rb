class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this

  fields do
    name          :string, :required, :unique
    email_address :email_address, :login => true
    administrator :boolean, :default => false
    role          Role, :default => 'recruit'
    nick          :string
    contributions :text
    timestamps
  end

  has_many    :user_categories
  has_many    :user_question_groups
  has_many    :question_categories, :through => :user_categories, :accessible => true, :uniq => true
  has_many    :grouped_questions, :through => :user_question_groups
  has_many    :answers, :foreign_key => :owner_id
  has_many    :answered_questions, :through => :answers, :class_name => "Question", :source => :question
  has_many    :project_acceptances, :accessible => true, :uniq => true

  belongs_to  :mentor, :class_name => "User"
  has_many    :recruits, :class_name => "User", :foreign_key => :mentor_id

  named_scope :mentorless_recruits, :conditions => { :role => 'recruit', :mentor_id => nil}
  named_scope :recruits_answered_all, :conditions => "role = 'recruit' AND NOT EXISTS
    (SELECT questions.id FROM questions
    INNER JOIN question_categories cat ON questions.question_category_id = cat.id INNER JOIN
    user_categories ON user_categories.question_category_id = cat.id LEFT OUTER JOIN
    answers ON answers.question_id = questions.id AND answers.owner_id = users.id WHERE
    user_categories.user_id = users.id AND answers.id IS NULL AND questions.question_group_id IS NULL)
    AND NOT EXISTS
    (SELECT questions.id FROM questions INNER JOIN user_question_groups ON questions.id = user_question_groups.question_id
    LEFT OUTER JOIN answers ON answers.question_id = questions.id AND answers.owner_id = users.id
     WHERE user_question_groups.user_id = users.id AND answers.id IS NULL)"

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
  
  validate                :only_recruiter_can_be_administrator
  validate                :recruit_cant_mentor
  validate                :mentors_and_recruiters_must_have_nick
  validates_uniqueness_of :nick, :if => :nick
  # --- Permissions --- #

  def create_permitted?
    false
  end

  def update_permitted?
    # Allow edit in one of four cases:
      # Acting user is administrator
      # Acting user is editing his/her self and changes only what [s]he is allowed to
      # Acting user is recruiter and changes only what [s]he is allowed to
      # Acting user was mentor of edited user and resigned
      # Acting user became mentor of edited recruit and edited user had no mentor
    acting_user.administrator? ||
      (acting_user == self && changes_allowed_to_self?)||
      (User.user_is_recruiter?(acting_user) && changes_allowed_for_recruiter?)||
      (role.is_recruit? && acting_user.try.role.try.is_mentor? && mentor_picked_up_or_resigned?)
  end

  def role_edit_permitted?
    acting_user.role.is_recruiter?
  end

  def mentor_edit_permitted?
    mentor.nil? || mentor_is?(acting_user)
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
    Question.ungrouped_questions_of_user(id) + Question.grouped_questions_of_user(id)
  end

  def unanswered_questions
    Question.unanswered_grouped(id) + Question.unanswered_ungrouped(id)
  end

  def my_recruits_answers
    Answer.all :joins => :owner, :conditions => ['users.mentor_id = ?', id]
  end

  def my_recruits_answers_in_category(cat)
    Answer.all :joins => [:question, :owner], :conditions => ['questions.question_category_id = ? AND users.mentor_id = ?', cat, id]
  end

  def answered_all_questions?
    Question.unanswered_grouped(id).count.zero? && Question.unanswered_ungrouped(id).count.zero?
  end

  def any_pending_project_acceptances?
    (ProjectAcceptance.count :conditions => { :accepting_nick => nick }) > 0
  end

  # This returns named scope, so it's efficient to use
  #   some_user.questions_to_approve.count
  def questions_to_approve
    if administrator?
      Question.questions_to_approve
    else
      []
    end
  end

  def answered_all_multi_choice
    Question.multiple_choice.ungrouped_questions_of_user(id).unanswered(id).count == 0 &&
      Question.multiple_choice.grouped_questions_of_user(id).unanswered(id).count == 0
  end

  protected

    def only_recruiter_can_be_administrator
      errors.add(:administrator, 'only recruiters can be administrators')  if administrator and !role.is_recruiter?
    end

    def recruit_cant_mentor
      errors.add(:mentor, "recruit can't mentor")  if mentor && mentor.role.is_recruit?
    end

    def mentors_and_recruiters_must_have_nick
      if (role.is_mentor? || role.is_recruiter?) && (nick.nil? || nick.empty?)
        errors.add(:nick, "Mentors and administrators must have nicks set")
      end
    end

    def changes_allowed_for_recruiter?
      only_allowed_changed  = only_changed?(:question_categories, :role, :nick)
      promoted_to_mentor    = role.is_mentor? && Role.new(role_was).is_recruit?
      demoted_mentor        = role.is_recruit? && Role.new(role_was).is_mentor?
      only_allowed_changed && (!role_changed? || promoted_to_mentor || demoted_mentor)
    end

    def changes_allowed_to_self?
      only_changed?(:email_address, :crypted_password, :current_password,
        :password, :password_confirmation, :nick, :contributions)
        # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
        # directly from a form submission.
    end

    def mentor_picked_up_or_resigned?
      # Mentor picked up or resigned if
      #   only mentor attribute was changed
      #   and mentor was nil or acting user
      #   and mentor is nil or current user
      only_changed?(:mentor) &&
      (mentor_id_was.nil? || (mentor_id_was == acting_user.try.id)) &&
      (mentor_id.nil? || (mentor_id == acting_user.try.id))
    end
end
