class AddHargaSatuan < ActiveRecord::Migration
  def self.up
    add_column :verifikasi_obats, :harga_satuan, :float
    add_column :verifikasi_pemeriksaans, :harga_satuan, :float
    add_column :verifikasi_tindakans, :harga_satuan, :float
  end

  def self.down
    remove_column :verifikasi_obats, :harga_satuan
    remove_column :verifikasi_pemeriksaans, :harga_satuan
    remove_column :verifikasi_tindakans, :harga_satuan
  end
end
