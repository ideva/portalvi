class AddIduserToDokter < ActiveRecord::Migration
  def self.up
    add_column :dokters, :iduser, :integer
  end

  def self.down
    remove_column :dokters, :iduser
  end
end
