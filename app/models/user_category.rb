require 'permissions/set.rb'
class UserCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :user
  belongs_to :question_category

  validates_uniqueness_of :user_id, :scope => :question_category_id

  multi_permission :create, :update, :destroy do
    User.user_is_recruiter?(acting_user) || user_is?(acting_user)
  end

  def view_permitted?(field)
    User.user_is_recruiter?(acting_user) ||
      user_is?(acting_user)||
      user.mentor_is?(acting_user)
  end
end
