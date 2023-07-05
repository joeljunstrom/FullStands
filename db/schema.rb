# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_07_01_190355) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "ticket_source_status", ["pending", "processing", "completed", "rejected"]
  create_enum "ticket_status", ["pending", "processing", "available", "claimed", "rejected"]

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.bigint "opponent_id"
    t.datetime "occurs_at", precision: nil
    t.index ["occurs_at"], name: "index_games_on_occurs_at", unique: true
    t.index ["opponent_id"], name: "index_games_on_opponent_id"
  end

  create_table "sections", force: :cascade do |t|
    t.text "name"
    t.text "entrance"
    t.index ["name"], name: "index_sections_on_name", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.citext "name"
    t.index ["name"], name: "index_teams_on_name", unique: true
  end

  create_table "ticket_sources", force: :cascade do |t|
    t.bigint "ticket_id"
    t.text "message_id", null: false
    t.enum "status", default: "pending", null: false, enum_type: "ticket_source_status"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ticket_id"], name: "index_ticket_sources_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "section_id"
    t.enum "status", default: "pending", null: false, enum_type: "ticket_status"
    t.text "identifier"
    t.text "row"
    t.text "seat"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_tickets_on_game_id"
    t.index ["identifier"], name: "index_tickets_on_identifier", unique: true
    t.index ["section_id"], name: "index_tickets_on_section_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "games", "teams", column: "opponent_id"
  add_foreign_key "ticket_sources", "tickets"
  add_foreign_key "tickets", "games"
  add_foreign_key "tickets", "sections"
end
