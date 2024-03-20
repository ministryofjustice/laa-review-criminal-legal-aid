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

ActiveRecord::Schema[7.1].define(version: 2024_03_15_132443) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "user_role", ["caseworker", "supervisor", "data_analyst"]

  create_table "crime_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "submitted_application"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "submitted", null: false
    t.datetime "submitted_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "returned_at", precision: nil
    t.virtual "searchable_text", type: :tsvector, as: "((to_tsvector('english'::regconfig, (submitted_application #>> '{client_details,applicant,first_name}'::text[])) || to_tsvector('english'::regconfig, (submitted_application #>> '{client_details,applicant,last_name}'::text[]))) || to_tsvector('english'::regconfig, (submitted_application ->> 'reference'::text)))", stored: true
    t.datetime "reviewed_at", precision: nil
    t.string "review_status", default: "application_received", null: false
    t.virtual "reference", type: :integer, as: "((submitted_application ->> 'reference'::text))::integer", stored: true
    t.virtual "applicant_first_name", type: :citext, as: "(submitted_application #>> '{client_details,applicant,first_name}'::text[])", stored: true
    t.virtual "applicant_last_name", type: :citext, as: "(submitted_application #>> '{client_details,applicant,last_name}'::text[])", stored: true
    t.string "offence_class"
    t.virtual "office_code", type: :string, as: "((submitted_application -> 'provider_details'::text) ->> 'office_code'::text)", stored: true
    t.jsonb "return_details"
    t.string "work_stream", default: "criminal_applications_team", null: false
    t.virtual "return_reason", type: :string, as: "(return_details ->> 'reason'::text)", stored: true
    t.virtual "case_type", type: :string, as: "((submitted_application -> 'case_details'::text) ->> 'case_type'::text)", stored: true
    t.virtual "application_type", type: :string, as: "(submitted_application ->> 'application_type'::text)", stored: true
    t.index ["applicant_last_name", "applicant_first_name"], name: "index_crime_applications_on_applicant_name"
    t.index ["application_type"], name: "index_crime_applications_on_application_type"
    t.index ["case_type"], name: "index_crime_applications_on_case_type"
    t.index ["office_code"], name: "index_crime_applications_on_office_code"
    t.index ["reference"], name: "index_crime_applications_on_reference"
    t.index ["return_reason"], name: "index_crime_applications_on_return_reason"
    t.index ["review_status", "reviewed_at"], name: "index_crime_applications_on_review_status_and_reviewed_at"
    t.index ["review_status", "submitted_at"], name: "index_crime_applications_on_review_status_and_submitted_at"
    t.index ["searchable_text"], name: "index_crime_applications_on_searchable_text", using: :gin
    t.index ["status", "returned_at"], name: "index_crime_applications_on_status_and_returned_at", order: { returned_at: :desc }
    t.index ["status", "reviewed_at"], name: "index_crime_applications_on_status_and_reviewed_at", order: { reviewed_at: :desc }
    t.index ["status", "submitted_at"], name: "index_crime_applications_on_status_and_submitted_at", order: { submitted_at: :desc }
    t.index ["work_stream"], name: "index_crime_applications_on_work_stream"
  end

  create_table "current_assignments", id: false, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "assignment_id", null: false
    t.index ["assignment_id"], name: "index_current_assignments_on_assignment_id", unique: true
    t.index ["user_id"], name: "index_current_assignments_on_user_id"
  end

  create_table "event_store_events", force: :cascade do |t|
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.binary "metadata"
    t.binary "data", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "valid_at", precision: nil
    t.index ["created_at"], name: "index_event_store_events_on_created_at"
    t.index ["event_id"], name: "index_event_store_events_on_event_id", unique: true
    t.index ["event_type"], name: "index_event_store_events_on_event_type"
    t.index ["valid_at"], name: "index_event_store_events_on_valid_at"
  end

  create_table "event_store_events_in_streams", force: :cascade do |t|
    t.string "stream", null: false
    t.integer "position"
    t.uuid "event_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["created_at"], name: "index_event_store_events_in_streams_on_created_at"
    t.index ["stream", "event_id"], name: "index_event_store_events_in_streams_on_stream_and_event_id", unique: true
    t.index ["stream", "position"], name: "index_event_store_events_in_streams_on_stream_and_position", unique: true
  end

  create_table "received_on_reports", primary_key: "business_day", id: :date, force: :cascade do |t|
    t.integer "total_received", default: 0, null: false
    t.integer "total_closed", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "redacted_crime_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "crime_application_id"
    t.jsonb "submitted_application", default: {}, null: false
    t.jsonb "metadata", default: {}, null: false
    t.virtual "status", type: :string, as: "(metadata ->> 'status'::text)", stored: true
    t.index ["crime_application_id"], name: "index_redacted_crime_applications_on_crime_application_id", unique: true
    t.index ["status"], name: "index_redacted_crime_applications_on_status"
  end

  create_table "reviews", id: false, force: :cascade do |t|
    t.uuid "application_id", null: false
    t.string "state"
    t.uuid "reviewer_id"
    t.uuid "parent_id"
    t.datetime "submitted_at", precision: nil
    t.date "business_day"
    t.string "work_stream", default: "criminal_applications_team"
    t.date "reviewed_on"
    t.string "application_type", default: "initial"
    t.index ["application_id"], name: "index_reviews_on_application_id", unique: true
    t.index ["application_type"], name: "index_reviews_on_application_type"
    t.index ["business_day"], name: "index_reviews_on_business_day"
    t.index ["parent_id"], name: "index_reviews_on_parent_id"
    t.index ["reviewed_on"], name: "index_reviews_on_reviewed_on"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["state"], name: "index_reviews_on_state"
    t.index ["work_stream"], name: "index_reviews_on_work_stream"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "auth_oid"
    t.citext "email"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_auth_at", precision: nil
    t.datetime "first_auth_at", precision: nil
    t.string "auth_subject_id"
    t.boolean "can_manage_others", default: false, null: false
    t.datetime "deactivated_at", precision: nil
    t.datetime "invitation_expires_at"
    t.datetime "revive_until"
    t.enum "role", default: "caseworker", null: false, enum_type: "user_role"
    t.index ["auth_subject_id"], name: "index_users_on_auth_subject_id", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "current_assignments", "users"
  add_foreign_key "redacted_crime_applications", "crime_applications"
end
