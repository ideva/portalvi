class DestroyUnusedFieldFromVerifikasifikas < ActiveRecord::Migration
  def self.up
    remove_column :verifikasis, :no_pelayanan
    remove_column :verifikasis, :poli
    remove_column :verifikasis, :kode_kabupaten
    remove_column :verifikasis, :kode_peserta_jkbm
    remove_column :verifikasis, :no_daftar_rs

    remove_column :verifikasi_obats, :flag

    remove_column :verifikasi_pemeriksaans, :flag

    remove_column :verifikasi_tindakans, :jenis_pelayanan
  end

  def self.down
  end
end
