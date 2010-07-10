class UsersController < ApplicationController

  hobo_user_controller

  auto_actions :all, :except => [ :index, :new, :create ]
  index_action :ready_recruits
  index_action :mentorless_recruits, :receive_email


  def ready_recruits
    hobo_index User.recruits_answered_all
  end

  def mentorless_recruits
    hobo_index  User.mentorless_recruits
  end
  def receive_email
    hobo_index

    mail          = TMail::Mail.new
    mail.subject  = params['subject']
    mail.from     = params['from']
    mail.to       = params['to']
    mail.reply_to = params['reply_to']

    UserMailer.receive(mail.to_s)
  end
end
