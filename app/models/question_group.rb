class QuestionGroup < ActiveRecord::Base

  hobo_model # Don't put anything above this

  fields do
    name        :string, :null => false
    description HoboFields::MarkdownString, :null => false
    timestamps
  end

  has_many :questions
  validates_presence_of   :name, :description
  validates_uniqueness_of :name
  include Permissions::AnyoneCanViewAdminCanChange

  named_scope :in_category, lambda { |cid| {
    :joins => :questions, :conditions => ['questions.question_category_id = ?', cid],
    :group => 'question_groups.id, question_groups.name, question_groups.description,
      question_groups.created_at, question_groups.updated_at'}}

  named_scope :unassociated_in_category, lambda { |uid, cid| {
    :joins => :questions, :conditions => ['questions.question_category_id = ? AND NOT EXISTS
      (SELECT user_question_groups.* FROM user_question_groups INNER JOIN questions ON
      questions.id = user_question_groups.question_id WHERE (user_question_groups.user_id = ?
      AND questions.question_group_id = question_groups.id))', cid, uid],
    :group => 'question_groups.id, question_groups.name, question_groups.description,
      question_groups.created_at, question_groups.updated_at'}}
end
