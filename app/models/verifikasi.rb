class Verifikasi < ActiveRecord::Base
  @@recently_save = false
  # status_verifikasi_verifikator = 0 - belum diproses atau data baru
  # status_verifikasi_verifikator = 1 - Sukses
  # status_verifikasi_verifikator = 2 - Gagal
  # status_verifikasi_verifikator = 3 - Pending

  include UserInfo
  belongs_to :user, :foreign_key => "iduser"
  before_save :asign_iduser, :assign_0, :check_lama_dirawat, :asign_nama_pelayanan
  def asign_iduser
    if current_user_id
      self.iduser = current_user_id
    end
  end

  def asign_nama_pelayanan
    instalasi_layanan = InstalasiLayanan.find_by_kode(self.kode_instalasi_layanan)
    self.nama_instalasi_layanan = instalasi_layanan.nama rescue ''
  end

  def check_lama_dirawat
    lama_dirawat = 0
    begin
      if self.tgl_masuk < self.tgl_keluar
        lama_dirawat = self.tgl_keluar.to_date - self.tgl_masuk.to_date
      else
        lama_dirawat = 0
      end
    rescue
    end
    self.lama_dirawat = lama_dirawat
  end

  def assign_0
    if self.lama_dirawat.nil?
      self.lama_dirawat = 0
    end
  end

  validate :check_date
  def check_date
    if self.tgl_masuk.to_date > self.tgl_keluar.to_date
      errors.add(:base, "Tgl masuk harus < Tgl keluar")
      return false
    end
  end

  validates_uniqueness_of :kode, :case_sensitive => false, :message => "Kode telah digunakan"
  def upper_case_kode
    self.kode.upcase!
  end
  
  before_create :generate_code
  def generate_code
    @@recently_save = true
    kode = code_generator(AWALAN_KODE, 5) #code_generator(param, length)
    if self.class.find_by_kode(kode).nil?
      self.kode = kode
      #self.save
    else
      generate_code
    end
  end

  has_many :verifikasi_obats
  has_many :verifikasi_tindakans
  belongs_to :alasan_verifikasi, :foreign_key => "kode_alasan_verifikasi", :class_name => "AlasanVerifikasi", :primary_key => "kode"
  belongs_to :kabupaten, :foreign_key => "kode_kabupaten", :class_name => "Kabupaten", :primary_key => "kode"
  belongs_to :peserta_jkbm, :foreign_key => "kode_peserta_jkbm", :class_name => "PesertaJkbm", :primary_key => "kode"
  belongs_to :jenis_pelayanan, :foreign_key => "kode_jenis_pelayanan", :class_name => "JenisPelayanan", :primary_key => "kode"
  belongs_to :instalasi_layanan, :foreign_key => "kode_instalasi_layanan", :class_name => "InstalasiLayanan", :primary_key => "kode"

  def status_verifikasi_text
    if self.status_verifikasi == 0
      return "Belum terproses"
    elsif self.status_verifikasi == 1
      return "Layak"
    elsif self.status_verifikasi == 2
      return "Tidak Layak"
    elsif self.status_verifikasi == 3
      return "Perbaikan"
    end
  end

  def respon_verifikasi_sistem
    if self.status_verifikasi_sistem
      return "Sukses"
    else
      return "Gagal"
    end
  end

  after_save :set_log
  def set_log
    kode_verifikasi = self.kode
    verifikasi_log = VerifikasiLog.new
    verifikasi_lama = Verifikasi.find_by_kode(kode_verifikasi)
    verifikasi_log.kode_verifikasi = kode_verifikasi
    verifikasi_log.status_verifikasi_verifikator_sebelum = verifikasi_lama.status_verifikasi_verifikator rescue 0
    verifikasi_log.status_verifikasi_verifikator_sesudah = self.status_verifikasi_verifikator rescue 0
    verifikasi_log.save
  end

  def self.ambil_data_kepersetaan_ejkbm
    setting = Setting.find_by_name('URL_WS_EJKBM_AMBIL_DATA_KEPERSETAAN')
    url = setting.string_value+"&tanggal="+Date.today.to_s
    #url = "http://10.20.52.102/ws_kepesertaan/service1.asmx/getLog?passCode=123456&tanggal=2011-05-10"
    #puts "---------------------------#{url}-----------------------------"

    require "net/http"
    require "uri"
    require "rexml/document"
    begin
      result = Net::HTTP.get(URI.parse(url))
      #puts result
      doc = REXML::Document.new result.to_s
      root = doc.root
      #puts root.attributes["xmlns"]
      #puts root.elements["diffgr:diffgram/NewDataSet/Table"].attributes["diffgr:id"]
      root.elements.each("diffgr:diffgram/NewDataSet/Table") do |element|

        no_ejkbm = element[3].text
        no_kk = element[5].text
        nik = element[7].text
        nama_pasien = element[9].text
        tgl_masuk = element[11].text.to_s
        kode_kabupaten = element[13].text.to_s

        verifikasi = Verifikasi.find_by_no_ejkbm_and_no_kk_and_nik_and_nama_pasien_and_tgl_masuk(no_ejkbm, no_kk, nik, nama_pasien, tgl_masuk )
        if verifikasi.nil?
          verifikasi = Verifikasi.new
        end
        verifikasi.no_ejkbm = no_ejkbm
        verifikasi.no_kk = no_kk
        verifikasi.nik = nik
        verifikasi.kode_kabupaten = kode_kabupaten
        verifikasi.nama_pasien = nama_pasien
        verifikasi.tgl_masuk = (tgl_masuk.to_time.to_date rescue '')
        verifikasi.save(perform_validation = false)
      end
      #data = doc.root.elements['/DataTable/xs:schema'].text
      #puts "--------------------------------------------------------"
      status = true
    rescue
      status = false
    end
    return status
  end

  def self.sent_to_vi(verifikasi='')
    uri = '-'
    parameter = '-'
    result = '-'
    
    status_pengiriman = false
    #peserta_jkbm = PesertaJkbm.find_by_flag(1)
    #unless peserta_jkbm.nil?
      setting = Setting.find_by_name('URL_WS_VI')
    if verifikasi == ''
      verifikasi = Verifikasi.where("status_pengiriman = ? AND sent_to_vi = ?", 1, 0).first
    end
      parameter = param_verifikasi(verifikasi)
