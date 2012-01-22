class CreateVerifikasiPelayananLains < ActiveRecord::Migration
  def self.up
    create_table :verifikasi_pelayanan_lains do |t|
      t.string :kode
      t.string :kode_verifikasi
      t.string :kode_pelayanan_lain
      t.integer :jumlah_pelayanan_lain
      t.string :nama_pelayanan_lain
      t.string :tgl_pelayanan_lain
      t.integer :iduser

      t.timestamps
    end
  end

  def self.down
    drop_table :verifikasi_pelayanan_lains
  end
end
