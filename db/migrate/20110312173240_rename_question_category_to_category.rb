class RenameQuestionCategoryToCategory < ActiveRecord::Migration
  def self.up
    rename_table :question_categories, :categories

    rename_column :questions, :question_category_id, :category_id

    rename_column :user_categories, :question_category_id, :category_id

    remove_index :questions, :name => :index_questions_on_question_category_id rescue ActiveRecord::StatementInvalid
    add_index :questions, [:category_id]

    remove_index :user_categories, :name => :index_user_categories_on_question_category_id rescue ActiveRecord::StatementInvalid
    add_index :user_categories, [:category_id]
  end

  def self.down
    rename_column :questions, :category_id, :question_category_id

    rename_column :user_categories, :category_id, :question_category_id

    rename_table :categories, :question_categories

    remove_index :questions, :name => :index_questions_on_category_id rescue ActiveRecord::StatementInvalid
    add_index :questions, [:question_category_id]

    remove_index :user_categories, :name => :index_user_categories_on_category_id rescue ActiveRecord::StatementInvalid
    add_index :user_categories, [:question_category_id]
  end
end
