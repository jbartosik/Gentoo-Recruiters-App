class QuestionsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  index_action :answered_questions, :unanswered_questions, :my_questions, :suggest_questions, :approve_questions

  def answered_questions
    hobo_index (current_user.signed_up? && current_user.answered_questions)
  end

  def suggest_questions
    hobo_index Question.suggested_questions current_user.try.id
  end

  def approve_questions
    hobo_index Question.questions_to_approve
  end
end
