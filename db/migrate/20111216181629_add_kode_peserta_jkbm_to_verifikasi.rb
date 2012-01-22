class AddKodePesertaJkbmToVerifikasi < ActiveRecord::Migration
  def self.up
    add_column :verifikasis, :kode_peserta_jkbm, :string
  end

  def self.down
    remove_column :verifikasis, :kode_peserta_jkbm
  end
end
