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
