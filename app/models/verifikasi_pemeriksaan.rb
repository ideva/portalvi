class VerifikasiPemeriksaan < ActiveRecord::Base
  # flag = 1 - data tindakan medis
  # flag = 2 - data tidak ditemukan dalam mapping

  include UserInfo
  belongs_to :user, :foreign_key => "iduser"
  before_save :asign_iduser
  def asign_iduser
    if current_user_id
      self.iduser = current_user_id
    end
  end

  validates_uniqueness_of :kode, :case_sensitive => false, :message => "Kode telah digunakan"
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

 belongs_to :verifikasi, :foreign_key => "kode_verifikasi",
             :class_name => "Verifikasi", :primary_key => "kode"
 belongs_to :pemeriksaan, :foreign_key => "kode_pemeriksaan",
             :class_name => "Pemeriksaan", :primary_key => "kode"
 belongs_to :alasan_verifikasi, :foreign_key => "kode_alasan_verifikasi",
             :class_name => "AlasanVerifikasi", :primary_key => "kode"


  def status_verifikasi
    if self.flag == 1
      return "Sukses"
    elsif self.flag == 2
      return "Gagal"
    end
  end

    def status_verifikasi
    if self.status_verifikasi_verifikator == 0
      return "Belum terproses"
    elsif self.status_verifikasi_verifikator == 1
      return "Layak"
    elsif self.status_verifikasi_verifikator == 2
      return "Tidak Layak"
    elsif self.status_verifikasi_verifikator == 3
      return "Perbaikan"
    end
  end
end
