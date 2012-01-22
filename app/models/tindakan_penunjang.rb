class TindakanPenunjang < ActiveRecord::Base
  include UserInfo
  belongs_to :user, :foreign_key => "iduser"
  belongs_to :kategori_tindakan_penunjang, :foreign_key => "kode_kategori_tindakan_penunjang", :class_name => "KategoriTindakanPenunjang", :primary_key => "kode"
  

  def status_flag
    if self.flag == 1
      return "Puskesmas"
    elsif self.flag == 2
      return "Rumah Sakit"
    end
  end

  def nama_kategori
    "#{self.kode},#{self.nama}"
  end

  validates_presence_of :kode, :nama
  validates_uniqueness_of :kode, :case_sensitive => false, :message => "Kode telah digunakan"
  def upper_case_kode
    self.kode.upcase!
  end

  before_save :asign_iduser, :assign_0
  private
  def asign_iduser
    if current_user_id
      self.iduser = current_user_id
    end
  end

  def assign_0
    if self.tarif.nil?
      self.tarif = 0
    end
  end
end
