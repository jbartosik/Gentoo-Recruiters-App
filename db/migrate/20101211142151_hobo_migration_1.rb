class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :project_acceptances do |t|
      t.string   :accepting_nick, :null => false
      t.boolean  :accepted, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id, :null => false
    end
    add_index :project_acceptances, [:user_id]

    create_table :question_categories do |t|
      t.string   :name, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :comments do |t|
      t.text     :content, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :answer_id, :null => false
      t.integer  :owner_id
    end
    add_index :comments, [:answer_id]
    add_index :comments, [:owner_id]

    create_table :questions do |t|
      t.string   :title, :null => false
      t.string   :documentation
      t.boolean  :approved, :default => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id
      t.integer  :question_category_id
      t.integer  :question_group_id
    end
    add_index :questions, [:user_id]
    add_index :questions, [:question_category_id]
    add_index :questions, [:question_group_id]

    create_table :question_content_multiple_choices do |t|
      t.text     :content, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :question_id, :null => false
    end
    add_index :question_content_multiple_choices, [:question_id]

    create_table :question_groups do |t|
      t.string   :name, :null => false
      t.text     :description, :null => false
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :question_content_emails do |t|
      t.text     :requirements, :null => false, :default => ""
      t.text     :description
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :question_id, :null => false
    end
    add_index :question_content_emails, [:question_id]

    create_table :user_categories do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id, :null => false
      t.integer  :question_category_id, :null => false
    end
    add_index :user_categories, [:user_id]
    add_index :user_categories, [:question_category_id]

    create_table :user_question_groups do |t|
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :user_id, :null => false
      t.integer  :question_id, :null => false
    end
    add_index :user_question_groups, [:user_id]
    add_index :user_question_groups, [:question_id]

    create_table :question_content_texts do |t|
      t.text     :content, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :question_id, :null => false
    end
    add_index :question_content_texts, [:question_id]

    create_table :users do |t|
      t.string   :crypted_password, :limit => 40
      t.string   :salt, :limit => 40
      t.string   :remember_token
      t.datetime :remember_token_expires_at
      t.string   :name
      t.string   :email_address
      t.boolean  :administrator, :default => false
      t.string   :role, :default => "recruit"
      t.string   :nick
      t.string   :openid
      t.text     :contributions
      t.boolean  :project_lead, :default => false
      t.string   :token
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :mentor_id
      t.string   :state, :default => "active"
      t.datetime :key_timestamp
    end
    add_index :users, [:mentor_id]
    add_index :users, [:state]

    create_table :options do |t|
      t.string   :content, :null => false
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :option_owner_id, :null => false
      t.string   :option_owner_type, :null => false
    end
    add_index :options, [:option_owner_type, :option_owner_id]

    create_table :answers do |t|
      t.text     :content, :null => false, :default => ""
      t.boolean  :approved, :default => false
      t.boolean  :reference, :default => false
      t.string   :feedback, :default => ""
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :question_id, :null => false
      t.integer  :owner_id
      t.boolean  :correct
      t.string   :type
    end
    add_index :answers, [:question_id]
    add_index :answers, [:owner_id]
    add_index :answers, [:type]
  end

  def self.down
    drop_table :project_acceptances
    drop_table :question_categories
    drop_table :comments
    drop_table :questions
    drop_table :question_content_multiple_choices
    drop_table :question_groups
    drop_table :question_content_emails
    drop_table :user_categories
    drop_table :user_question_groups
    drop_table :question_content_texts
    drop_table :users
    drop_table :options
    drop_table :answers
  end
end
