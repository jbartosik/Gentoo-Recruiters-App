module Permissions
  module TestPermissions
    def cud_allowed( users, testee)
      for user in users
        testee.should be_creatable_by(user)
        testee.should be_updatable_by(user)
        testee.should be_editable_by(user)
      end
    end

    def cud_denied( users, testee)
      for user in users
        testee.should_not be_creatable_by(user)
        testee.should_not be_updatable_by(user)
        testee.should_not be_editable_by(user)
      end
    end
    
    def ud_denied( users, testee)
      for user in users
        testee.should_not be_updatable_by(user)
        testee.should_not be_editable_by(user)
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
  end
end
