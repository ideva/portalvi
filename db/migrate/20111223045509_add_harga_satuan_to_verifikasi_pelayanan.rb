class AddHargaSatuanToVerifikasiPelayanan < ActiveRecord::Migration
  def self.up
    add_column :verifikasi_pelayanan_lains, :harga_satuan, :float
  end

  def self.down
    remove_column :verifikasi_pelayanan_lains, :harga_satuan
  end
end
