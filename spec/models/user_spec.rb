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
      end
    end
  end

  it "should be allowed for admin to change anyone else role" do
    for other_user in [:recruit, :administrator]
      for new_role in [:recruit, :mentor, :recruiter]
        user  = Factory(other_user)
        user.role   = new_role
        user.should be_updatable_by(Factory(:administrator))
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
    end
  end

  it "should allow recruiter to change user role" do
    recruit       = Factory(:recruit)
    recruit.role  = :mentor
    for user in [Factory(:recruiter), Factory(:administrator)]
      recruit.should be_updatable_by(user)
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

  it "should return proper recruits answers in category" do
    n_categories = 5
    r = recruit_with_answers_in_categories(nil, n_categories)
    for i in 0..(n_categories-1)
      cat = r.categories[i]
      ans = r.answers_in_cat[i]

      for answer in ans
        r.mentor.my_recruits_answers_in_category(cat).include?(answer).should be_true
      end

      for answer in r.all_answers - ans
        r.mentor.my_recruits_answers_in_category(cat).include?(answer).should be_false
      end

      r.mentor.my_recruits_answers_in_category(cat).should ==
        r.mentor.my_recruits_answers_in_category(cat).uniq
    end
  end
  it "should return proper my_recruits_anwers" do
    mentor    = Factory(:mentor)
    r1        = recruit_with_answers_in_categories(mentor)
    r2        = recruit_with_answers_in_categories(mentor)
    r3        = recruit_with_answers_in_categories

    for ans in (r1.all_answers + r2.all_answers)
      mentor.my_recruits_answers.include?(ans).should be_true
    end

    for ans in r3.all_answers
      mentor.my_recruits_answers.include?(ans).should be_false
    end
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

  it "should allow mentor to resign" do
    recruit = Factory(:recruit)
    mentor  = recruit.mentor
    recruit.should be_editable_by(mentor)
    recruit.should be_editable_by(mentor, :mentor)
    recruit.mentor = nil
    recruit.should be_updatable_by(mentor)
  end

  require 'ruby-debug'
  it "should check if mentors were Gentoo devs long enough if configured to" do
    user            = Factory(:recruit)

    # Configure to check using test data
    old_cong                                =  APP_CONFIG # to restore it after his test
    APP_CONFIG['developer_data']['check']   = true
    APP_CONFIG['developer_data']['min_months_mentor_is_dev']  = '6'
    APP_CONFIG['developer_data']['data']    = %{ { "developers":[
      {"joined":"#{4.years.ago.strftime('%F')}","nick":"long"},
      {"joined":"#{4.months.ago.strftime('%F')}","nick":"short"}
    ]}}

    user.role       = :mentor

    user.nick       = "long"
    user.should     be_valid

    user.nick       = "short"
    user.should_not be_valid

    user.nick       = "short"
    user.should_not be_valid

    APP_CONFIG = old_cong # restore config
  end
end