#      full_url = "#{setting.string_value}?#{URI.escape(param)}"
#      puts "-- #{full_url} --"

      require "net/http"
      require "uri"
      require "rexml/document"
      begin
        #result = Net::HTTP.get(URI.parse(full_url))
        uri = URI(setting.string_value)
        result = Net::HTTP.post_form(uri, parameter)
        result = result.body
        puts result

        x = REXML::Document.new result.to_s
        status =  x.root.elements['/verifikasi/status_pengiriman'].text
        puts "-----------------Status Pengiriman= #{status}------------------------------"
        if status.to_s == "1"
          status_verifikasi_sistem =  x.root.elements['/verifikasi/status_verifikasi'].text
          puts "-----------------Status Verifikasi= #{status_verifikasi_sistem}------------------------------"
          if status_verifikasi_sistem.to_s == "1"         
            verifikasi.status_verifikasi_sistem = true
          else
            verifikasi.status_verifikasi_sistem = false
          end
          verifikasi.sent_to_vi = true  
          verifikasi.status_pengiriman = 2
          verifikasi.save
          status_pengiriman = true
        else
          status_pengiriman = false
        end
      rescue
        status_pengiriman = false
      end

      verifikasi_log = VerifikasiRequestLog.new
      verifikasi_log.request_out = "\n--URL-------\n"+uri.to_s+"\n--Parameter-------\n"+parameter.to_s+"\n--Result-------\n"+result
      verifikasi_log.save
      puts "-- #{status_pengiriman} --"
      
      return status_pengiriman
    #end
  end

  def self.param_verifikasi(verifikasi)
    unless verifikasi.nil?
      no_ejkbm = verifikasi.no_ejkbm
      no_transaksi_ejkbm = verifikasi.no_skp_ejkbm
      nama_pasien = verifikasi.nama_pasien
      no_kk =verifikasi.no_kk
      nik =verifikasi.nik
      no_ktp = verifikasi.ktp
      kode_kabupaten = verifikasi.kode_kabupaten
      kode_ru_pusk = Setting.find_by_name('RS_PUSK_KODE').string_value
      #alamat = verifikasi.alamat

      no_klaim = verifikasi.kode
      no_reg = verifikasi.kode
      norm = verifikasi.norm
      tgl_masuk = verifikasi.tgl_masuk
      tgl_keluar = verifikasi.tgl_keluar
      lama_dirawat = verifikasi.lama_dirawat
      nama_dokter = verifikasi.dokter
      kode_instalasi_layanan = verifikasi.kode_instalasi_layanan
      nama_instalasi_layanan = verifikasi.nama_instalasi_layanan
      keluhan = verifikasi.keluhan
      diagnosa_icd = verifikasi.diagnosa_icd
      nama_diagnosa_icd = verifikasi.nama_diagnosa_icd
      kode_jenis_pelayanan  = verifikasi.kode_jenis_pelayanan
      total_tarif = verifikasi.total_tarif
      #no_daftar = verifikasi.no_daftar_rs

      parameter = {"no_klaim" => no_klaim, "no_reg" => no_reg, "no_transaksi_ejkbm" => no_transaksi_ejkbm,
                   "norm" => norm, "no_ejkbm" => no_ejkbm, "nama_pasien" => nama_pasien,
                   "tgl_masuk" => tgl_masuk, "tgl_keluar" => tgl_keluar, "lama_dirawat" => lama_dirawat,
                   "nik" => nik, "nomor_kk" => no_kk, "no_ktp" => no_ktp, "nama_dokter" => nama_dokter,
                   "kode_instalasi_layanan" => kode_instalasi_layanan, "nama_instalasi_layanan" => nama_instalasi_layanan,
                   "keluhan" => keluhan,
                   "diagnosa_icd" => diagnosa_icd, "nama_diagnosa_icd" => nama_diagnosa_icd,
                   "jenis_pelayanan" => kode_jenis_pelayanan,
                   "total_tarif" => total_tarif, "kode_kabupaten" => kode_kabupaten,
                   "kode_ru_pusk" => kode_ru_pusk
                   }
      #parameter = "no_klaim=#{no_klaim}&no_transaksi_ejkbm=#{no_transaksi_ejkbm}&norm=#{norm}&no_ejkbm=#{no_ejkbm}&nama_pasien=#{nama_pasien}&tgl_masuk=#{tgl_masuk}&tgl_keluar=#{tgl_keluar}&lama_dirawat=#{lama_dirawat}&nik=#{nik}&nomor_kk=#{no_kk}&no_ktp=#{no_ktp}&nama_dokter=#{nama_dokter}&kode_instalasi_layanan=#{kode_instalasi_layanan}&keluhan=#{keluhan}&diagnosa_icd=#{diagnosa_icd}&jenis_pelayanan=#{kode_jenis_pelayanan}"
      kode_verifikasi = verifikasi.kode

      parameter.merge!(param_pemeriksaan_to_vi(kode_verifikasi))
      parameter.merge!(param_tindakan_medis_to_vi(kode_verifikasi))
      parameter.merge!(param_obat_to_vi(kode_verifikasi))
      parameter.merge!(param_pelayanan_lain_to_vi(kode_verifikasi))

    else
      parameter = ''
    end
    return  parameter
  end

  def self.param_pemeriksaan_to_vi(kode_verifikasi)
    param_kode = ""
    verifikasi_pemeriksaans = VerifikasiPemeriksaan.where(:kode_verifikasi => kode_verifikasi)
    verifikasi_pemeriksaans.each do |verifikasi_pemeriksaan|
      if param_kode == ""
        param_kode = verifikasi_pemeriksaan.kode_pemeriksaan
      else
        param_kode = param_kode+"_"+verifikasi_pemeriksaan.kode_pemeriksaan
      end
    end

    param_jumlah_hari = ""
    verifikasi_pemeriksaans.each do |verifikasi_pemeriksaan|
      if param_jumlah_hari == ""
        param_jumlah_hari = verifikasi_pemeriksaan.jumlah.to_i rescue "0"
      else
        param_jumlah_hari = "#{param_jumlah_hari}_#{verifikasi_pemeriksaan.jumlah.to_i rescue 0}"
      end
    end

    param = {"kode_pemeriksaan" => param_kode, "jumlah_hari" => param_jumlah_hari}
    param.merge!(generate_param(verifikasi_pemeriksaans, "pemeriksaan"))
    return param
  end

  def self.param_tindakan_medis_to_vi(kode_verifikasi)
    verifikasi_tindakan_medis = VerifikasiTindakan.where(:kode_verifikasi => kode_verifikasi)
    param_kode = ""
    verifikasi_tindakan_medis.each do |verifikasi_tindakan_medi|
      if param_kode == ""
        param_kode = verifikasi_tindakan_medi.kode_t_medis
      else
        param_kode = param_kode+"_"+verifikasi_tindakan_medi.kode_t_medis
      end
    end
    param_nama = ""
    verifikasi_tindakan_medis.each do |verifikasi_tindakan_medi|
      if param_nama == ""
        if verifikasi_tindakan_medi.flag == 1
          param_nama = verifikasi_tindakan_medi.tindakan_medi.nama rescue ''
        else
          param_nama = verifikasi_tindakan_medi.tindakan_penunjang.nama rescue ''
        end
      else
        if verifikasi_tindakan_medi.flag == 1
          param_nama = param_nama+"_"+verifikasi_tindakan_medi.tindakan_penunjang.nama rescue ''
        else
          param_nama = param_nama+"_"+verifikasi_tindakan_medi.tindakan_penunjang.nama rescue ''
        end
      end
    end
    param_jumlah = ""
    verifikasi_tindakan_medis.each do |verifikasi_tindakan_medi|
      if param_jumlah == ""
        param_jumlah = verifikasi_tindakan_medi.jumlah_t_medis.to_s rescue "0"
      else
        param_jumlah = "#{param_jumlah rescue "0"}_#{verifikasi_tindakan_medi.jumlah_t_medis rescue "0"}"
      end
    end
    param_tgl = ""
    verifikasi_tindakan_medis.each do |verifikasi_tindakan_medi|
      if param_tgl == ""
        param_tgl = verifikasi_tindakan_medi.tgl_t_medis.to_s rescue "0"
      else
        param_tgl = param_tgl+"_"+verifikasi_tindakan_medi.tgl_t_medis
      end
    end
