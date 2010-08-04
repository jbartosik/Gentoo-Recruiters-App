class Option < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    content :string, :null => false
    timestamps
  end

  belongs_to    :option_owner, :polymorphic => true, :creator => true, :null => false
  never_show    :option_owner_type

  inherit_permissions(:option_owner)
end
