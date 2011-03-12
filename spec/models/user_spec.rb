require 'spec_helper.rb'
describe User do
  include Permissions::TestPermissions

  it "should be non-admin recruit" do
    new_user  = User.new(:name => "Some", :email_address => "some@some.com")
    new_user.should_not   be_administrator
    new_user.role.should  == :recruit
  end

  it { should allow_value(:mentor).for(:role) }
  it { should allow_value(:recruiter).for(:role) }

  it "should be valid if recruiter is administrator" do
    Factory(:administrator).should be_valid
  end

  it "should be invalid if non-recruiter is administrator" do
    user = Factory(:recruit)
    user .administrator = true

    for new_role in [:recruit, :mentor]
      user.role        =  new_role
      user.should_not  be_valid
    end
  end

  it "should be prohibited for recruits and mentors to change anyone role to recruiter" do
    user = Factory(:recruit)
    for new_role in [:recruiter, :mentor]
      user.role        =  new_role
      for updater in [Factory(:recruit), Factory(:mentor), Guest.new]
        user.should_not  be_updatable_by(updater)
        user.should_not  be_editable_by(updater, :role)
      end
    end
  end

  it "should be allowed for admin to change anyone else role" do
    for other_user in [:recruit, :administrator]
      for new_role in [:recruit, :mentor, :recruiter]
        user  = Factory(other_user)
        user.role   = new_role
        user.should be_updatable_by(Factory(:administrator))
        user.should be_editable_by(Factory(:administrator), :role)
      end
    end
  end

  it 'should be invalid for recruit to mentor someone' do
    for user in [Factory(:administrator), Factory(:recruiter), Factory(:mentor)] do
      user.mentor = Factory(:recruit)
      user.should_not be_valid
    end
  end

  it 'should be allowed for mentors and recruiters to mentor someone' do
    for user in [Factory(:administrator), Factory(:recruiter), Factory(:mentor)] do
      recruit     = Factory(:recruit, :mentor => user)
      user.should be_valid
    end
  end

  it "should prohibit non-recruiter to change user role" do
    recruit       = Factory(:recruit)
    recruit.role  = :mentor
    for user in [Factory(:recruit), Factory(:mentor)]
      recruit.should_not be_updatable_by(user)
      recruit.should_not be_editable_by(user, :role)
    end
  end

  it "should allow recruiter to promote recruits to mentors" do
    recruit       = Factory(:recruit)
    recruit.role  = :mentor
    for user in [Factory(:recruiter), Factory(:administrator)]
      recruit.should be_updatable_by(user)
      recruit.should be_editable_by(user, :role)
    end
  end

  it "should allow recruiter to demote mentors to recruits" do
    recruit       = Factory(:mentor)
    recruit.role  = :recruit
    for user in [Factory(:recruiter), Factory(:administrator)]
      recruit.should be_updatable_by(user)
      recruit.should be_editable_by(user, :role)
    end
  end


  it "should return proper all_questions" do
    r = recruit_with_answered_and_unanswered_questions

    for question in r.answered + r.unanswered
      r.recruit.all_questions.include?(question).should be_true
    end
    r.recruit.all_questions.count.should == r.recruit.all_questions.uniq.count
  end

  it "should return proper answered_questions" do
    r = recruit_with_answered_and_unanswered_questions
    for question in r.answered
      r.recruit.answered_questions.include?(question).should be_true
    end
    for question in r.unanswered
      r.recruit.answered_questions.include?(question).should be_false
    end
    r.recruit.answered_questions.should == r.recruit.answered_questions.uniq
  end

  it "should return proper unanswered_questions" do
    r = recruit_with_answered_and_unanswered_questions
    unanswered = r.recruit.unanswered_questions
    (r.unanswered - unanswered).should be_empty
    (unanswered - r.unanswered).should be_empty
    unanswered.should == unanswered.uniq
  end

  it "should properly check if user answered all questions" do
    r = recruit_with_answered_and_unanswered_questions
    r.recruit.answered_all_questions?.should          be_false
    Factory(:recruit).answered_all_questions?.should  be_true
  end

  it "should return proper recruits with all questions` answered" do
    # recruits that should be returned
    correct_answered_all = [Factory(:recruit)]
    correct_answered_all.push recruit_with_answers_in_categories.recruit

    # and some other users
    recruit_with_answered_and_unanswered_questions
    Factory(:administrator)
    Factory(:mentor)
    Factory(:recruiter)

    answered_all = User.recruits_answered_all

    (answered_all - correct_answered_all).should be_empty
    (correct_answered_all - answered_all).should be_empty
  end

  it "should allow recruiters to change nick of other users" do
    for u in fabricate_all_roles
      u.should be_editable_by Factory(:recruiter), :nick
      u.should be_viewable_by Factory(:recruiter), :nick
      u.nick = 'changed'
      u.should be_updatable_by Factory(:recruiter)
    end
  end

  it "should allow user to change their nicks" do
    for u in fabricate_all_roles
      u.should be_editable_by u, :nick
      u.should be_viewable_by u, :nick
      u.nick = 'changed'
      u.should be_updatable_by u
    end
  end

  it "that is mentorless recruit should allow mentor to pick up" do
    recruit = Factory(:recruit, :mentor => nil)
    mentor  = Factory(:mentor)
    recruit.should be_editable_by(mentor)
    recruit.should be_editable_by(mentor, :mentor)
    recruit.mentor = mentor
    recruit.should be_updatable_by(mentor)
  end

  it "that is mentorless recruit should allow recruiter to pick up" do
    recruit = Factory(:recruit, :mentor => nil)
    mentor  = Factory(:recruiter)
    recruit.should be_editable_by(mentor)
    recruit.should be_editable_by(mentor, :mentor)
    recruit.mentor = mentor
    recruit.should be_updatable_by(mentor)
  end

  it "should allow mentor to resign" do
    recruit = Factory(:recruit)
    mentor  = recruit.mentor
    recruit.should be_editable_by(mentor)
    recruit.should be_editable_by(mentor, :mentor)
    recruit.mentor = nil
    recruit.should be_updatable_by(mentor)
  end

  it "should allow administartor to change mentor to resign" do
    recruit = Factory(:recruit)
    recruit.should be_editable_by(Factory(:administrator))
    recruit.should be_editable_by(Factory(:administrator), :mentor)
  end
  it "should check if mentors were Gentoo devs long enough if configured to" do
    user            = Factory(:recruit)

    # Configure to check using test data
    old_config                              =  APP_CONFIG.to_json # to restore it after his test
                                                                  # it behaves like reference if
                                                                  # I copy a hash
    APP_CONFIG['developer_data']['check']   = true
    APP_CONFIG['developer_data']['min_months_mentor_is_dev']  = '6'
    APP_CONFIG['developer_data']['data']    = %{{"developers": [
      {"joined": "#{4.years.ago.strftime('%Y/%m/%d')}", "nick": "long"},
      {"joined": "#{4.months.ago.strftime('%Y/%m/%d')}", "nick": "short"}
    ]}}

    user.role       = :mentor

    user.nick       = "long"
    user.should     be_valid

    user.nick       = "short"
    user.should_not be_valid

    user.nick       = "invalid"
    user.should_not be_valid

    silence_warnings { APP_CONFIG = JSON.load(old_config) } # restore config
  end

  it "should allow only recruiters to edit project acceptances" do
    user = Factory(:recruit)
    user.should be_editable_by(Factory(:recruiter), :project_acceptances)

    user.should_not be_editable_by(Factory(:mentor, :project_lead => true), :project_acceptances)
    user.should_not be_editable_by(Factory(:mentor), :project_acceptances)
    user.should_not be_editable_by(Factory(:recruit), :project_acceptances)
    user.should_not be_editable_by(Guest.new, :project_acceptances)
  end

  it "should have token right after creation" do
    for u in fabricate_all_roles
      u.token.should_not be_nil
    end
  end

  it "should make mentors users that register with OpenID https://dev.gentoo.org/~nick, deducing nick from OpenID" do
    user = User.new :email_address => "example@example.com", :name => "Example",
                    :openid => "https://dev.gentoo.org/~example"
    user.save!
    user.nick.should == "example"
    user.role.is_mentor?.should be_true
  end

  it "should not make mentors users that set their OpenID after registration" do
    user = Factory(:recruit)
    user.openid = "https://dev.gentoo.org/~example"
    user.save!
    user.nick.should be_nil
    user.role.is_mentor?.should be_false
  end

  it "should not make mentors users who use faked dev.gentoo.org OpenID" do
    user = User.new :email_address => "example@example.com", :name => "Example",
                    :openid => "https://fake.com/dev.gentoo.org/~example"
    user.save!
    user.nick.should be_nil
    user.role.is_mentor?.should be_false

    user = User.new :email_address => "example@fake.com", :name => "Fake",
                    :openid => "https://fake.com/https://dev.gentoo.org/~example"
    user.save!
    user.nick.should be_nil
    user.role.is_mentor?.should be_false
  end

  it "should not be creatable by anyone" do
    user = User.new :name => "name", :email_address => "email@example.com"
    for u in fabricate_all_roles + [Guest.new]
      user.should_not be_creatable_by(u)
    end
  end

  it "should allow only administrator to destory" do
    user = Factory(:recruit)
    for u in fabricate_users(:recruit, :mentor, :recruiter) + [Guest.new]
      user.should_not be_destroyable_by(u)
    end

    user.should be_destroyable_by(Factory(:administrator))
  end

  it "should properly recognize if there are pending project acceptances" do
    lead = Factory(:mentor)
    lead.any_pending_project_acceptances?.should be_false

    ProjectAcceptance.create! :accepting_nick => lead.nick, :user => Factory(:recruit)
    lead.any_pending_project_acceptances?.should be_true

    ProjectAcceptance.first.update_attribute(:accepted, true)
    lead.any_pending_project_acceptances?.should be_false
  end

  it "should reurn proper questions to approve" do
    for u in fabricate_users(:recruit, :mentor, :recruiter) + [Guest.new]
      u.questions_to_approve.should == []
    end

    Factory(:administrator).questions_to_approve.should == []

    q = Factory(:question, :approved => false, :user => Factory(:recruit))

    Factory(:administrator).questions_to_approve.should == [q]
  end

  it "should properly recognie if user answera all multiple choice questions" do
    recruit = Factory(:recruit)
    recruit.answered_all_multi_choice_questions?.should be_true

    q1      = Factory(:question)
              Factory(:question_content_multiple_choice, :question => q1)
              Factory(:user_category,
                      :category => q1.category,
                      :user => recruit)

    recruit.answered_all_multi_choice_questions?.should be_false

    Factory(:multiple_choice_answer, :question => q1, :owner => recruit)
    recruit.answered_all_multi_choice_questions?.should be_true

    q2      = Factory(:question, :question_group => Factory(:question_group))
    Factory(:question_content_multiple_choice, :question => q2)
    recruit.answered_all_multi_choice_questions?.should be_true

    Factory(:user_question_group,
            :user => recruit,
            :question => q2)
    recruit.answered_all_multi_choice_questions?.should be_false

    Factory(:multiple_choice_answer, :question => q2, :owner => recruit)
    recruit.answered_all_multi_choice_questions?.should be_true
  end

  it "shold return proper progress" do
    recruit = Factory(:recruit)
    recruit.progress.should == "Answered 0 of 0 questions."

    q1 = Factory(:question)
    Factory(:user_category, :user => recruit,
      :category => q1.category)
    recruit.progress.should == "Answered 0 of 1 questions."

    Factory(:answer, :owner => recruit, :question => q1)
    recruit.progress.should == "Answered 1 of 1 questions."

    q2 = Factory(:question, :question_group => Factory(:question_group))
          Factory(:user_question_group, :question => q2, :user => recruit)
    recruit.progress.should == "Answered 1 of 2 questions."

    Factory(:answer, :owner => recruit, :question => q2)
    recruit.progress.should == "Answered 2 of 2 questions."
  end
end