#    param = "kode_tm=#{param_kode}&nama_tm=#{param_nama}&jumlah_tm=#{param_jumlah}&tgl_tm=#{param_tgl}"
#    parameter = generate_param(verifikasi_tindakan_medis, "tm")
#    param = param+"&"+parameter

    param = {"kode_tm" => param_kode, "nama_tm" => param_nama,
             "jumlah_tm" => param_jumlah, "tgl_tm" => param_tgl}
    param.merge!(generate_param(verifikasi_tindakan_medis, "tm"))

    return param
  end

  def self.param_obat_to_vi(kode_verifikasi)

    verifikasi_obats = VerifikasiObat.where(:kode_verifikasi => kode_verifikasi)
    param_kode = ""
    verifikasi_obats.each do |verifikasi_obat|
      if param_kode == ""
        param_kode = verifikasi_obat.kode_obat
      else
        param_kode = param_kode+"_"+verifikasi_obat.kode_obat
      end
    end
    param_nama = ""
    verifikasi_obats.each do |verifikasi_obat|
      if param_nama == ""
        param_nama = verifikasi_obat.obat.nama rescue ''
      else
        param_nama = param_nama+"_"+verifikasi_obat.obat.nama rescue ''
      end
    end
    param_jumlah = ""
    verifikasi_obats.each do |verifikasi_obat|
      if param_jumlah == ""
        param_jumlah = verifikasi_obat.jumlah_obat
      else
        param_jumlah = "#{param_jumlah.to_s rescue "0"}_#{verifikasi_obat.jumlah_obat rescue "0"}"
      end
    end
    param_tgl = ""
    verifikasi_obats.each do |verifikasi_obat|
      if param_tgl == ""
        param_tgl = verifikasi_obat.tgl_obat
      else
        param_tgl = param_tgl+"_"+verifikasi_obat.tgl_obat
      end
    end
