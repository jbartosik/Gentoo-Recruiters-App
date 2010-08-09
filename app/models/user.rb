class User < ActiveRecord::Base

  hobo_user_model # Don't put anything above this

  fields do
    name          :string, :required, :unique
    email_address :email_address, :login => true
    administrator :boolean, :default => false
    role          Role, :default => 'recruit'
    nick          :string
    openid        :string
    contributions HoboFields::MarkdownString
    project_lead  :boolean, :default => false
    token         :string
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
    user_categories ON user_categories.question_category_id = cat.id  WHERE
    user_categories.user_id = users.id AND questions.question_group_id IS NULL AND NOT EXISTS (
    SELECT answers.id FROM answers WHERE answers.question_id = questions.id AND answers.owner_id = users.id))
    AND NOT EXISTS
    (SELECT questions.id FROM questions INNER JOIN user_question_groups ON questions.id = user_question_groups.question_id
     WHERE user_question_groups.user_id = users.id AND NOT EXISTS (
     SELECT answers.id FROM answers WHERE answers.question_id = questions.id AND answers.owner_id = users.id))"

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
  validate                :mentor_is_gentoo_dev_long_enough
  validates_uniqueness_of :nick, :if => :nick
  validates_uniqueness_of :openid, :if => :openid

  never_show              :project_lead

  # Token
  never_show              :token

  # Generate new token
  def token=(more_salt)
    # Time.now.to_f.to_s gives enough precision to be considered random
    token = Digest::SHA1.hexdigest("#{Time.now.to_f.to_s}#{@salt}#{more_salt}")
    write_attribute("token", token)
    token
  end

  # Give user token on creation
  before_create do |u|
    u.token = ''
  end

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
    return true if acting_user.administrator?
    return true if acting_user == self && changes_allowed_to_self?
    return true if acting_user.role.is_recruiter? && changes_allowed_for_recruiter?
    return true if role.is_recruit? && acting_user.role.is_mentor? && mentor_picked_up_or_resigned?
  end

  def role_edit_permitted?
    acting_user.role.is_recruiter?
  end

  def mentor_edit_permitted?
    return true if mentor_is?(acting_user)
    return true if mentor.nil? && acting_user.role.is_mentor?
    return true if mentor.nil? && acting_user.role.is_recruiter?
    return true if acting_user.administrator?
    false
  end

  def destroy_permitted?
    acting_user.administrator?
  end

  def view_permitted?(field)
    true
  end

  def all_questions
    Question.ungrouped_questions_of_user(id) + Question.grouped_questions_of_user(id)
  end

  def unanswered_questions
    Question.unanswered_grouped(id) + Question.unanswered_ungrouped(id)
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

  def answered_all_multi_choice_questions?
    Question.multiple_choice.ungrouped_questions_of_user(id).unanswered(id).count == 0 &&
      Question.multiple_choice.grouped_questions_of_user(id).unanswered(id).count == 0
  end

  def required_questions_count
    Question.ungrouped_questions_of_user(id).count + Question.grouped_questions_of_user(id).count
  end

  def required_unanswered_count
    Question.unanswered_grouped(id).count + Question.unanswered_ungrouped(id).count
  end

  def required_answered_count
    self.required_questions_count - self.required_unanswered_count
  end

  def progress
    "Answered #{self.required_answered_count} of #{self.required_questions_count} questions."
  end

  before_create do |u|
    # Users using OpenID from dev.gentoo.org are mentors
    # Note that this doesn't make sure user can authenticate with
    # specified OpenID.
    match = /^https:\/\/dev.gentoo.org\/~(\w+)$/i.match(u.openid)
    if match
      u.role = :mentor
      u.nick = match.captures.first
    end
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
      # make sure recruiters change only what they are allowed to
      return false unless only_changed?(:question_categories, :role, :nick)

      # and make sure change to role wasn't changed or was promotion of recruit
      # to mentor or demotion of mentor to recruit
      return true unless role_changed?
      return true if role.is_mentor? && Role.new(role_was).is_recruit?
      return true if role.is_recruit? && Role.new(role_was).is_mentor?

      false
    end

    def changes_allowed_to_self?
      only_changed?(:email_address, :crypted_password, :current_password,
        :password, :password_confirmation, :nick, :contributions, :name)
        # Note: crypted_password has attr_protected so although it is permitted to change, it cannot be changed
        # directly from a form submission.
    end

    def mentor_picked_up_or_resigned?
      # Mentor picked up or resigned if
      #   only mentor attribute was changed
      #   and mentor changed from nil to acting user
      #   or mentor changed from nil to current user
      return false unless only_changed?(:mentor)
      return false unless (mentor_id_was.nil? || (mentor_id_was == acting_user.id))
      return false unless (mentor_id.nil? || (mentor_id == acting_user.id))

      true
    end

    def mentor_is_gentoo_dev_long_enough
      return unless role.is_mentor?                         # User isn't mentor
      return unless APP_CONFIG['developer_data']['check']   # Configured not to check

      dev_data_str    = APP_CONFIG['developer_data']['data']  # Data about developers from configuration
      if dev_data_str.nil?                                  # If there isn't any fetch it from configured location
        uri           = URI.parse(APP_CONFIG['developer_data']['uri'])
        dev_data_str  = Net::HTTP.get_response(uri).body
      end

      dev_data        = YAML::load(dev_data_str)['developers']
      max_join_date   = APP_CONFIG['developer_data']['min_months_mentor_is_dev'].to_i.months.ago.to_date

      for dev in dev_data
        if dev['nick'] == nick                              # Found dev
          joined  = dev['joined'].to_date
          return  if joined < max_join_date                 # Joined early enough: finish check, no errors
                                                            # Otherwise: finish check, report error
          errors.add(:role, "developer with provided nick can't be mentor yet (joined Gentoo less then
            #{ APP_CONFIG['min_months_mentor_is_dev']} months ago)")
          return
        end
      end

      errors.add(:nick, "not found this nick amoung Gentoo Developers.")
    end
end
