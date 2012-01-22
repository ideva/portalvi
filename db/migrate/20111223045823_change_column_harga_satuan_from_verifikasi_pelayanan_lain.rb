class ChangeColumnHargaSatuanFromVerifikasiPelayananLain < ActiveRecord::Migration
  def self.up
    change_column :verifikasi_pelayanan_lains, :harga_satuan, :double, :default => 0
  end

  def self.down
    change_column :verifikasi_pelayanan_lains, :harga_satuan, :float, :default => 0
  end
end
