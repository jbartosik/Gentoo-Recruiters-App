# This removes existing database entries, so ask for confirmation

response = nil
while response != 'y'
  puts "Warning, this will remove content of your database, are you sure you want it(y/n)?"
  STDOUT.flush()
  response = STDIN.gets.chomp
  exit if 'n' == response
end

# Remove existing database entries
User.destroy_all
Answer.destroy_all
QuestionCategory.destroy_all
Question.destroy_all
UserCategory.destroy_all
User.destroy_all

# Question categories
ebuild    = QuestionCategory.create! :name => 'Ebuild quiz'
mentoring = QuestionCategory.create! :name => 'End of mentoring quiz'
non       = QuestionCategory.create! :name => 'Non-ebuild staff quiz'

# Ebuild quiz questions
ebuild_q1 = Question.create!  :title => 'Big changes in Gentoo',
  :content => 'What is the proper method for suggesting a wide-ranging feature ' +
  'or enhancement to Gentoo? Describe the process for getting this feature ' +
  'approved and implemented.', :documentation => 'GLEPs', :question_category => ebuild

ebuild_q2 = Question.create!  :title => 'Responsibilities',
  :content => 'Who should be contacted with complaints about specific ' +
  'developers or projects?', :documentation => 'devrel policy', :question_category => ebuild

ebuild_q3 = Question.create!  :title => 'Gentoo mailing lists',
  :content => 'When is it appropriate to post to the following mailing lists:' +
  'gentoo-core, gentoo-dev, gentoo-dev-announce, gentoo-project?',
  :documentation => 'gentoo.org', :question_category => ebuild

# End of mentoring quiz  questions
mentor_q1 = Question.create! :title => 'Scopes in ebuild',
  :content => "What's the difference between local and global scope in an ebuild?",
  :documentation => 'handbook', :question_category => mentoring

mentor_q2 = Question.create! :title => 'Optional SSL support in ebuild',
  :content => 'You have a patch for foomatic which enables SSL support that is' +
  ' optional at build time. Assuming that foomatic uses an autotools based ' +
  'build system provide most probable changes required in an EAPI="0" ebuild.' +
  'What should be done for the ebuild in case it uses EAPI="2"?',
  :documentation => 'devmanual', :question_category => mentoring

mentor_q3 = Question.create! :title => 'Improve maintainability of ebuild',
  :content => 'You are writing an ebuild for the foomatic package. Upstream calls' +
  'the current version "1.3-7b" (but this is _not_ a beta release). How would the ' +
  "ebuild be named? What's wrong with the ebuild snippet below and how should this " +
  'be written to aid maintainability?<br/><br/>' +
  'SRC_URI="http://foomatic.example.com/download/foomatic-1.3-7b.tar.bz2"'+
  'S=${WORKDIR}/foomatic-1.3-7b ',
  :documentation => 'devmanual', :question_category => mentoring

# Nonebuild staff quiz questions
non_q1  = Question.create! :title => 'Gentoo Foundation',
  :content => 'What is the Gentoo Foundation? How does one apply for membership and who are eligible?',
  :documentation => 'gentoo.org', :question_category => non

non_q2  = Question.create! :title => 'Gentoo Council',
  :content => 'What is the purpose of the Gentoo Council?',
  :documentation => 'GLEPs', :question_category => non

non_q3  = Question.create! :title => 'Gentoo Council',
  :content => 'What is the purpose of the Gentoo Council?',
  :documentation => 'GLEPs', :question_category => non

# Recruiters
admin = User.create! :email_address => 'admin@recruiters.org', :name => 'Admin',
  :role => :recruiter, :password => 'secret', :password_confirmation => 'secret'

recruiter = User.create! :email_address => 'recruiter@recruiters.org',
  :name => 'Recruiter', :role => :recruiter, :password => 'secret',
  :password_confirmation => 'secret'

# Mentor. Used to be recruit, has answered questions
# in ebuild and end of mentoring quizzes and question categories.
mentor = User.create! :email_address => 'mentor@recruits.org',
  :name => 'Recruit who is Mentor', :role => :mentor, :password => 'secret',
  :password_confirmation => 'secret', :mentor => recruiter

# Recruit - no questions answered
recruit = User.create! :email_address => 'recruit@recruits.org',
  :name => 'Recruit', :role => :recruit, :password => 'secret',
  :password_confirmation => 'secret', :mentor => mentor

# Recruit - completed ebuild quiz
advanced = User.create! :email_address => 'advanced@recruits.org',
  :name => 'Advanced Recruit', :role => :recruit, :password => 'secret',
  :password_confirmation => 'secret', :mentor => mentor

# Categories for users
UserCategory.create! [{:question_category => ebuild, :user => mentor},
  {:question_category => mentoring, :user => mentor},
  {:question_category => ebuild, :user => recruit},
  {:question_category => ebuild, :user => advanced},
  {:question_category => mentoring, :user => advanced}]

def answer_q(user, question, content)
  Answer.create! :owner => user, :question => question, :content => content
end

for q in [ebuild_q1, ebuild_q2, ebuild_q3]
  for u in [mentor, recruit, advanced]
    answer_q(u, q, 'Some answer')
  end
end

for q in [mentor_q1, mentor_q2]
  for u in [mentor, advanced]
    answer_q(u, q, 'Some answer')
  end
end

answer_q(mentor, mentor_q3, 'Some answer')
