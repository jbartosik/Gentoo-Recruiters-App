class ProjectAcceptancesController < ApplicationController

  hobo_model_controller

  auto_actions :all
  index_action :pending_acceptances

  def pending_acceptances
    hobo_index ProjectAcceptance.accepting_nick_is(current_user.try.nick)
  end
end
