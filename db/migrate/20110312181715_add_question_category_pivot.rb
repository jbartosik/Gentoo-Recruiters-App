class AddQuestionCategoryPivot < ActiveRecord::Migration
  def self.up
    create_table :question_categories do |t|
      t.integer :question_id, :null => false
      t.integer :category_id, :null => false
    end
    add_index :question_categories, [:question_id, :category_id], :unique => true

    remove_column :questions, :category_id

    remove_index :questions, :name => :index_questions_on_category_id rescue ActiveRecord::StatementInvalid
  end

  def self.down
    add_column :questions, :category_id, :integer

    drop_table :question_categories

    add_index :questions, [:category_id]
  end
end
