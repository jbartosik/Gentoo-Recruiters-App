#    Gentoo Recruiters Web App - to help Gentoo recruiters do their job better
#   Copyright (C) 2010 Joachim Filip Bartosik
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, version 3 of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
# Questions are arranged in categories. Recruit should answer question in some
# categories.
class Category < ActiveRecord::Base

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
    [['All Categories', nil]] + self.all(:select => 'name, id').collect{ |q| [q.name, q.id]}
  end
end
