require 'permissions/inherit.rb'
class QuestionContentText < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content HoboFields::MarkdownString, :null => false
    timestamps
  end

  belongs_to    :question, :null => false
  attr_readonly :question

  validates_length_of   :content, :minimum => 2

  inherit_permissions(:question)

  def new_answer_of(user)
    Answer.new :question_id => question_id, :owner => user
  end
end
