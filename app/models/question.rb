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
  has_one     :reference_answer, :class_name => "Answer", :conditions => ["answers.reference = ?", true]
  include Permissions::AnyoneCanViewAdminCanChange

  after_create :notify_new_question

  def answered?(user)
    user.signed_up? && user.answered_questions.include?(self)
  end

  def answer_of(user)
    answers.owner_is(user).not_reference.first if user.signed_up?
  end

  protected
    def notify_new_question
      # If question category isn't assigned don't try to access it
      if question_category
        for user in question_category.users
          UserMailer.deliver_new_question user, self
        end
      end
    end
end
