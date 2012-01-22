class AddIduserToPoli < ActiveRecord::Migration
  def self.up
    add_column :polis, :iduser, :integer
  end

  def self.down
    remove_column :polis, :iduser
  end
end
