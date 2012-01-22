class ChangeColumnStatusPengirimanFromVerifikasi < ActiveRecord::Migration
  def self.up
    change_column :verifikasis, :status_pengiriman, :integer, :default => 0
  end

  def self.down
    hange_column :verifikasis, :status_pengiriman, :boolean, :default => false
  end
end
