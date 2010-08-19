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
class UsersController < ApplicationController

  hobo_user_controller
  openid_login:openid_opts => { :model => User }

  skip_before_filter :only_valid_users, :only => [:edit, :update]
  auto_actions :all, :except => [ :index, :new, :create ]
  index_action :ready_recruits
  index_action :mentorless_recruits
  show_action  :questions

  def ready_recruits
    hobo_index User.recruits_answered_all
  end

  def mentorless_recruits
    hobo_index  User.mentorless_recruits
  end

  def questions
    hobo_show do
      @user = this
    end
  end

  skip_before_filter :verify_authenticity_token, :only => [:receive_email]

  def receive_email
    raise Hobo::PermissionDeniedError unless request.remote_ip == '127.0.0.1'
    UserMailer.receive(params[:email])
    render :text => 'Email Received'
  end
end
