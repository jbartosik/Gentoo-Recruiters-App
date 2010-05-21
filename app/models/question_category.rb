class QuestionCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end

  has_many :questions

  include Permissions::AnyoneCanViewRecruiterCanChange
end
