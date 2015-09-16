# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150916133213) do

  create_table "areas", force: true do |t|
    t.string   "name"
    t.string   "open_eye_area_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "movie_area_ships", force: true do |t|
    t.integer  "movie_id"
    t.integer  "area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_show",    default: false
  end

  create_table "movie_news", force: true do |t|
    t.string   "title"
    t.string   "info"
    t.string   "news_link"
    t.string   "publish_day"
    t.string   "pic_link"
    t.date     "publish_date"
    t.integer  "news_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "movie_ranks", force: true do |t|
    t.integer  "rank_type"
    t.integer  "movie_id"
    t.integer  "current_rank"
    t.integer  "last_week_rank"
    t.integer  "publish_weeks"
    t.integer  "the_week"
    t.string   "static_duration"
    t.integer  "expect_people"
    t.integer  "total_people"
    t.string   "satisfied_num"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_show",         default: false
  end

  create_table "movie_times", force: true do |t|
    t.string   "remark"
    t.string   "movie_title"
    t.text     "movie_time"
    t.string   "movie_time_open_eye_link"
    t.integer  "movie_id"
    t.integer  "theater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "area_id"
    t.string   "movie_photo"
    t.boolean  "is_show",                  default: false
  end

  create_table "movies", force: true do |t|
    t.string   "title"
    t.string   "title_eng"
    t.string   "movie_class"
    t.string   "movie_type"
    t.string   "movie_length"
    t.string   "publish_date"
    t.string   "director"
    t.string   "editors"
    t.string   "actors"
    t.string   "official"
    t.text     "movie_info"
    t.string   "small_pic"
    t.string   "large_pic"
    t.date     "publish_date_date"
    t.string   "open_eye_link"
    t.string   "yahoo_link"
    t.boolean  "is_this_week_new",    default: false
    t.boolean  "is_open_eye_crawled", default: false
    t.boolean  "is_yahoo_crawled",    default: false
    t.integer  "movie_round",         default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "photo_size",          default: 0
    t.integer  "trailer_size",        default: 0
  end

  create_table "photos", force: true do |t|
    t.string   "photo_link"
    t.integer  "movie_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "theaters", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.string   "official_site_link"
    t.string   "theater_open_eye_link"
    t.string   "yahoo_link"
    t.integer  "area_id"
    t.integer  "second_area_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trailers", force: true do |t|
    t.string   "title"
    t.string   "youtube_id"
    t.string   "youtube_link"
    t.integer  "movie_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "message"
    t.boolean  "is_learned_android"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "yahoo_news_links", force: true do |t|
    t.string   "link"
    t.integer  "news_type",  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "youtube_columns", force: true do |t|
    t.string   "title"
    t.string   "image_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_show",    default: false
  end

  create_table "youtube_sub_columns", force: true do |t|
    t.string   "name"
    t.integer  "youtube_column_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "youtube_videos", force: true do |t|
    t.string   "title"
    t.string   "youtube_id"
    t.integer  "youtube_column_id"
    t.integer  "youtube_sub_column_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
