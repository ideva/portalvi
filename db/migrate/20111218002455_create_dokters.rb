class CreateDokters < ActiveRecord::Migration
  def self.up
    create_table :dokters do |t|
      t.string :kode
      t.string :nama

      t.timestamps
    end
  end

  def self.down
    drop_table :dokters
  end
end
