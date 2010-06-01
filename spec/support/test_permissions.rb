module Permissions
  module TestPermissions
    def cud_allowed( users, testee)
      for user in users
        testee.should be_creatable_by(user)
        testee.should be_updatable_by(user)
        testee.should be_destroyable_by(user)
      end
    end

    def cud_denied( users, testee)
      for user in users
        testee.should_not be_creatable_by(user)
        testee.should_not be_updatable_by(user)
        testee.should_not be_destroyable_by(user)
      end
    end
    
    def ud_denied( users, testee)
      for user in users
        testee.should_not be_updatable_by(user)
        testee.should_not be_destroyable_by(user)
      end
    end

    def view_allowed( users, testee)
      for user in users
        testee.should be_viewable_by(user)
      end
    end
    
    def view_denied( users, testee)
      for user in users
        testee.should_not be_viewable_by(user)
      end
    end

    def edit_allowed( users, testee, field = nil)
      for user in users
        testee.should be_editable_by(user, field)
      end
    end

    def edit_denied( users, testee, field = nil)
      for user in users
        testee.should_not be_editable_by(user, field)
      end
    end

    # if testee is nil it will yield block in for each user in users
    # giving user as paramter to generate testee
    def deny_all(users, testee = nil)
      for user in users
        testee = yield(user) if testee.nil?

        testee.should_not be_creatable_by(user)
        testee.should_not be_destroyable_by(user)
        testee.should_not be_updatable_by(user)
        testee.should_not be_viewable_by(user)
        testee.should_not be_editable_by(user)
      end
    end

    # if testee is nil it will yield block in for each user in users
    # giving user as paramter to generate testee
    def allow_all(users, testee = nil)
      for user in users
        testee = yield(user) if testee.nil?

        testee.should be_creatable_by(user)
        testee.should be_updatable_by(user)
        testee.should be_destroyable_by(user)
        testee.should be_viewable_by(user)
        testee.should be_editable_by(user)
      end
    end
  end
end
