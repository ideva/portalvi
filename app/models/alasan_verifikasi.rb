class AlasanVerifikasi < ActiveRecord::Base
  include UserInfo
  belongs_to :user, :foreign_key => "iduser"
  before_save :asign_iduser
  def asign_iduser
    if current_user_id
      self.iduser = current_user_id
    end
  end

  validates_presence_of :kode, :alasan
  validates_uniqueness_of :kode, :case_sensitive => false, :message => "Kode telah digunakan"
  def upper_case_kode
    self.kode.upcase!
  end
  before_create :generate_code
  def generate_code
    kode = code_generator(AWALAN_KODE, 5) #code_generator(param, length)
    if self.class.find_by_kode(kode).nil?
      self.kode = kode
      #self.save
    else
      generate_code
    end
  end
  
  has_many :verifikasis


  before_destroy :check_cascade


  private

  def check_cascade
    unless Verifikasi.find_by_kode_alasan_verifikasi(self.kode).nil?
      return false
    end
    return true
  end
  
  
end
