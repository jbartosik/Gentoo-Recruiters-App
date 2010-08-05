# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  append_before_filter :only_valid_users

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected
    def only_valid_users
      unless current_user.valid?
        flash[:notice] = "You user account is invalid, please fix problems before you continue."
        redirect_to edit_user_path(current_user)
      end
    end
end
