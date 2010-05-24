class Question < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    title         :string
    content       :text
    documentation :string
    timestamps
  end

  validates_presence_of :title, :content
  #allow empty documentation and no category
  #maybe add a page for not complete questions

  belongs_to  :question_category
  has_many    :answers
  include Permissions::AnyoneCanViewAdminCanChange

  def answered?(user)
    user.signed_up? && user.answered_questions.include?(self)
  end
end
