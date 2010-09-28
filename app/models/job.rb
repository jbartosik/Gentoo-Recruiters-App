# Don't use this class.
#
# Only purpose of this class is to let hobo_migration generator know that it
# should create delayed_jobs table.
class Job < ActiveRecord::Base
  set_table_name "delayed_jobs"
  fields do
    priority    :integer, :default => 0
    attempts    :integer, :default => 0
    handler     :text
    last_error  :string
    run_at      :datetime
    locked_at   :datetime
    failed_at   :datetime
    locked_by   :string
    timestamps
  end
end
