class CreateInstalasiLayanans < ActiveRecord::Migration
  def self.up
    create_table :instalasi_layanans do |t|
      t.string :kode
      t.string :nama
      t.integer :iduser

      t.timestamps
    end
  end

  def self.down
    drop_table :instalasi_layanans
  end
end
