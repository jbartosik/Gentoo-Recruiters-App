class QuestionContentTextsController < ApplicationController

  hobo_model_controller

  auto_actions      :create
  auto_actions_for  :question, :new

  def new_for_question
    hobo_new  QuestionContentText.new(:question_id => params[:question_id])
  end
end
