class ChangeColumnHargaSatuan < ActiveRecord::Migration
  def self.up
    change_column :verifikasi_obats, :harga_satuan, :double, :default => 0
    change_column :verifikasi_pemeriksaans, :harga_satuan, :double, :default => 0
    change_column :verifikasi_tindakans, :harga_satuan, :double, :default => 0
  end

  def self.down
    change_column :verifikasi_obats, :harga_satuan, :float, :default => 0
    change_column :verifikasi_pemeriksaans, :harga_satuan, :float, :default => 0
    change_column :verifikasi_tindakans, :harga_satuan, :float, :default => 0
  end
end
