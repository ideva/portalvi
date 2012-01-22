class PesertaJkbm < ActiveRecord::Base
  # flag = 0 -> data baru
  # flag = 1 -> data telah diproses, siap dikirim, dapat diedit
  # flag = 2 -> data telah dikirim ke VI, tidak dapat diedit lagi
  # flag = 3 -> data yang harus diperbaiki, VI mengirimkan perbaikan

  belongs_to :kabupaten, :foreign_key => "kode_kabupaten", :class_name => "Kabupaten", :primary_key => "kode"
  
  before_create :generate_code, :set_flag_baru

  validates_uniqueness_of :kode, :case_sensitive => false, :message => "Kode telah digunakan"
  def upper_case_kode
    self.kode.upcase!
  end
  
  def generate_code
    kode = code_generator(AWALAN_KODE, 5) #code_generator(param, length)
    if self.class.find_by_kode(kode).nil?
      self.kode = kode
      #self.save
    else
      generate_code
    end
  end

  def set_flag_baru
    self.flag = 0
  end

  def status_data
    if self.flag == 0
      return "Baru"
    elsif self.flag == 1
      return "Siap dikirim"
    elsif self.flag == 2
      return "Telah dikirim"
    elsif self.flag == 3
      return "Perlu perbaikan"
    end
  end
end
