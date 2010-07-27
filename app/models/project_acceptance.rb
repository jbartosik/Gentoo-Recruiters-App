require 'permissions/set.rb'
class ProjectAcceptance < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    accepting_nick :string, :null => false
    accepted       :boolean, :default => false
    timestamps
  end

  belongs_to :user
  attr_readonly :user

  validates_presence_of   :user, :accepting_nick
  validates_uniqueness_of :accepting_nick, :scope => :user_id

  named_scope :find_by_user_name_and_accepting_nick, lambda { |user_name, accepting_nick| {
    :joins => :user, :conditions => ['users.name = ? AND accepting_nick = ?', user_name, accepting_nick] } }

  def create_permitted?
    # Recruiters can create project_acceptances
    # Project leads can create project_acceptances they should approve
    return true if acting_user.try.role.try.is_recruiter?
    return true if acting_user.try.project_lead && accepting_nick == acting_user.try.nick
    false
  end

  multi_permission :update, :destroy, :edit do
    # Allow admins everything
    return true if acting_user.try.administrator?

    # Allow users mentor and recruiters if not accepted and
    # accepted was not changed
    recruiter_user_or_mentor =  acting_user.try.role.try.is_recruiter? ||
                                user.try.mentor_is?(acting_user)

    return true if recruiter_user_or_mentor && !accepted && !accepted_changed?

    # Allow user with nick accepting_nick to change :accepted
    return true if (acting_user.try.nick ==  accepting_nick) && only_changed?(:accepted)

    # Allow CRU new records to recruiters and project leads
    return true if new_record? && acting_user.try.role.try.is_recruiter?
    return true if new_record? && acting_user.try.project_lead

    false
  end

  def view_permitted(field)
    # Allow user(relation), mentor of user and recruiters to view
     return true if user_is?(acting_user)
     return true if acting_user.try.role.try.is_recruiter?
     return true if user.mentor_is?(acting_user)

     false
  end

  # Returns new project acceptance with user = recruit, accepting_nick = lead.nick
  # if lead is marked as project_lead AND there isn't such a project acceptance yet
  def self.new_for_users(recruit, lead)
    return nil unless lead.try.project_lead
    return nil unless recruit.signed_up?
    return nil unless ProjectAcceptance.first(:conditions => { :accepting_nick => lead.nick, :user_id => recruit.id}).nil?
    ProjectAcceptance.new :accepting_nick => lead.nick, :user => recruit
  end
end
