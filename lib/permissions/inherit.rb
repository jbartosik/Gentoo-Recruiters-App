require 'permissions/set.rb'
# If you call this in your model it will have exactly the same permissions as
# source.
def inherit_permissions(source)
  one_permission(:view){ send(source).nil? || send(source).send("viewable_by?", acting_user)}
  one_permission(:create){ send(source).nil? || send(source).send("creatable_by?", acting_user)}
  one_permission(:update){ send(source).nil? || send(source).send("updatable_by?", acting_user)}
  one_permission(:destroy){ send(source).nil? || send(source).send("destroyable_by?", acting_user)}
  one_permission(:edit){ send(source).nil? || send(source).send("editable_by?", acting_user)}
end
