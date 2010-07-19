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

  multi_permission :create, :update, :destroy, :edit do
    # Allow admins everything
    return true if acting_user.try.administrator?

    # Allow users mentor and recruiters if not accepted and
    # accepted was not changed
    recruiter_user_or_mentor =  acting_user.try.role.try.is_recruiter? ||
                                user.try.mentor_is?(acting_user)

    return true if recruiter_user_or_mentor && !accepted && !accepted_changed?

    # Allow user with nick accepting_nick to change :accepted
    return true if (acting_user.try.nick ==  accepting_nick) && only_changed?(:accepted)

    false
  end

  def view_permitted(field)
    # Allow user(relation), mentor of user and recruiters to view
     return true if user_is?(acting_user)
     return true if acting_user.try.role.try.is_recruiter?
     return true if user.mentor_is?(acting_user)

     false
  end
end
