require 'permissions/owned_model.rb'
class Answer < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content :text
    timestamps
  end

  belongs_to  :question

  owned_model owner_class = "User"

  def view_permitted?(field)
    owned_soft? || Permissions::AnyoneCanViewRecruiterCanChange.user_is_recruiter?(acting_user)
  end
end
