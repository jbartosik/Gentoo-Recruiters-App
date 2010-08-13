require 'permissions/inherit.rb'
# Multiple choice content for question.
class QuestionContentMultipleChoice < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content   HoboFields::MarkdownString, :null => false
    timestamps
  end

  belongs_to            :question, :null => false
  attr_readonly         :question
  has_many              :options, :as => :option_owner, :accessible => true, :uniq => true
  validates_length_of   :content, :minimum => 2

  inherit_permissions(:question)

  # Returns new answer (of proper class) of user for question (relation).
  def new_answer_of(user)
    MultipleChoiceAnswer.new :question_id => question_id, :owner => user
  end
end
