require 'permissions/owned_model.rb'
class Answer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content :text
    timestamps
  end

  belongs_to  :question

  validates_uniqueness_of :question_id, :scope => :owner_id

  owned_model owner_class = "User"

  def view_permitted?(field)
    owned_soft? ||
      User.user_is_recruiter?(acting_user)||
      User.user_is_mentor_of?(acting_user, owner)
  end
end
