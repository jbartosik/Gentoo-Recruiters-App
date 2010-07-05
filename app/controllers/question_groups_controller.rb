class QuestionGroupsController < ApplicationController

  hobo_model_controller

  auto_actions  :all, :except => :index
  index_action   :category

  def category
    if params["id"].nil? || params["id"].empty?
      hobo_index
    else
      hobo_index QuestionGroup.in_category params["id"]
    end
  end
end
