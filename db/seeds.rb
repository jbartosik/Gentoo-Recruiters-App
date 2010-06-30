# This removes existing database entries
# but don't ask for confirmation - it's prohibited on Heroku
# In future (when we will have some important data)
# we should consider removing it (or at least disable it in production mode)
class SeedHelper
  attr_accessor :objects
  def initialize
    @objects  ={}
  end

  # Read data from file
  # in each item replace values of fields given in replace_with_objects with objects
  # and create!
  def read_yaml(file, klass, replace_with_objects)
    for item_array in  YAML::load_file(file)
      name = item_array[0]
      hash = item_array[1]
      for field in replace_with_objects
        hash[field] = @objects[hash[field]]
      end
      @objects[name] = klass.create! hash
    end
  end

  def answer_many(user, questions, answer_hash)
    for question in questions
      answer_hash[:question] = @objects[question]
      answer_hash[:owner] = @objects[user]
      Answer.create! answer_hash
    end
  end
end

# Remove existing database entries
User.destroy_all
Answer.destroy_all
QuestionCategory.destroy_all
QuestionGroup.destroy_all
Question.destroy_all
UserCategory.destroy_all
UserQuestionGroup.destroy_all
User.destroy_all

seeder = SeedHelper.new

# Question categories
seeder.objects['ebuild']    = QuestionCategory.create! :name => 'Ebuild quiz'
seeder.objects['mentoring'] = QuestionCategory.create! :name => 'End of mentoring quiz'
seeder.objects['non']       = QuestionCategory.create! :name => 'Non-ebuild staff quiz'

# Question groups
seeder.objects['ebuild_group1'] = QuestionGroup.create! :name => 'ebuild_group1', :description => 'src_install implementations to comment on'

# Questions - load from YAML file
seeder.read_yaml 'db/fixtures/questions.yml', Question, ['question_category', 'question_group']

# Users - load from YAML file
seeder.read_yaml 'db/fixtures/users.yml', User, 'mentor'

# Categories for users
user_cats = [
  ['ebuild', 'mentor'],
  ['ebuild', 'recruit'],
  ['ebuild', 'middle'],
  ['ebuild', 'advanced'],
  ['mentoring', 'advanced'],
  ['mentoring', 'mentor']]

for uc in user_cats
  UserCategory.create! :question_category => seeder.objects[uc[0]], :user => seeder.objects[uc[1]]
end


ebuild_q  = ['ebuild_q1', 'ebuild_q2', 'ebuild_q3']
mentor_q  = ['mentor_q1', 'mentor_q2', 'mentor_q3']
non_q     = ['non_q1', 'non_q', 'non_q3']

# non-approved answers
ans_hash = {:content => 'Some answer'}
seeder.answer_many 'recruit',      ebuild_q, ans_hash
seeder.answer_many 'middle',  ebuild_q  - ['ebuild_q3'], ans_hash
seeder.answer_many 'advanced',     mentor_q, ans_hash

# approved answers
ans_hash[:approved] = true
seeder.answer_many 'mentor',       ebuild_q, ans_hash
seeder.answer_many 'advanced',     ebuild_q, ans_hash
seeder.answer_many 'mentor',       mentor_q, ans_hash

# reference answers for most questions
seeder.answer_many 'recruiter', mentor_q + ebuild_q + non_q - ['ebuild_q1', 'non_q1'],
  {:content => "Some reference answer", :reference => true}

advanced = seeder.objects['advanced']

for ans in advanced.answers
  Comment.create( :answer => ans, :owner => advanced.mentor, :content => "some comment")
end

for q in ebuild_q
  Comment.create( :answer => (seeder.objects[q].answer_of advanced), :owner => advanced.mentor,
    :content => "Some other comment")
end
