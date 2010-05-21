class Question < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title         :string
    content       :text
    documentation :string
    timestamps
  end

  belongs_to :question_category

  include Permissions::AnyoneCanViewRecruiterCanChange
end
