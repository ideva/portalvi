class VerifikasisController < ApplicationController
  before_filter :login_required, :except => [:ws_vi_rs]
  protect_from_forgery :except => [:ws_vi_rs]
  
  # GET /verifikasis
  # GET /verifikasis.xml
  def index
    @show_bt_upload = false
    @show_bt_add = false
    if params[:id] == "new"
      status_param = "status_pengiriman = 0"
    elsif params[:id] == "kirim"
      status_param = "status_pengiriman = 1"
      @show_bt_upload = true
    elsif params[:id] == "perbaikan"
       status_param = "status_pengiriman = 3"
    elsif params[:id] == "valid"
      status_param = "status_verifikasi = 1"
    elsif params[:id] == "invalid"
      status_param = "status_verifikasi = 0"
    end
    
    param_page = params[:page] rescue 1
    per_page = PAGINATION
    
    param = params[:param].to_s rescue ''
    tipe = params[:tipe]

    if params[:tipe]
      if tipe == "kode"
        field = "kode LIKE ?"
      elsif tipe == "no_pelayanan"
      elsif tipe == "tgl_keluar"
        field = "tgl_keluar LIKE ?"
        param.to_date.strftime("%Y-%m-%d")
      else
      end
      @verifikasis = Verifikasi.where("#{field} AND #{status_param}", "%"+param+"%").paginate :per_page => per_page, :page => param_page
    else
      @verifikasis = Verifikasi.where("#{status_param}").paginate :per_page => per_page, :page => param_page
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @verifikasis }
      format.js {}
    end
  end

  def set_url_back
#    if @verifikasi.status_verifikasi_verifikator == 0
#      url = "/#{self.controller_name}/index/new"
#    elsif @verifikasi.status_verifikasi_verifikator == 1 || @verifikasi.status_verifikasi_verifikator == 2
#      url = "/#{self.controller_name}/index/kirim"
#    elsif @verifikasi.status_verifikasi_verifikator == 3
#      url = "/#{self.controller_name}/index/pending"
#    end

    if @verifikasi.status_pengiriman == 0
      url = "/#{self.controller_name}/index/new"
    elsif @verifikasi.status_pengiriman == 1
      url = "/#{self.controller_name}/index/kirim"
    elsif @verifikasi.status_pengiriman == 3
      url = "/#{self.controller_name}/index/pending"
    end
    return url
  end

  # GET /verifikasis/1
  # GET /verifikasis/1.xml
  def show
    @verifikasi = Verifikasi.find(params[:id])
    @verifikasi_tindakan_medis = VerifikasiTindakan.where(:kode_verifikasi => @verifikasi.kode, :flag => 1)
    @verifikasi_tindakan_penunjangs = VerifikasiTindakan.where(:kode_verifikasi => @verifikasi.kode, :flag => 2)
    @verifikasi_pemeriksaans = VerifikasiPemeriksaan.where(:kode_verifikasi => @verifikasi.kode, :flag => 1)
    @verifikasi_obats = VerifikasiObat.where(:kode_verifikasi => @verifikasi.kode, :flag => 1)

    @verifikasi_pemeriksaans_non_mapping = VerifikasiPemeriksaan.where(:kode_verifikasi => @verifikasi.kode, :flag => 2)
    @verifikasi_tindakan_medis_non_mapping = VerifikasiTindakan.where(:kode_verifikasi => @verifikasi.kode, :flag => 3)
    @verifikasi_obats_non_mapping = VerifikasiObat.where(:kode_verifikasi => @verifikasi.kode, :flag => 2)

    session[:url_back] = set_url_back
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @verifikasi }
    end
  end

  # GET /verifikasis/new
  # GET /verifikasis/new.xml
  def new
    @verifikasi = Verifikasi.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @verifikasi }
    end
  end

  # GET /verifikasis/1/edit
  def edit
    @id = params[:id]
    @verifikasi = Verifikasi.find(params[:id])

    session[:url_back] = set_url_back
    #pagination(params[:id], "manage")

#    begin
      user_being_acces, status = check_user_concurrence(@verifikasi)
      if status
        flash[:extra_notice] = EDIT_MSG
        set_nilai_verifikasi
        
      else
        # user_concurrence_blocked(user_being_acces, is_redirect)
        # true => redirect, false => render
        user_concurrence_blocked(user_being_acces, false)
      end
