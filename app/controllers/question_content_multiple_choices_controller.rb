class QuestionContentMultipleChoicesController < ApplicationController

  hobo_model_controller

  auto_actions      :create, :update, :edit
  auto_actions_for  :question, :new

  def new_for_question
    hobo_new  QuestionContentMultipleChoice.new(:question_id => params[:question_id])
  end
end
