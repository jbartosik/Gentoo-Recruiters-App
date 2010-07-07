class UserQuestionGroup < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    timestamps
  end
  belongs_to :user
  belongs_to :question

  validates_presence_of :question
  validate              :question_has_category
  validate              :user_does_not_have_other_question_from_the_same_category

  single_permission do
    # app manages those internally, don't allow users to do anything with it
    false
  end

  named_scope :find_by_user_and_question, lambda { |uid, qid| {
    :conditions => {:user_id => uid, :question_id => qid}}}

  named_scope :find_by_mentor_and_question, lambda { |mid, qid| {
    :joins => [:user, :question],
    :conditions => ['users.mentor_id = ? AND questions.id = ?', mid, qid]}}

  protected
    # as users can never edit questions on their own if one of those isn't met
    # it'll be because of some problem in application
    def question_has_category
      errors.add(:question, 'must be grouped!') if question.try.question_group.nil?
    end

    def user_does_not_have_other_question_from_the_same_category
      # if there are Questions from the same group associated with the same user
      # through user_question_groups report an error
      if Question.user_questions_in_group(user_id, question.question_group_id).id_is_not(question_id).count > 0
        errors.add(:question, 'user can have only one question from group')
      end
    end
end
