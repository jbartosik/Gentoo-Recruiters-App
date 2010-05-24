require 'permissions/set'
module Permissions
  module AnyoneCanViewAdminCanChange
    multi_permission :create, :update, :destroy do
      acting_user.administrator?
    end

    def view_permitted?(field)
      true
    end
  end
end
