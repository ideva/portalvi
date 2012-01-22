class Pemeriksaan < ActiveRecord::Base
  include UserInfo
  belongs_to :user, :foreign_key => "iduser"
  belongs_to :jenis_pelayanan, :foreign_key => "kode_jenis_pelayanan", :class_name => "JenisPelayanan", :primary_key => "kode"
  has_many :verifikasi_pemeriksaans
 

  validates_presence_of :kode, :nama
  validates_uniqueness_of :kode, :case_sensitive => false, :message => "Kode telah digunakan"
  def upper_case_kode
    self.kode.upcase!
  end

  before_save :asign_iduser, :assign_0
  

  def status_flag
    if self.flag == 1
      return "Puskesmas"
    elsif self.flag == 2
      return "Rumah Sakit"
    end
  end

  def nama_pemeriksaan
    "#{self.kode}, #{self.nama}"
  end

    

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
