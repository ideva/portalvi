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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120103223007) do

  create_table "alasan_verifikasis", :force => true do |t|
    t.string   "kode"
    t.string   "alasan"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alasan_verifikasis", ["iduser"], :name => "NewIndex1"

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.text     "meta_description"
    t.string   "meta_keyword"
    t.boolean  "is_publish",       :default => false
    t.integer  "idpage",           :default => 0
    t.integer  "iduser",           :default => 0
    t.boolean  "use_image_slide",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment"
    t.boolean  "allow_comment"
    t.integer  "counter"
  end

  create_table "dokters", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  create_table "f_user_levels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "functions", :force => true do |t|
    t.string   "name"
    t.string   "action_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "controller_name"
  end

  create_table "galleries", :force => true do |t|
    t.string   "image"
    t.string   "remote_image_url"
    t.string   "caption"
    t.integer  "idalbum"
    t.integer  "idblog"
    t.integer  "iduser",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_cover"
    t.integer  "image_order"
    t.string   "session_id"
    t.string   "code"
  end

  create_table "instalasi_layanans", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jenis_pelayanans", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "jenis_pelayanans", ["kode"], :name => "NewIndex1"

  create_table "kabupatens", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kabupatens", ["kode"], :name => "NewIndex1"

  create_table "kategori_obats", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "kategori_obats", ["iduser"], :name => "NewIndex2"
  add_index "kategori_obats", ["kode"], :name => "NewIndex1", :unique => true

  create_table "kategori_tindakan_medis", :force => true do |t|
    t.string   "kode",       :null => false
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "kategori_tindakan_medis", ["kode"], :name => "NewIndex1"

  create_table "kategori_tindakan_penunjangs", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "kategori_tindakan_penunjangs", ["kode"], :name => "NewIndex1"

  create_table "l_cities", :force => true do |t|
    t.integer  "idprovincy"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_active",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "idcountry"
  end

  add_index "l_cities", ["idprovincy"], :name => "NewIndex1"

  create_table "l_countries", :force => true do |t|
    t.string   "iso"
    t.string   "name"
    t.string   "printable_name"
    t.string   "iso3"
    t.integer  "numcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",      :default => true
  end

  create_table "l_provincies", :force => true do |t|
    t.integer  "idcountry"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_active",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "l_provincies", ["idcountry"], :name => "NewIndex1"

  create_table "lock_tables", :force => true do |t|
    t.string   "model"
    t.integer  "iduser_access"
    t.string   "session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "id_to_lock"
    t.integer  "counter",         :default => 0
    t.string   "controller_name"
    t.string   "action_name"
  end

  create_table "obats", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.string   "kode_kategori"
    t.string   "bentuk_kekuatan_kemasan"
    t.integer  "jumlah",                  :default => 0
    t.string   "satuan"
    t.float    "het_satuan",              :default => 0.0
    t.float    "het_pack",                :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "obats", ["iduser"], :name => "NewIndex1"

  create_table "pages", :force => true do |t|
    t.string   "name"
    t.boolean  "is_active",    :default => false
    t.integer  "parent_page"
    t.boolean  "is_home_page", :default => false
    t.integer  "order_page"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser",       :default => 0
    t.text     "flash_news"
  end

  create_table "pelayanan_lains", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.string   "tarif"
    t.string   "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pemeriksaans", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.float    "tarif",                :default => 0.0
    t.integer  "flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
    t.string   "kode_jenis_pelayanan", :default => ""
  end

  add_index "pemeriksaans", ["iduser"], :name => "NewIndex1"

  create_table "peserta_jkbms", :force => true do |t|
    t.string   "kode"
    t.string   "no_pelayanan"
    t.string   "no_kk"
    t.string   "nik"
    t.string   "ktp"
    t.string   "no_ejkbm"
    t.string   "kode_kabupaten"
    t.integer  "flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nama_pasien"
    t.text     "alamat"
    t.datetime "tgl_masuk"
  end

  add_index "peserta_jkbms", ["kode_kabupaten"], :name => "NewIndex1"

  create_table "polis", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  create_table "ru_pusks", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", :force => true do |t|
    t.string   "name"
    t.string   "string_value"
    t.integer  "integer_value"
    t.boolean  "boolean_value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_plants", :force => true do |t|
    t.string   "tanggal"
    t.string   "menu"
    t.string   "url"
    t.text     "skenario"
    t.boolean  "hasil"
    t.text     "deskripsi_hasil"
    t.text     "komentar"
    t.string   "image"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tindakan_medis", :force => true do |t|
    t.string   "kode"
    t.string   "kode_kategori_tindakan_medis"
    t.string   "nama"
    t.float    "tarif",                        :default => 0.0
    t.string   "flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "tindakan_medis", ["kode_kategori_tindakan_medis"], :name => "NewIndex1"

  create_table "tindakan_penunjangs", :force => true do |t|
    t.string   "kode"
    t.string   "kode_kategori_tindakan_penunjang"
    t.string   "nama"
    t.float    "tarif",                            :default => 0.0
    t.string   "flag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "iduser"
  end

  add_index "tindakan_penunjangs", ["kode_kategori_tindakan_penunjang"], :name => "NewIndex1"

  create_table "user_type_functions", :force => true do |t|
    t.integer  "iduser_type"
    t.integer  "idfunction"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_type_functions", ["iduser_type"], :name => "NewIndex2"

  create_table "user_types", :force => true do |t|
    t.string   "kode"
    t.string   "nama"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_types", ["kode"], :name => "NewIndex1"

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.boolean  "super_admin",                              :default => false
    t.integer  "iduser_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["id"], :name => "IndexUser1", :unique => true
  add_index "users", ["id"], :name => "NewIndex1"
  add_index "users", ["iduser_type"], :name => "NewIndex2"
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "verifikasi_logs", :force => true do |t|
    t.integer  "status_verifikasi_verifikator_sebelum"
    t.integer  "status_verifikasi_verifikator_sesudah"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kode_verifikasi"
  end

  add_index "verifikasi_logs", ["iduser"], :name => "NewIndex2"
  add_index "verifikasi_logs", ["kode_verifikasi"], :name => "NewIndex1"

  create_table "verifikasi_obats", :force => true do |t|
    t.string   "kode"
    t.string   "kode_verifikasi"
    t.string   "kode_obat"
    t.integer  "jumlah_obat"
    t.string   "nama_obat"
    t.string   "tgl_obat"
    t.boolean  "status_verifikasi_sistem",      :default => false
    t.integer  "status_verifikasi_verifikator", :default => 0
    t.string   "kode_alasan_verifikasi"
    t.string   "komentar"
    t.float    "harga_satuan",                  :default => 0.0
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "verifikasi_obats", ["iduser"], :name => "NewIndex1"
  add_index "verifikasi_obats", ["kode_verifikasi"], :name => "FK_verifikasi_obats"

  create_table "verifikasi_pelayanan_lains", :force => true do |t|
    t.string   "kode"
    t.string   "kode_verifikasi"
    t.string   "kode_pelayanan_lain"
    t.integer  "jumlah_pelayanan_lain"
    t.string   "nama_pelayanan_lain"
    t.string   "tgl_pelayanan_lain"
    t.float    "harga_satuan",                  :default => 0.0
    t.boolean  "status_verifikasi_sistem",      :default => false
    t.integer  "status_verifikasi_verifikator", :default => 0
    t.string   "kode_alasan_verifikasi"
    t.string   "komentar"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "verifikasi_pelayanan_lains", ["kode_verifikasi"], :name => "FK_verifikasi_pelayanan_lains"

  create_table "verifikasi_pemeriksaans", :force => true do |t|
    t.string   "kode"
    t.string   "kode_verifikasi"
    t.string   "kode_pemeriksaan"
    t.integer  "jumlah"
    t.boolean  "status_verifikasi_sistem",      :default => false
    t.integer  "status_verifikasi_verifikator", :default => 0
    t.string   "kode_alasan_verifikasi"
    t.string   "komentar"
    t.float    "harga_satuan",                  :default => 0.0
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "verifikasi_pemeriksaans", ["iduser"], :name => "FK_verifikasi_pemeriksaans"
  add_index "verifikasi_pemeriksaans", ["kode_verifikasi"], :name => "NewIndex1"

  create_table "verifikasi_request_logs", :force => true do |t|
    t.text     "request_in"
    t.text     "request_out"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "verifikasi_tindakans", :force => true do |t|
    t.string   "kode",                                             :null => false
    t.string   "kode_verifikasi"
    t.string   "kode_t_medis"
    t.integer  "jumlah_t_medis"
    t.string   "nama_t_medis"
    t.string   "tgl_t_medis"
    t.float    "harga_satuan",                  :default => 0.0
    t.boolean  "status_verifikasi_sistem",      :default => false
    t.integer  "status_verifikasi_verifikator", :default => 0
    t.string   "kode_alasan_verifikasi"
    t.string   "komentar"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "flag"
  end

  add_index "verifikasi_tindakans", ["iduser"], :name => "NewIndex1"
  add_index "verifikasi_tindakans", ["kode_verifikasi"], :name => "NewIndex2"

  create_table "verifikasis", :force => true do |t|
    t.string   "kode",                                        :null => false
    t.string   "tgl_masuk",                :default => ""
    t.string   "tgl_keluar",               :default => ""
    t.integer  "lama_dirawat",             :default => 0
    t.string   "no_kk",                    :default => ""
    t.string   "nik",                      :default => ""
    t.string   "ktp",                      :default => ""
    t.string   "dokter",                   :default => ""
    t.string   "keluhan",                  :default => ""
    t.string   "diagnosa_icd",             :default => ""
    t.string   "nama_pasien"
    t.string   "no_ejkbm"
    t.string   "norm"
    t.string   "no_klaim_rs"
    t.string   "no_skp_ejkbm"
    t.integer  "status_pengiriman",        :default => 0
    t.boolean  "status_verifikasi_sistem", :default => false
    t.integer  "status_verifikasi",        :default => 0
    t.float    "total_tarif",              :default => 0.0
    t.integer  "kode_jenis_pelayanan"
    t.string   "alamat"
    t.boolean  "sent_to_vi",               :default => false
    t.text     "komentar"
    t.integer  "iduser"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kode_instalasi_layanan"
    t.string   "kode_kabupaten"
    t.text     "nama_diagnosa_icd"
    t.string   "nama_instalasi_layanan"
  end

  add_index "verifikasis", ["iduser"], :name => "NewIndex2"
  add_index "verifikasis", ["kode"], :name => "NewIndex1", :unique => true
  add_index "verifikasis", ["kode"], :name => "index_verifikasi_obat"

end
