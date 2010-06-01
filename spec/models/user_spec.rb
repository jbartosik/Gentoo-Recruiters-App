require 'spec_helper.rb'
describe User do
  include Permissions::TestPermissions
  fixtures :users, :question_categories, :questions, :answers, :user_categories

  before(:each) do
    @new_user = users(:uriael)
    @admin    = users(:ann)
    @admin2   = users(:alice)

    @ron        = users(:ron)
    @apple_q    = questions(:apple)
    @banana_q   = questions(:banana)
    @cucumber_q = questions(:cucumber)
    @carrot_q   = questions(:carrot)
    @spinach_q  = questions(:spinach)
    @potatoes_q = questions(:potatoes)
    @beef_q     = questions(:beef)
    @pork_q     = questions(:pork)

    @answered   = [@apple_q, @banana_q, @cucumber_q, @carrot_q, @spinach_q]
    @unanswered = [@potatoes_q, @beef_q, @pork_q]

    @recruit  = users(:ron)
    @recruiter= users(:ralph)
    @mentor   = users(:mustafa)
  end

  it "should be non-admin recruit" do
    @new_user.should_not   be_administrator
    @new_user.role.should  == :recruit
  end

  it { should allow_value(:mentor).for(:role) }
  it { should allow_value(:recruiter).for(:role) }

  it "should be valid if recruiter is administrator" do
    @new_user.role = :recruiter
    @new_user.administrator = true
    @new_user.should be_valid
  end

  it "should be invalid if non-recruiter is administrator" do
    @new_user.administrator = true

    for new_role in [:recruit, :mentor]
      @new_user.role        =  new_role
      @new_user.should_not  be_valid
    end
  end

  it "should be prohibited for non-admin to change anyone role to recruiter" do
    for new_role in [:recruiter, :mentor]
      @new_user.role        =  new_role
      @new_user.should_not  be_updatable_by(@new_user)
    end
  end

  it "should be allowed for admin to change anyone else role" do
    for other_user in [@new_user, @admin]
      for new_role in [:recruit, :mentor, :recruiter]
        other_user.role    = new_role
        other_user.should  be_updatable_by(@admin2)
      end
    end
  end

  it "should return proper all_questions" do
    for question in @answered + @unanswered
      @ron.all_questions.should be_include(question)
    end
    @ron.all_questions.should == @ron.all_questions.uniq
  end

  it "should return proper answered_questions" do
    for question in @answered
      @ron.answered_questions.should be_include(question)
    end
    for question in @unanswered
      @ron.answered_questions.should_not be_include(question)
    end
    @ron.answered_questions.should == @ron.answered_questions.uniq
  end

  it "should return proper unanswered_questions" do
    for question in @answered
      @ron.unanswered_questions.should_not be_include(question)
    end
    for question in @unanswered
      @ron.unanswered_questions.should be_include(question)
    end
    @ron.unanswered_questions.should == @ron.unanswered_questions.uniq
  end

  it 'should be invalid for recruit to mentor someone' do
    for user in [@admin, @recruiter, @mentor] do
      user.mentor = @recruit
      user.should_not be_valid
    end
  end

  it "should return proper recruits answers in category" do
    for ans in [answers(:apple), answers(:banana), answers(:cucumber),
      answers(:roland_apple)]
      @mentor.my_recruits_answers_in_category(question_categories(:fruit)).should
        be_include(ans)
      @mentor.my_recruits_answers_in_category(question_categories(:fruit)).should ==
      @mentor.my_recruits_answers_in_category(question_categories(:fruit)).uniq
    end
    @mentor.my_recruits_answers_in_category(question_categories(:fruit)).should_not
      be_include(answers(:albert_apple))
  end

  it 'should be allowed for mentors and recruiters to mentor someone' do
    for user in [@admin, @recruiter, @mentor] do
      @recruit.mentor = user
      @recruit.should be_valid
    end
  end

  it "should return proper my_recruits_anwers" do
    for ans in @recruit.answers + users(:roland).answers
      @mentor.my_recruits_answers.should be_include(ans)
    end
    for ans in users(:albert).answers
      @mentor.my_recruits_answers.should_not be_include(ans)
    end
    @mentor.my_recruits_answers.should == @mentor.my_recruits_answers.uniq
  end

  it "should prohibit non-recruiter to change user role" do
    @ron.role = :mentor
    for user in [@new_user, @mentor]
      @ron.should_not be_updatable_by(user)
    end
  end

  it "should allow recruiter to change user role" do
    @ron.role = :mentor
    for user in [@admin, @recruiter]
      @ron.should be_updatable_by(user)
    end
  end
end
