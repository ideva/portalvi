class CreateKategoriTindakanPenunjangs < ActiveRecord::Migration
  def self.up
    create_table :kategori_tindakan_penunjangs do |t|
      t.string :kode
      t.string :nama
      t.timestamps
    end
  end

  def self.down
    drop_table :kategori_tindakan_penunjangs
  end
end
