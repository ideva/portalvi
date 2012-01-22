class AddIdUser < ActiveRecord::Migration
  def self.up
    add_column :obats, :iduser, :integer
    add_column :kategori_obats, :iduser, :integer
    add_column :pemeriksaans, :iduser, :integer
  end

  def self.down
    remove_column :obats, :iduser
    remove_column :kategori_obats, :iduser
    remove_column :pemeriksaans, :iduser
  end
end
