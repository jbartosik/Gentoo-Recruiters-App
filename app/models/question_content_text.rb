require 'permissions/inherit.rb'
class QuestionContentText < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content :text
    timestamps
  end

  belongs_to    :question
  attr_readonly :question

  inherit_permissions(:question)

  def new_answer_of(user)
    Answer.new :question_id => question_id, :owner => user
  end
end
