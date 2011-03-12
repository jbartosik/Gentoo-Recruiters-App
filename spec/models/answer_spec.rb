require 'spec_helper.rb'
describe Answer do

  include Permissions::TestPermissions

  it 'any user (not guest) should be allowed to create, read, update and delete owned answers' do
    for user in fabricate_all_roles
      new_answer = Factory(:answer, :owner => user)
      cud_allowed([user], new_answer)
      view_allowed([user], new_answer)
    end
  end

  it 'should be prohibited to create, update and delete answers someone else owns' do
    for user in fabricate_all_roles
      ud_denied(fabricate_all_roles + [Guest.new], Factory(:answer, :owner => user))
      # updatable_by? blocks changing db
      # mentor is covered in separate test
    end
  end

  it 'should be creatable by any logged in user' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      new_answer.should be_creatable_by user
    end
  end

  it 'should not be creatable by guest' do
    Factory(:answer).should_not be_creatable_by Guest.new
  end

  it 'should allow owner to edit answer as whole and content field' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      new_answer.should be_editable_by user
      new_answer.should be_editable_by user, :content
    end
  end

  it 'should prohibited editing of non-reference answer as whole and content field to non-owners' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      edit_denied(fabricate_all_roles, new_answer)
      edit_denied(fabricate_all_roles, new_answer, :content)
    end
  end

  it 'should be prohibited for non-recruiters to view answers someone else owns' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      view_denied(fabricate_users(:recruit, :mentor)+ [Guest.new], new_answer)
    end
  end

  it 'should be allowed for recruiters to view all answers' do
    for user in fabricate_all_roles
      new_answer = Answer.new(:owner => user)
      view_allowed(fabricate_users(:recruiter, :administrator), new_answer)
    end
  end

  it "should be viewable by mentor of it's owner" do
    mentor  = Factory(:mentor)
    recruit = Factory(:recruit, :mentor => mentor)
    new_answer = Factory(:answer, :owner => recruit)
    view_allowed([mentor], new_answer)
  end

  it { should belong_to(:question) }
  it { should have_readonly_attribute(:owner) }

  it "should prohibit CUD and view of reference ans to non-recruiters" do
    new_answer  = Factory(:answer, :reference => true)
    cud_denied(fabricate_users(:recruit, :mentor), new_answer)
    view_denied(fabricate_users(:recruit, :mentor), new_answer)
  end

  it "should allow CUD, view and edit of reference answers to recruiters" do
    new_answer  = Factory(:answer, :reference => true)
    cud_allowed(fabricate_users(:recruiter, :administrator), new_answer)
    edit_allowed(fabricate_users(:recruiter, :administrator), new_answer)
    edit_allowed(fabricate_users(:recruiter, :administrator), new_answer, :content)
  end

  it "should allow mentor of owner to approve and disapprove" do
    r = recruit_with_answers_in_categories(nil, 1, 1)
    answer = r.all_answers.first
    for i in 1..2
      answer.approved = !answer.approved
      answer.should be_updatable_by(r.mentor)
      answer.should be_editable_by(r.mentor)
      answer.should be_editable_by(r.mentor, :approved)
      answer.save!
    end
  end

  it "should prohibit mentor of owner to edit content" do
    answer  = Factory(:answer)

    answer.content      = "changed"
    answer.should_not   be_updatable_by(answer.owner.mentor)
  end

  it "should prohibit owner to save changed answer as approved" do
    answer  = Factory(:answer)

    answer.approved = true
    answer.save!

    answer.content  = "changed"
    answer.should_not be_updatable_by(answer.owner)
  end

  it "should allow owner to save changed answer as unapproved" do
    answer  = Factory(:answer)

    answer.approved = true
    answer.save!

    answer.content  = "changed"
    answer.approved = false
    answer.should be_updatable_by(answer.owner)
  end

  it "should mark questions with changed content as unapproved" do
    answer  = Factory(:answer)

    answer.approved = true
    answer.save!

    answer.content  = "changed"
    answer.save!
    answer.approved.should be_false
  end

  it "should send email notification to mentor when created" do
    question  = Factory(:question)
    recruit   = Factory(:recruit)

    #can't use Factory Girl here, because we want to save it after setting expectation to get email
    answer    = Answer.new(:owner => recruit, :question => question, :content => "Some answer.")

    UserMailer.should_receive_delayed(:deliver_new_answer, recruit.mentor, answer)

    answer.save!
  end

  it "should send email notification to mentor when changed" do
    answer = Factory(:answer)
    UserMailer.should_receive_delayed(:deliver_changed_answer, answer.owner.mentor, answer)
    answer.content = "changed"
    answer.save!
  end

  it "shouldn't try to send notifications to mentor of mentorless recruit" do
    recruit =  Factory(:recruit, :mentor => nil)
    UserMailer.should_not_receive(:deliver_changed_answer)
    answer  = Factory(:answer, :owner => recruit)
    answer.save!
    answer.content = "changed"
    answer.save!
  end

  it "should prohibit editing of reference and approved fields to recruits" do
    answer = Factory(:answer)
    answer.should_not be_editable_by(answer.owner, :approved)
    answer.should_not be_editable_by(answer.owner, :reference)
  end

  it "should return proper answers_of_mentored_by" do
    mentor    = Factory(:mentor)
    r1        = recruit_with_answers_in_categories(mentor)
    r2        = recruit_with_answers_in_categories(mentor)
    r3        = recruit_with_answers_in_categories

    for ans in (r1.all_answers + r2.all_answers)
      Answer.of_mentored_by(mentor).include?(ans).should be_true
    end

    for ans in r3.all_answers
      Answer.of_mentored_by(mentor).include?(ans).should be_false
    end
  end

  it "should return in_category" do
    n_categories = 5
    r = recruit_with_answers_in_categories(nil, n_categories)
    for i in 0..(n_categories-1)
      cat = r.categories[i]
      ans = r.answers_in_cat[i]

      for answer in ans
        Answer.in_category(cat).include?(answer).should be_true
      end

      for answer in r.all_answers - ans
        Answer.in_category(cat).include?(answer).should be_false
      end

      Answer.in_category(cat).should ==
        Answer.in_category(cat).uniq
    end
  end

  it "should allow only owner to change feedback" do
    ans     = Factory(:answer)
    owner   = ans.owner
    others  = fabricate_users(:administrator, :recruit, :mentor, :recruiter) + [Guest.new, ans.owner.mentor]

    ans.should be_editable_by(owner, :feedback)
    edit_denied(others, ans, :feedback)

    ans.feedback = 'changed'
    ans.should be_updatable_by(owner)
    ud_denied(others, ans)
  end

  it "should allow editing of reference only to recruiters on new answers" do
    answer = Answer.new(:reference => true, :owner => Factory(:recruiter))
    answer.should     be_editable_by(Factory(:recruiter), :reference)
    answer.should_not be_editable_by(Factory(:recruit), :reference)
    answer.should_not be_editable_by(Factory(:mentor), :reference)
    answer.should_not be_editable_by(Guest.new, :reference)
  end

  it "should produce proper answer from params" do
    ans_hash = { 'reference' => false, 'owner_id' => Factory(:recruit).id,
                  'approved' => false, 'content' => 'example' }
    produced_ans  = Answer.new_from("answer" => ans_hash)

    produced_ans.class.should == Answer
    for i in ans_hash
      if i[1]
        produced_ans.attributes[i[0]].should == i[1]
      else
        (!produced_ans.attributes[i[0]]).should be_true # it can be nil or false
      end
    end

    ans_hash = { 'reference' => false, 'owner_id' => Factory(:recruit).id,
                  'approved' => false, 'content' => 'example' }
    produced_ans  = Answer.new_from("multiple_choice_answer" => ans_hash)

    produced_ans.class.should == MultipleChoiceAnswer
    for i in ans_hash
      if i[1]
        produced_ans.attributes[i[0]].should == i[1]
      else
        (!produced_ans.attributes[i[0]]).should be_true # it can be nil or false
      end
    end
  end

  it "should produce proper updated answer from params" do
    ans = Factory(:answer)
    upd = Answer.update_from('id' => ans.id.to_s, 'answer' => { 'content' => 'changed' })
    upd['id'].should == ans.id
    upd['owner_id'].should == ans.owner_id
    upd['content'].should == 'changed'

    ans = Factory(:multiple_choice_answer)
    upd = Answer.update_from('id' => ans.id.to_s, 'multiple_choice_answer' => { 'content' => 'changed' })
    upd['id'].should == ans.id
    upd['owner_id'].should == ans.owner_id
    upd['content'].should == 'changed'
  end

  it "should properly return wrong answers of recruit" do
    recruit = Factory(:recruit)
    cat     = Factory(:category)
    q1      = Factory(:question_category, :category => cat).question
    q2      = Factory(:question_category, :category => cat).question
    q3      = Factory(:question_category, :category => cat).question
    q4      = Factory(:question_category, :category => cat).question

              Factory(:question_content_text, :question => q4)

    for i in [q1, q2, q3]
      Factory(:question_content_multiple_choice, :question => i)
      i.reload
      ["1", "2", "3"].each{ |j| Factory(:option, :option_owner => i.content, :content => j) }
      i.reload
      Factory(:multiple_choice_answer, :question => i,
              :options => [i.content.options.first.id], :reference => true)
    end

    wrong_ans = []
    not_wrong_ans = []

    wrong_ans.push Factory(:multiple_choice_answer, :question => q1,
                            :options => [q1.content.options.second.id], :owner => recruit)

    wrong_ans.push Factory(:multiple_choice_answer, :question => q2,
                            :options => [q1.content.options.first.id, q1.content.options.second.id],
                            :owner => recruit)

    not_wrong_ans.push Factory(:multiple_choice_answer, :question => q3,
                            :options => [q1.content.options.first.id])

    not_wrong_ans.push Factory(:answer, :question => q4,
                                :content => "wrong",
                                :owner => recruit)

    not_wrong_ans.push Factory(:answer, :question => q4,
                                :content => "good",
                                :reference => true)

    for i in wrong_ans
      Answer.wrong_answers_of(recruit).include?(i).should be_true
    end

    for i in not_wrong_ans
      Answer.wrong_answers_of(recruit).include?(i).should be_false
    end

    Answer.wrong_answers_of(recruit).count.should == Answer.wrong_answers_of(recruit).uniq.count
  end

  it "should prohibit mentor of owner to destroy" do
    a = Factory(:answer)
    a.should_not be_destroyable_by(a.owner.mentor)
  end

  it "should allow editing of reference only to recruiters" do
    for user in fabricate_users(:recruit, :mentor)
      Answer.new(:owner => user).should_not be_editable_by(user, :reference)
    end

    for user in fabricate_users(:recruiter, :administrator)
      Answer.new(:owner => user).should be_editable_by(user, :reference)
    end
  end

  it "should properly return answers with feedback" do

    with_feedback = (Answer.new.feedback.class.values - ['']).collect do |fb|
      Factory(:answer, :feedback => fb)
    end

    without_feedback = ['', nil].collect do |fb|
      Factory(:answer, :feedback => fb)
    end

    with_feedback.each{ |ans| Answer.with_some_feedback.include?(ans).should be_true }
    without_feedback.each{ |ans| Answer.with_some_feedback.include?(ans).should be_false }

    Answer.with_some_feedback.count.should == Answer.with_some_feedback.uniq.count
  end
end
