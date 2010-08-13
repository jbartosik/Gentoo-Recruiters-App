AllPermissions = [:create, :update, :destroy, :view, :edit]

# Block will be used to determine chosen permission
def one_permission(permission,  &block)
    define_method("#{permission.to_s}_permitted?", &block)
end

# Block will be used to determine chosen permissions
def multi_permission(*permission_list,  &block)
  permission_list.flatten.each do |target|
    one_permission(target, &block)
  end
end

# Block will be used to determine all permission
def single_permission(&block)
  multi_permission(AllPermissions, &block)
end
