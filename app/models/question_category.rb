class QuestionCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string
    timestamps
  end

  validates_presence_of :name

  has_many :questions
  has_many :user_categories
  has_many :users, :through => :user_category, :accessible => true
  include Permissions::AnyoneCanViewRecruiterCanChange
end
