class AddSentToVerifikasi < ActiveRecord::Migration
  def self.up
    add_column :verifikasis, :sent_to_vi, :boolean, :default => false
  end

  def self.down
    remove_column :verifikasis, :sent_to_vi
  end
end
