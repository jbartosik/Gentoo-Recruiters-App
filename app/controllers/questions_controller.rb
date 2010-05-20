class QuestionsController < ApplicationController

  hobo_model_controller

  auto_actions :all
  index_action :answered_questions, :unanswered_questions, :my_questions
  def answered_questions
    hobo_index (current_user.signed_up? && current_user.answered_questions)
  end
end
