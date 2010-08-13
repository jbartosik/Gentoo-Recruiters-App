module Permissions
  # Please don't include this directly - use owned_model method
  module OwnedModel
    def create_permitted?
      acting_user.signed_up?
    end

    def update_permitted?
      owned?
    end

    def edit_permitted?(field)
     owned_soft?
    end

    def destroy_permitted?
      owned?
    end

    def view_permitted?(field)
      owned_soft?
    end

    protected
      def owned?
        owner_is?(acting_user) and !owner_changed?
      end

      def owned_soft?
        owner_is?(acting_user)
      end

      def must_be_owned
        errors.add(:owner, "must be current_user") unless owned?
      end

      def included
        validate_presence_of :owner
      end
  end
end

# If you use this in your model it will have two effects:
# - It will add belong_to owner relation with :creator => true. Owner will be
#   read only, never shown attribute.
# - It will set permissions so any signed up user will be able to create,
#   update, destroy, view and edit owned instance of model. No one else will
#   be able to.
def owned_model(owner_class)
  belongs_to    :owner, :class_name => owner_class, :creator => true
  never_show    :owner
  attr_readonly :owner
  include Permissions::OwnedModel
end
