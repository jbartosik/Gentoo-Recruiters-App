require 'spec_helper.rb'

describe ProjectAcceptance do

  include Permissions::TestPermissions

  it 'should allow any mentor of user and recruiters to edit and RUD (if not accepted)' do
    for user in fabricate_all_roles
      acceptance = Factory(:project_acceptance, :user => user)
      users = [Factory(:recruiter)]
      users += [user.mentor] if user.mentor

      ud_allowed(users, acceptance)
      view_allowed(users, acceptance)
      edit_allowed(users, acceptance)
    end
  end

  it 'should prohibit user other then recuiter or mentor of recruit being accepted to edit and CUD' do
    acceptance  = Factory(:project_acceptance)
    users       = fabricate_users(:recruit, :mentor) + [Guest.new, acceptance.user]

    cud_denied(users, acceptance)
    edit_denied(users, acceptance)
  end

  it 'allow user with nick which is accepting_nick for the acceptance to accept' do
    acceptance          = Factory(:project_acceptance)
    acceptance.accepted = true
    user                = [User.find_by_nick(acceptance.accepting_nick)]

    ud_allowed(user, acceptance)
    view_allowed(user, acceptance)
    edit_allowed(user, acceptance)
  end

  it 'prohibit users to accept and change if it is accepted' do
    acceptance          = Factory(:project_acceptance)
    users               = fabricate_users(:recruit, :mentor) + [Guest.new]
    acceptance.accepted = true

    cud_denied(users, acceptance)
    edit_denied(users, acceptance)

    acceptance.save!
    cud_denied(users, acceptance)
    edit_denied(users, acceptance)
  end

  it 'should allow any user (relation), his/her mentor and recruiters to view if accepted' do
    acceptance          = Factory(:project_acceptance)
    acceptance.accepted = true
    acceptance.save!

    users       = [acceptance.user, acceptance.user.mentor, Factory(:recruiter)]
    view_allowed(users, acceptance)
  end

  it 'should allow creation only to recruiters and project leads that create for themselfs' do
    acceptance = ProjectAcceptance.new :accepting_nick => 'a'
    lead = Factory(:mentor, :nick => "a", :project_lead => true)

    acceptance.should be_creatable_by(Factory(:recruiter))
    acceptance.should be_creatable_by(lead)

    acceptance.should be_editable_by(Factory(:recruiter))
    acceptance.should be_editable_by(lead)

    acceptance.should_not be_creatable_by(Factory(:recruit))
    acceptance.should_not be_creatable_by(Factory(:mentor))
    acceptance.should_not be_creatable_by(Factory(:mentor, :project_lead => true))
    acceptance.should_not be_creatable_by(Guest.new)
  end
end
