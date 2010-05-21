module Permissions
  module AnyoneCanViewRecruiterCanChange
    def create_permitted?
      User.user_is_recruiter?(acting_user)
    end

    def update_permitted?
      User.user_is_recruiter?(acting_user)
    end

    def destroy_permitted?
      User.user_is_recruiter?(acting_user)
    end

    def view_permitted?(field)
      true
    end
  end
end
