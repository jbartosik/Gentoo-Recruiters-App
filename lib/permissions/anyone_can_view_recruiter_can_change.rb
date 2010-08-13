require 'permissions/set'
module Permissions
  # If you include this recruiters will be allowed to do everything,
  # others users will will be able only to view.
  module AnyoneCanViewRecruiterCanChange
    multi_permission :create, :update, :destroy do
      User.user_is_recruiter?(acting_user)
    end

    def view_permitted?(field)
      true
    end
  end
end
