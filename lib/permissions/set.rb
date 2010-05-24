AllPermissions = [:create, :update, :destroy, :view, :edit]

def one_permission(permission,  &block)
    define_method("#{permission.to_s}_permitted?", &block)
end
def multi_permission(*permission_list,  &block)
  permission_list.flatten.each do |target|
    one_permission(target, &block)
  end
end
def single_permission(&block)
  multi_permission(AllPermissions, &block)
end
