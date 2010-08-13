require 'permissions/set'
# Modules helping to manage permissions
module Permissions
  # If you include this administrators will be allowed to do everything,
  # others users will will be able only to view.
  module AnyoneCanViewAdminCanChange
    multi_permission :create, :update, :destroy do
      acting_user.administrator?
    end

    def view_permitted?(field)
      true
    end
  end
end
