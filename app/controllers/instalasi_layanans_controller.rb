class InstalasiLayanansController < ApplicationController
  # GET /instalasi_layanans
  # GET /instalasi_layanans.xml
  def index
    @instalasi_layanans = InstalasiLayanan.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @instalasi_layanans }
    end
  end

  # GET /instalasi_layanans/1
  # GET /instalasi_layanans/1.xml
  def show
    @instalasi_layanan = InstalasiLayanan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @instalasi_layanan }
    end
  end

  # GET /instalasi_layanans/new
  # GET /instalasi_layanans/new.xml
  def new
    @instalasi_layanan = InstalasiLayanan.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @instalasi_layanan }
    end
  end

  # GET /instalasi_layanans/1/edit
  def edit
    @instalasi_layanan = InstalasiLayanan.find(params[:id])
  end

  # POST /instalasi_layanans
  # POST /instalasi_layanans.xml
  def create
    @instalasi_layanan = InstalasiLayanan.new(params[:instalasi_layanan])

    respond_to do |format|
      if @instalasi_layanan.save
        format.html { redirect_to(:action => "index", :notice => CREATE_MSG) }
        format.xml  { render :xml => @instalasi_layanan, :status => :created, :location => @instalasi_layanan }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @instalasi_layanan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /instalasi_layanans/1
  # PUT /instalasi_layanans/1.xml
  def update
    @instalasi_layanan = InstalasiLayanan.find(params[:id])

    respond_to do |format|
      if @instalasi_layanan.update_attributes(params[:instalasi_layanan])
        format.html { redirect_to(:action => "index", :notice => UPDATE_MSG) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @instalasi_layanan.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /instalasi_layanans/1
  # DELETE /instalasi_layanans/1.xml
  def destroy
    @instalasi_layanan = InstalasiLayanan.find(params[:id])
    @instalasi_layanan.destroy

    respond_to do |format|
      if @instalasi_layanan.destroy
          format.html { redirect_to(:action => 'index', :id => "new", :notice => DELETE_MSG) }
        else
          format.html { redirect_to(:action => "edit", :id => @id, :error => DELETE_CASCADE_ERROR_MSG) }
        end
    end
    end
  end