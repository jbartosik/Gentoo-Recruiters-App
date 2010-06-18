# returns r, and:
#   r.recruit     - recruit
#   r.answered    - array of questions r.recruit answered
#   r.unanswered  - array of questions r.recruit didn't answer
# r.answered and r.unanswered are in categories r.recruit is assigned
# (one answered and one unanswered question per category)
def recruit_with_answered_and_unanswered_questions(n=5)
    r = Struct.new(:recruit, :answered, :unanswered).new
    r.recruit     = Factory(:recruit)
    r.answered    = []
    r.unanswered  = []
    for i in 1..n
      category =        Factory(:question_category)
      r.answered.push   Factory(:question, :question_category => category)
      r.unanswered.push Factory(:question, :question_category => category)

      Factory(:answer, :owner => r.recruit, :question => r.answered.last)
      r.recruit.question_categories.push category
    end
    r
end

def recruit_with_answers_in_categories(mentor = nil, n_categories = 5, n_ans_in_cat = 3)
  r = Struct.new(:recruit, :mentor, :categories, :answers_in_cat, :all_answers).new
  if mentor.nil?
    r.mentor        = Factory(:mentor)
  else
    r.mentor        = mentor
  end

  r.recruit         = Factory(:recruit, :mentor => r.mentor)
  r.categories      = []
  r.answers_in_cat  = []
  r.all_answers     = []
  for i in 1..n_categories
    r.categories.push     Factory(:question_category)
    r.answers_in_cat.push []
    for i in 1..n_ans_in_cat
      question                    = Factory(:question, :question_category => r.categories.last)
      r.all_answers.push          Factory(:answer, :owner => r.recruit, :question => question)
      r.answers_in_cat.last.push  r.all_answers.last
    end
  end
  r
end

def fabricate_users(*roles)
  r = []
  for role in roles
    r.push Factory(role)
  end
  r
end

def fabricate_all_roles()
  fabricate_users(:recruit, :mentor, :recruiter, :administrator)
end
