# Questions are arranged in categories. Recruit should answer question in some
# categories.
class QuestionCategory < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name :string, :null => false
    timestamps
  end

  validates_presence_of :name

  has_many :questions
  has_many :user_categories
  has_many :users, :through => :user_categories, :accessible => true

  include Permissions::AnyoneCanViewAdminCanChange

  # Array of arrays [Category name, Category id], includes also
  # ['All Categories', nil] array.
  def self.as_select_opts
    [['All Categories', nil]] + QuestionCategory.all(:select => 'name, id').collect{ |q| [q.name, q.id]}
  end
end
