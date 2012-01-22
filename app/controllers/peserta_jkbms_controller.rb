class PesertaJkbmsController < ApplicationController
  # GET /peserta_jkbms
  # GET /peserta_jkbms.xml
  def index
   # @peserta_jkbms = PesertaJkbm.all
    @show_bt_upload = false
    @show_bt_add = false
    if params[:id] == "baru"
      status_param = "flag = 0"
    elsif params[:id] == "kirim"
      status_param = "flag = 1 && verifikasis.sent_to_vi = 0"
      @show_bt_upload = true
    elsif params[:id] == "terkirim"
      status_param = "flag = 2 || verifikasis.sent_to_vi = 1"
    elsif params[:id] == "perbaikan"
      status_param = "flag = 3"
    end

    param_page = params[:page] rescue 1
    per_page = PAGINATION

    @peserta_jkbms = PesertaJkbm.joins("LEFT JOIN verifikasis ON verifikasis.kode_peserta_jkbm = peserta_jkbms.kode ").where("#{status_param}").paginate :per_page => per_page, :page => param_page

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @peserta_jkbms }
    end
  end

  # GET /peserta_jkbms/1
  # GET /peserta_jkbms/1.xml
  def show
    @peserta_jkbm = PesertaJkbm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @peserta_jkbm }
    end
  end

  # GET /peserta_jkbms/new
  # GET /peserta_jkbms/new.xml
  def new
    @peserta_jkbm = PesertaJkbm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @peserta_jkbm }
    end
  end

  # GET /peserta_jkbms/1/edit
  def edit
    @id = params[:id]
    @peserta_jkbm = PesertaJkbm.find(params[:id])
     pagination(params[:id], "manage")
     
#    begin
      user_being_acces, status = check_user_concurrence(@peserta_jkbm)
      if status
        flash[:extra_notice] = EDIT_MSG
        set_nilai_verifikasi(@peserta_jkbm.kode)

        
        @show_bt_delete = false
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

  # POST /peserta_jkbms
  # POST /peserta_jkbms.xml
  def create
    @peserta_jkbm = PesertaJkbm.new(params[:peserta_jkbm])

    respond_to do |format|
      if @peserta_jkbm.save
        format.html { redirect_to(@peserta_jkbm, :notice => 'Peserta jkbm was successfully created.') }
        format.xml  { render :xml => @peserta_jkbm, :status => :created, :location => @peserta_jkbm }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @peserta_jkbm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /peserta_jkbms/1
  # PUT /peserta_jkbms/1.xml
  def update
    @peserta_jkbm = PesertaJkbm.find(params[:id])
    @peserta_jkbm.flag = 1 # Telah diedit, maka siap dikirim

    if params[:verifikasi][:kode].nil? || params[:verifikasi][:kode] == ''
      @verifikasi = Verifikasi.new(params[:verifikasi])
    else
      @verifikasi = Verifikasi.find_by_kode(params[:verifikasi][:kode])
    end
    @verifikasi.attributes = params[:verifikasi]

    respond_to do |format|
      if @verifikasi.save
        simpan_verifikasi_pemeriksaan
        simpan_verifikasi_obat
        simpan_verifikasi_tindakan
        simpan_verifikasi_tindakan_penunjang

      #  @verifikasi_tindakan.save
          
        @peserta_jkbm.save
        format.html { redirect_to(:action => "edit", :id => @peserta_jkbm, :notice => UPDATE_MSG) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @peserta_jkbm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /peserta_jkbms/1
  # DELETE /peserta_jkbms/1.xml
  def destroy
    @peserta_jkbm = PesertaJkbm.find(params[:id])
    @peserta_jkbm.destroy

    respond_to do |format|
      format.html { redirect_to(peserta_jkbms_url) }
      format.xml  { head :ok }
    end
  end


  def ambil_data_kepersetaan_jkbm
    Verifikasi.ambil_data_kepersetaan_ejkbm

    respond_to do |format|
      format.html { redirect_to(:action => "index", :id => "kirim", :notice => 'Sukses mengambil data dari EJKBM') }
    end
  end

  def sent_to_vi
    # flag = 1 => data siap dikirim
    peserta_jkbms = PesertaJkbm.where(:flag => 1)
    peserta_jkbms.each do |peserta_jkbm|
      puts "-- #{peserta_jkbm.kode} --"
      Verifikasi.send_to_vi
    end

    respond_to do |format|
      format.html { redirect_to(:action => "index", :id => "kirim", :notice => 'Data telah berhasil terkirim') }
    end

  end

  def sent_to_rs
    gagal_terkirim = Array.new

    check_boxs = params[:check_box]
    check_boxs.each do |kode_verifikasi|
      peserta_jkbm = PesertaJkbm.find_by_kode()
      verifikasi = Verifikasi.find_by_kode(kode_verifikasi)
      if verifikasi.sent_to_rs == false
        Verifikasi.send_to_rs(verifikasi)
      end
    end

    respond_to do |format|
      if gagal_terkirim.empty?
        notice = "Data telah dikirim"
      else
        notice = "Terjadi kesalahan pada pengiriman data"
      end
      format.html { redirect_to(:action => :index, :id => "kirim", :notice => notice) }
      format.xml  { }
     end
  end

end