#    rescue
#      respond_to do |format|
#        error = "Data sedang digunakan, cobalah beberapa saat lagi"
#        format.html {redirect_to "/main/resctricted?error=#{CGI::escape(error)}" }
#      end
#    end
    
   
  end

  # POST /verifikasis
  # POST /verifikasis.xml
  def create
    @verifikasi = Verifikasi.new(params[:verifikasi])

    respond_to do |format|
      if @verifikasi.save
        format.html { redirect_to(@verifikasi, :notice => 'Verifikasi was successfully created.') }
        format.xml  { render :xml => @verifikasi, :status => :created, :location => @verifikasi }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @verifikasi.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /verifikasis/1
  # PUT /verifikasis/1.xml
  def update
    @verifikasi = Verifikasi.find(params[:id])
     user_being_acces, status = check_user_concurrence(@verifikasi)
    unless status
      user_concurrence_blocked(user_being_acces, false)
      return
    end
    
    if params[:verifikasi][:kode].nil? || params[:verifikasi][:kode] == ''
      @verifikasi = Verifikasi.new(params[:verifikasi])
    else
      @verifikasi = Verifikasi.find_by_kode(params[:verifikasi][:kode])
    end
    @verifikasi.attributes = params[:verifikasi]

    @verifikasi.status_pengiriman = 1 # Telah diedit, maka siap dikirim
    respond_to do |format|
      if @verifikasi.save
        simpan_verifikasi_pemeriksaan
        simpan_verifikasi_obat
        simpan_verifikasi_tindakan
        simpan_verifikasi_tindakan_penunjang
        simpan_verifikasi_pelayanan_lain

        format.html { redirect_to(:action => "edit", :id => params[:id], :notice => UPDATE_MSG) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @verifikasi.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /verifikasis/1
  # DELETE /verifikasis/1.xml
  def destroy
    @verifikasi = Verifikasi.find(params[:id])
    @verifikasi.destroy

    respond_to do |format|
      format.html { redirect_to(verifikasis_url) }
      format.xml  { head :ok }
    end
  end

  def add_new_list_pemeriksaan
    counter = params[:counter_pemeriksaan]
    @counter_pemeriksaan = counter.to_i + 1

    respond_to do |format|
      format.js { }
      format.text { render :partial => "verifikasis/table_form_pemeriksaan", :locals => {:no => @counter_pemeriksaan} }
    end
  end

  def add_new_list_obat
    counter = params[:counter_obat]
    @counter_obat = counter.to_i + 1

    respond_to do |format|
      format.js { }
      format.text { render :partial => "table_form_obat", :locals => {:no => @counter_obat} }
    end
  end

  def add_new_list_tindakan
    counter = params[:counter_tindakan]
    @counter_tindakan = counter.to_i + 1

    respond_to do |format|
      format.js { }
      format.text { render :partial => "table_form_tindakan", :locals => {:no => @counter_tindakan} }
    end
  end

  def add_new_list_pelayanan_lain
    counter = params[:counter_pelayanan_lain]
    @counter_pelayanan_lain = counter.to_i + 1

    respond_to do |format|
      format.js { }
      format.text { render :partial => "table_form_pelayanan_lain", :locals => {:no => @counter_pelayanan_lain} }
    end
  end

  def add_new_list_tindakan_penunjang
    counter = params[:counter_tindakan_penunjang]
    @counter_tindakan_penunjang = counter.to_i + 1

    respond_to do |format|
      format.js { }
      format.text { render :partial => "table_form_tindakan_penunjang", :locals => {:no => @counter_tindakan_penunjang} }
    end
  end

  def ambil_data_kepersetaan_jkbm
    
    respond_to do |format|
      if Verifikasi.ambil_data_kepersetaan_ejkbm
        format.html { redirect_to(:action => "index", :id => "kirim", :notice => 'Sukses mengambil data dari EJKBM') }
      else
        format.html { redirect_to(:action => "index", :id => "kirim", :alert => 'Gagal mengambil data dari EJKBM') }
      end
      
    end
  end

  # WS ini akan diakses oleh SIM VI untuk mengirimkan hasil verifikasi
  # Hasil verifikasi yang akan diterima adalah: Layak, Tidak Layak dan Perbaikan
  def ws_vi_rs
    puts "----------------------------------------"
    no_klaim = params[:no_klaim]
    no_reg = params[:no_reg]
    status_verifikasi_global = params[:status_verifikasi_global]
    komentar_verifikasi_global = params[:komentar_verifikasi_global]
    total_tarif = params[:total_tarif]  

    verifikasi = Verifikasi.find_by_kode(no_reg)
    if verifikasi.nil?
      @status = "data tidak ditemukan" # 2
    else
    end
#    begin
#    Verifikasi.transaction do
      no_transaksi = params[:no_transaksi_pemeriksaan].split("_") rescue Array.new
      tarif = params[:tarif_pemeriksaan].split("_") rescue Array.new
      status_verifikasis = params[:status_verifikasi_pemeriksaan].split("_") rescue Array.new
      kode_alasan = params[:kode_alasan_pemeriksaan].split("_") rescue Array.new
      komentar = params[:komentar_pemeriksaan].split("_") rescue Array.new
      i = 0
      no_transaksi.each do |temp|
        object = VerifikasiPemeriksaan.find_by_kode(temp)
        object.harga_satuan = tarif[i].to_f rescue '0'
        if status_verifikasis[i] == "1"
          status_verifikasi = "1" # layak
        else
          status_verifikasi = "2" # tidak layak
        end
        object.status_verifikasi_verifikator = status_verifikasi
        object.kode_alasan_verifikasi = kode_alasan[i]
        object.komentar = komentar[i]
        object.save
        i=i+1
      end

      no_transaksi = params[:no_transaksi_tm].split("_") rescue Array.new
      tarif = params[:tarif_tm].split("_") rescue Array.new
      status_verifikasis = params[:status_verifikasi_tm].split("_") rescue Array.new
      kode_alasan = params[:kode_alasan_tm].split("_") rescue Array.new
      komentar = params[:komentar_tm].split("_") rescue Array.new
      i = 0
      no_transaksi.each do |temp|
        object = VerifikasiTindakan.find_by_kode(temp)
        object.harga_satuan = tarif[i]
        if status_verifikasis[i] == "1"
          status_verifikasi = "1" # layak
        else
          status_verifikasi = "2" # tidak layak
        end
        object.status_verifikasi_verifikator = status_verifikasi
        object.kode_alasan_verifikasi = kode_alasan[i]
        object.komentar = komentar[i]
        puts "==Status=#{status_verifikasi}==kode=#{temp}===Alasan=#{object.kode_alasan_verifikasi}==Komentar=#{object.komentar}==="
        object.save
        i=i+1
      end

      no_transaksi = params[:no_transaksi_obat].split("_") rescue Array.new
      tarif = params[:tarif_obat].split("_") rescue Array.new
      status_verifikasis = params[:status_verifikasi_obat].split("_") rescue Array.new
      kode_alasan = params[:kode_alasan_obat].split("_") rescue Array.new
      komentar = params[:komentar_obat].split("_") rescue Array.new
      i = 0
      no_transaksi.each do |temp|
        object = VerifikasiObat.find_by_kode(temp)
        object.harga_satuan = tarif[i]
        if status_verifikasis[i] == "1"
          status_verifikasi = "1" # layak
        else
          status_verifikasi = "2" # tidak layak
        end
        object.status_verifikasi_verifikator = status_verifikasi
        object.kode_alasan_verifikasi = kode_alasan[i]
        object.komentar = komentar[i]
        object.save
        i=i+1
      end

      no_transaksi = params[:no_transaksi_pl].split("_") rescue Array.new
      status_verifikasis = params[:status_verifikasi_pl].split("_") rescue Array.new
      kode_alasan = params[:kode_alasan_pl].split("_") rescue Array.new
      komentar = params[:komentar_pl].split("_") rescue Array.new
      i = 0
      no_transaksi.each do |temp|
        object = VerifikasiPelayananLain.find_by_kode(temp)
        object.harga_satuan = tarif[i]
        if status_verifikasis[i] == "1"
          status_verifikasi = "1" # layak
        else
          status_verifikasi = "2" # tidak layak
        end
        object.status_verifikasi_verifikator = status_verifikasi
        object.kode_alasan_verifikasi = kode_alasan[i]
        object.komentar = komentar[i]
        object.save
        i=i+1
      end

      if status_verifikasi_global.to_s == "1"
        verifikasi.status_verifikasi = 1
      elsif status_verifikasi_global.to_s == "2" # Perbaikan
        verifikasi.status_verifikasi = 2
        verifikasi.komentar = komentar_verifikasi_global
        verifikasi.status_pengiriman = 3 # Data perbaikan
        verifikasi.sent_to_vi = false
      else # 0 = Tidak layak
        verifikasi.status_verifikasi = 0
        verifikasi.status_pengiriman = 3
        verifikasi.komentar = komentar_verifikasi_global
        verifikasi.sent_to_vi = false
      end
      verifikasi.total_tarif = total_tarif
      verifikasi.save
      @status = "1"
#    end
#    rescue Exception => e
#      @status = e.to_s
#    end

    verifikasi_log = VerifikasiRequestLog.new
    verifikasi_log.request_in = "\n--URL-------\n"+request.url.to_s+"\n--Parameter-------\n"+request.parameters.to_s+"\n--Result-------\n"+@status
    verifikasi_log.save
    respond_to do |format|
        format.html {  }
        format.xml  { }
      end
  end

  def set_nilai_verifikasi()
    if @verifikasi.nil?
      @verifikasi = Verifikasi.new
      @verifikasi.kode_peserta_jkbm = kode_peserta_jkbm
      @verifikasi.no_pelayanan = @peserta_jkbm.no_pelayanan
      @verifikasi.nama_pasien = @peserta_jkbm.nama_pasien
      @verifikasi.no_kk = @peserta_jkbm.no_kk
      @verifikasi.nik = @peserta_jkbm.nik
      @verifikasi.ktp = @peserta_jkbm.ktp
      @verifikasi.no_ejkbm = @peserta_jkbm.no_ejkbm
      @verifikasi.alamat = @peserta_jkbm.alamat
      @verifikasi.kode_kabupaten = @peserta_jkbm.kode_kabupaten
      @verifikasi.tgl_masuk = @peserta_jkbm.tgl_masuk.to_s.to_date
      @verifikasi.lama_dirawat = nil
    else
    end
  end

  def simpan_verifikasi_pemeriksaan
    counter = params[:counter_pemeriksaan]
    for i in 1..counter.to_i do
      if params["verifikasi_pemeriksaan#{i}"]
        if params["verifikasi_pemeriksaan#{i}"][:kode].nil? || params["verifikasi_pemeriksaan#{i}"][:kode] == ""
          verifikasi_pemeriksaan = VerifikasiPemeriksaan.new(params["verifikasi_pemeriksaan#{i}"])
          verifikasi_pemeriksaan.kode_verifikasi = @verifikasi.kode
        else
          verifikasi_pemeriksaan = VerifikasiPemeriksaan.find_by_kode(params["verifikasi_pemeriksaan#{i}"][:kode])
        end
        verifikasi_pemeriksaan.attributes = params["verifikasi_pemeriksaan#{i}"]
        unless verifikasi_pemeriksaan.kode_pemeriksaan.nil? || verifikasi_pemeriksaan.kode_pemeriksaan == ""
          verifikasi_pemeriksaan.save
        end
      end
    end
  end

  def simpan_verifikasi_obat
    counter = params[:counter_obat]
    for i in 1..counter.to_i do
      if params["verifikasi_obat#{i}"]
        if params["verifikasi_obat#{i}"][:kode].nil? || params["verifikasi_obat#{i}"][:kode] == ""
          verifikasi_obat = VerifikasiObat.new
          verifikasi_obat.kode_verifikasi = @verifikasi.kode
        else
          verifikasi_obat = VerifikasiObat.find_by_kode(params["verifikasi_obat#{i}"][:kode])
        end
        verifikasi_obat.attributes = params["verifikasi_obat#{i}"]
        unless verifikasi_obat.kode_obat.nil? || verifikasi_obat.kode_obat == ""
          verifikasi_obat.save
        end

      end
    end
  end

  def simpan_verifikasi_tindakan
    counter = params[:counter_tindakan]
    for i in 1..counter.to_i do
      if params["verifikasi_tindakan#{i}"]
        if params["verifikasi_tindakan#{i}"][:kode].nil? || params["verifikasi_tindakan#{i}"][:kode] == ""
          verifikasi_tindakan = VerifikasiTindakan.new(params["verifikasi_tindakan#{i}"])
          verifikasi_tindakan.kode_verifikasi = @verifikasi.kode
        else
          verifikasi_tindakan = VerifikasiTindakan.find_by_kode(params["verifikasi_tindakan#{i}"][:kode])
        end
        verifikasi_tindakan.attributes = params["verifikasi_tindakan#{i}"]
        unless verifikasi_tindakan.kode_t_medis.nil? || verifikasi_tindakan.kode_t_medis == ""
          verifikasi_tindakan.flag = 1
          verifikasi_tindakan.save
        end
      end
    end
  end

  def simpan_verifikasi_tindakan_penunjang
    counter = params[:counter_tindakan_penunjang]
    for i in 1..counter.to_i do
      if params["verifikasi_tindakan_penunjang#{i}"]
        if params["verifikasi_tindakan_penunjang#{i}"][:kode].nil? || params["verifikasi_tindakan_penunjang#{i}"][:kode] == ""
          verifikasi_tindakan = VerifikasiTindakan.new(params["verifikasi_tindakan_penunjang#{i}"])
          verifikasi_tindakan.kode_verifikasi = @verifikasi.kode
        else
          verifikasi_tindakan = VerifikasiTindakan.find_by_kode(params["verifikasi_tindakan_penunjang#{i}"][:kode])
        end
        verifikasi_tindakan.attributes = params["verifikasi_tindakan_penunjang#{i}"]
        unless verifikasi_tindakan.kode_t_medis.nil? || verifikasi_tindakan.kode_t_medis == ""
          verifikasi_tindakan.flag = 2
          verifikasi_tindakan.save
        end
      end
    end
  end

  def simpan_verifikasi_pelayanan_lain
    counter = params[:counter_pelayanan_lain]
    for i in 1..counter.to_i do
      if params["verifikasi_pelayanan_lain#{i}"]
        if params["verifikasi_pelayanan_lain#{i}"][:kode].nil? || params["verifikasi_pelayanan_lain#{i}"][:kode] == ""
          verifikasi_pelayanan_lain = VerifikasiPelayananLain.new(params["verifikasi_pelayanan_lain#{i}"])
          verifikasi_pelayanan_lain.kode_verifikasi = @verifikasi.kode
        else
          verifikasi_pelayanan_lain = VerifikasiPelayananLain.find_by_kode(params["verifikasi_pelayanan_lain#{i}"][:kode])
        end
        verifikasi_pelayanan_lain.attributes = params["verifikasi_pelayanan_lain#{i}"]
        verifikasi_pelayanan_lain.save
      end
    end
  end

  def sent_to_vi
    gagal_terkirim = Array.new
    no_data = false

    if params[:check_box]
      check_boxs = params[:check_box]
      check_boxs.each do |kode_verifikasi|
        verifikasi = Verifikasi.find_by_kode(kode_verifikasi)
        #if verifikasi.sent_to_vi == false
          if Verifikasi.sent_to_vi(verifikasi)
          else
            gagal_terkirim << "No Klaim "+verifikasi.kode+" gagal terkirim ke VI"
          end
        #end
      end
    else
      no_data = true
    end

    respond_to do |format|
      if gagal_terkirim.empty?
        if no_data
          notice = "Tidak ada data yang dikirim"
        else
          notice = "Data telah dikirim"
        end
        format.html { redirect_to(:action => :index, :id => "kirim", :notice => notice) }
      else
        alert = ''
        gagal_terkirim.each do |pesan|
          if alert == ''
            alert = pesan
          else
            alert = alert+"<br/>"+pesan
          end
        end
        format.html { redirect_to(:action => :index, :id => "kirim", :alert => alert) }
      end 
      format.xml  { }
     end
  end
end
