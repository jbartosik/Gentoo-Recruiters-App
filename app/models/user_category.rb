class UserCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end

  belongs_to :user
  belongs_to :question_category

  include Permissions::AnyoneCanViewRecruiterCanChange
end
