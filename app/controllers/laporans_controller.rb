class LaporansController < ApplicationController
  # GET /laporans
  # GET /laporans.xml
  def index
    @laporans = Laporan.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laporans }
    end
  end

  # GET /laporans/1
  # GET /laporans/1.xml
  def show
    @laporan = Laporan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @laporan }
    end
  end

  # GET /laporans/new
  # GET /laporans/new.xml
  def new
    @laporan = Laporan.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @laporan }
    end
  end

  # GET /laporans/1/edit
  def edit
    @laporan = Laporan.find(params[:id])
  end

  # POST /laporans
  # POST /laporans.xml
  def create
    @laporan = Laporan.new(params[:laporan])

    respond_to do |format|
      if @laporan.save
        format.html { redirect_to(@laporan, :notice => 'Laporan was successfully created.') }
        format.xml  { render :xml => @laporan, :status => :created, :location => @laporan }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @laporan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /laporans/1
  # PUT /laporans/1.xml
  def update
    @laporan = Laporan.find(params[:id])

    respond_to do |format|
      if @laporan.update_attributes(params[:laporan])
        format.html { redirect_to(@laporan, :notice => 'Laporan was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @laporan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /laporans/1
  # DELETE /laporans/1.xml

  def destroy
    @laporan = Laporan.find(params[:id])
    @laporan.destroy

    respond_to do |format|
      format.html { redirect_to(laporans_url) }
      format.xml  { head :ok }
    end
  end

  def laporan
    
    #@show_bt_back = true
    @show_bt_ok = true


    param_page = params[:page] rescue 1
    per_page = PAGINATION


    if request.post?
      # --- Adjust this ---
      @show_bt_print = true
      @link_to_print = "/#{self.controller_name}/print/new"
      rentang_awal = params[:laporan][:tanggal_awal].to_date.strftime("%Y/%m/%d").to_s rescue ""
      rentang_akhir = params[:laporan][:tanggal_akhir].to_date.strftime("%Y/%m/%d").to_s rescue ""

      @tanggal_awal = params[:laporan][:tanggal_awal]
      @tanggal_akhir = params[:laporan][:tanggal_akhir]
      @jenis_laporan = params[:laporan][:jenis_laporan]

      jenis = params[:laporan][:jenis_laporan]

      if jenis == 'laporan1'
       @nama_laporan = 'Rekapitulasi Klaim Biaya Total Pelayanan'
       @laporans = JenisPelayanan.find_by_sql("select jenis_pelayanans.nama AS 'Pelayanan',
          count(verifikasis.kode) AS 'Jumlah Pasien',SUM(verifikasis.lama_dirawat) AS 'Lama Rawat',
          SUM(verifikasis.total_tarif) AS 'Total Tarif' FROM jenis_pelayanans
          INNER JOIN(verifikasis) ON (jenis_pelayanans.kode = verifikasis.no_pelayanan)
          where (verifikasis.created_at BETWEEN DATE('#{rentang_awal}') AND DATE('#{rentang_akhir}'))
          GROUP BY jenis_pelayanans.nama ORDER BY jenis_pelayanans.kode")
      elsif jenis == 'laporan2'
        @nama_laporan = 'RekapitulasiR Klaim Biaya RITL'
          @laporans = Verifikasi.find_by_sql("select verifikasis.nama_pasien AS 'Nama', verifikasis.tgl_keluar AS 'Tanggal Keluar',
          verifikasis.lama_dirawat AS 'Lama Hari Rawat', SUM(verifikasi_pemeriksaans.tarif_pemeriksaan) AS 'Biaya',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Penunjang Diagnostik', SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Tindakan Medis',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Kantong Darah',SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Haemodialisa',
          SUM(verifikasi_obats.sub_total_tarif_ejkbm) AS 'Yan Obat',('Biaya'+'Penunjang Diagnostik'+'Tindakan Medis'+'Kantong Darah'+'Haemodialisa'+'Yan Obat') AS 'Total',
          alasan_verifikasis.alasan as 'Keterangan' from verifikasis INNER JOIN (verifikasi_tindakans, verifikasi_obats, verifikasi_pemeriksaans, alasan_verifikasis)
          ON (verifikasis.kode = verifikasi_obats.kode_verifikasi AND verifikasis.kode = verifikasi_tindakans.kode_verifikasi
          AND verifikasis.kode = verifikasi_pemeriksaans.kode_verifikasi AND verifikasis.kode_alasan_verifikasi = alasan_verifikasis.kode)
          where 'Penunjang Diagnostik' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Tindakan Medis' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Kantong Darah'IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIQNY2')
          AND 'Haemodialisa' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIPXOK')
          AND (verifikasis.created_at BETWEEN DATE('#{rentang_awal}') AND DATE('#{rentang_akhir}'))
          GROUP by verifikasis.kode")
      elsif jenis == 'laporan3'
        @nama_laporan = 'Rekapitulasi Klaim Biaya One Day Care'
          @laporans = Verifikasi.find_by_sql("select verifikasis.created_at AS 'Tanggal', COUNT(verifikasis.kode) AS 'Jumlah Pasien',SUM(verifikasi_pemeriksaans.tarif_pemeriksaan) AS 'Pemeriksaan',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Penunjang Diagnostik',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Tindakan Medis', SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Kantong Darah',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Haemodialisa', SUM(verifikasi_obats.sub_total_tarif_ejkbm) AS 'Yan Obat',
          ('Pemeriksaan'+'Penunjang Diagnostik'+'Tindakan Medis'+'Kantong Darah'+'Haemodialisa'+'Yan Obat') AS 'Total' from verifikasis
          INNER JOIN (jenis_pelayanans,verifikasi_tindakans, verifikasi_obats, verifikasi_pemeriksaans)
          ON (verifikasis.no_pelayanan = jenis_pelayanans.kode AND verifikasis.kode = verifikasi_obats.kode_verifikasi
          AND verifikasis.kode = verifikasi_tindakans.kode_verifikasi AND verifikasis.kode = verifikasi_pemeriksaans.kode_verifikasi)
          where 'Penunjang Diagnostik' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Tindakan Medis' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Kantong Darah'IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIQNY2')
          AND 'Haemodialisa' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIPXOK')
          AND (verifikasis.created_at BETWEEN DATE('#{rentang_awal}') AND DATE('#{rentang_akhir}')) AND jenis_pelayanans.kode = '2'
          GROUP by 'Tanggal'")
      elsif jenis == 'laporan4'
        @nama_laporan = 'Rekapitulasi Klaim Biaya RJTL'
          @laporans = Verifikasi.find_by_sql("select verifikasis.created_at AS 'Tanggal', COUNT(verifikasis.kode) AS 'Jumlah Pasien',SUM(verifikasi_pemeriksaans.tarif_pemeriksaan) AS 'Pemeriksaan',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Penunjang Diagnostik',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Tindakan Medis', SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Kantong Darah',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Haemodialisa', SUM(verifikasi_obats.sub_total_tarif_ejkbm) AS 'Yan Obat',
          ('Pemeriksaan'+'Penunjang Diagnostik'+'Tindakan Medis'+'Kantong Darah'+'Haemodialisa'+'Yan Obat') AS 'Total' from verifikasis
          INNER JOIN (jenis_pelayanans,verifikasi_tindakans, verifikasi_obats, verifikasi_pemeriksaans)
          ON (verifikasis.no_pelayanan = jenis_pelayanans.kode AND verifikasis.kode = verifikasi_obats.kode_verifikasi
          AND verifikasis.kode = verifikasi_tindakans.kode_verifikasi AND verifikasis.kode = verifikasi_pemeriksaans.kode_verifikasi)
          where 'Penunjang Diagnostik' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Tindakan Medis' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Kantong Darah'IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIQNY2')
          AND 'Haemodialisa' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIPXOK')
          AND (verifikasis.created_at BETWEEN DATE('#{rentang_awal}') AND DATE('#{rentang_akhir}')) AND jenis_pelayanans.kode = '4'
          GROUP by 'Tanggal'")
      elsif jenis == 'laporan5'
        @nama_laporan = 'Rekapitulasi Klaim Biaya IGD'
          @laporans = Verifikasi.find_by_sql("select verifikasis.created_at AS 'Tanggal', COUNT(verifikasis.kode) AS 'Jumlah Pasien',SUM(verifikasi_pemeriksaans.tarif_pemeriksaan) AS 'Pemeriksaan',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Penunjang Diagnostik',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Tindakan Medis', SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Kantong Darah',
          SUM(verifikasi_tindakans.sub_total_tarif_ejkbm) AS 'Haemodialisa', SUM(verifikasi_obats.sub_total_tarif_ejkbm) AS 'Yan Obat',
          ('Pemeriksaan'+'Penunjang Diagnostik'+'Tindakan Medis'+'Kantong Darah'+'Haemodialisa'+'Yan Obat') AS 'Total' from verifikasis
          INNER JOIN (jenis_pelayanans,verifikasi_tindakans, verifikasi_obats, verifikasi_pemeriksaans)
          ON (verifikasis.no_pelayanan = jenis_pelayanans.kode AND verifikasis.kode = verifikasi_obats.kode_verifikasi
          AND verifikasis.kode = verifikasi_tindakans.kode_verifikasi AND verifikasis.kode = verifikasi_pemeriksaans.kode_verifikasi)
          where 'Penunjang Diagnostik' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Tindakan Medis' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.flag = '1')
          AND 'Kantong Darah'IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIQNY2')
          AND 'Haemodialisa' IN (select verifikasi_tindakans.sub_total_tarif_ejkbm from verifikasi_tindakans where verifikasi_tindakans.kode = 'VIPXOK')
          AND (verifikasis.created_at BETWEEN DATE('#{rentang_awal}') AND DATE('#{rentang_akhir}')) AND jenis_pelayanans.kode = '1'
          GROUP by 'Tanggal'")
      else
      end
      # --- Adjust this ---
      
       else
          @laporans = Verifikasi.all.paginate :per_page => per_page, :page => param_page
    end
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @laporans }
      format.js
    end
  end

  def print
    @is_show = true
    respond_to do |format|
      @form_header = "Laporan"
      #@page_header = "#{@@global_path_information} > #{@form_header}"

      format.html { render :layout => "laporan" }
      format.xml  { render :xml => @laporan }
    end
  end
end
