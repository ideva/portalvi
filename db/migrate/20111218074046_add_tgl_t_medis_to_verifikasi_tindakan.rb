class AddTglTMedisToVerifikasiTindakan < ActiveRecord::Migration
  def self.up
    add_column :verifikasi_tindakans, :tgl_t_medis, :string
  end

  def self.down
    remove_column :verifikasi_tindakans, :tgl_t_medis
  end
end
