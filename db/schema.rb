# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100603192118) do

  create_table "answers", :force => true do |t|
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_id"
    t.integer  "owner_id"
    t.boolean  "reference",   :default => false
  end

  add_index "answers", ["owner_id"], :name => "index_answers_on_owner_id"
  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "question_categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "documentation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_category_id"
  end

  add_index "questions", ["question_category_id"], :name => "index_questions_on_question_category_id"

  create_table "user_categories", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "question_category_id"
  end

  add_index "user_categories", ["question_category_id"], :name => "index_user_categories_on_question_category_id"
  add_index "user_categories", ["user_id"], :name => "index_user_categories_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "email_address"
    t.boolean  "administrator",                           :default => false
    t.string   "role",                                    :default => "recruit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "active"
    t.datetime "key_timestamp"
    t.integer  "mentor_id"
  end

  add_index "users", ["mentor_id"], :name => "index_users_on_mentor_id"
  add_index "users", ["state"], :name => "index_users_on_state"

end
