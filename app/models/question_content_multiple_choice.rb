require 'permissions/inherit.rb'
class QuestionContentMultipleChoice < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content   :text
    timestamps
  end

  belongs_to      :question
  attr_readonly   :question
  has_many        :options, :as => :option_owner, :accessible => true, :uniq => true

  inherit_permissions(:question)

  def new_answer_of(user)
    MultipleChoiceAnswer.new :question_id => question_id, :owner => user
  end
end