#    param = "kode_obat=#{param_kode}&nama_obat=#{param_nama}&jumlah_obat=#{param_jumlah}&tgl_obat=#{param_tgl}"
#    parameter = generate_param(verifikasi_obats, "obat")
#    param = param+"&"+parameter

    param = {"kode_obat" => param_kode, "nama_obat" => param_nama,
             "jumlah_obat" => param_jumlah, "tgl_obat" => param_tgl}
    param.merge!(generate_param(verifikasi_obats, "obat"))

    return param
  end

  def self.param_pelayanan_lain_to_vi(kode_verifikasi)

    verifikasi_pelayanan_lains = VerifikasiPelayananLain.where(:kode_verifikasi => kode_verifikasi)
    param_kode = ""
    verifikasi_pelayanan_lains.each do |verifikasi_pelayanan_lain|
      if param_kode == ""
        param_kode = verifikasi_pelayanan_lain.kode
      else
        param_kode = param_kode+"_"+verifikasi_pelayanan_lain.kode
      end
    end
    param_nama = ""
    verifikasi_pelayanan_lains.each do |verifikasi_pelayanan_lain|
      if param_nama == ""
        param_nama = verifikasi_pelayanan_lain.nama_pelayanan_lain rescue ''
      else
        param_nama = param_nama+"_"+verifikasi_pelayanan_lain.nama_pelayanan_lain rescue ''
      end
    end
    param_jumlah = ""
    verifikasi_pelayanan_lains.each do |verifikasi_pelayanan_lain|
      if param_jumlah == ""
        param_jumlah = verifikasi_pelayanan_lain.jumlah_pelayanan_lain
      else
        param_jumlah = "#{param_jumlah.to_s rescue "0"}_#{verifikasi_pelayanan_lain.jumlah_pelayanan_lain rescue "0"}"
      end
    end
    param_tgl = ""
    verifikasi_pelayanan_lains.each do |verifikasi_pelayanan_lain|
      if param_tgl == ""
        param_tgl = verifikasi_pelayanan_lain.tgl_pelayanan_lain
      else
        param_tgl = param_tgl+"_"+verifikasi_pelayanan_lain.tgl_pelayanan_lain
      end
    end
    harga_satuan = ""
    verifikasi_pelayanan_lains.each do |verifikasi_pelayanan_lain|
      if harga_satuan == ""
        harga_satuan = verifikasi_pelayanan_lain.harga_satuan
      else
        harga_satuan = "#{harga_satuan.to_s rescue "0"}_#{verifikasi_pelayanan_lain.harga_satuan rescue "0"}"
      end
    end

#   param = "kode_pl=#{param_kode}&nama_pl=#{param_nama}&jumlah_pl=#{param_jumlah}&tgl_pl=#{param_tgl}&harga_satuan_pl=#{harga_satuan}"
#   parameter = generate_param(verifikasi_pelayanan_lains, "pl")
#   param = param+"&"+parameter

    param = {"kode_pl" => param_kode, "nama_pl" => param_nama,
             "jumlah_pl" => param_jumlah, "tgl_pl" => param_tgl,
             "harga_satuan_pl" => harga_satuan}
    param.merge!(generate_param(verifikasi_pelayanan_lains, "pl"))

    return param
  end

  def self.generate_param(objects, param)
    param_no_transaksi = ""
    objects.each do |object|
      if param_no_transaksi == ""
        param_no_transaksi = object.kode rescue ''
      else
        param_no_transaksi = param_no_transaksi+"_"+(object.kode rescue '')
      end
    end

    #param = "no_transaksi_#{param}=#{param_no_transaksi}"
    param = {"no_transaksi_#{param}" => param_no_transaksi}
    return param
  end

end
