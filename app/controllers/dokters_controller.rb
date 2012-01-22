class DoktersController < ApplicationController
  # GET /dokters
  # GET /dokters.xml
  def index
    @dokters = Dokter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dokters }
    end
  end

  # GET /dokters/1
  # GET /dokters/1.xml
  def show
    @dokter = Dokter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dokter }
    end
  end

  # GET /dokters/new
  # GET /dokters/new.xml
  def new
    @dokter = Dokter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dokter }
    end
  end

  # GET /dokters/1/edit
  def edit
    @dokter = Dokter.find(params[:id])
  end

  # POST /dokters
  # POST /dokters.xml
  def create
    @dokter = Dokter.new(params[:dokter])

    respond_to do |format|
      if @dokter.save
        format.html { redirect_to(:action => "index", :notice => CREATE_MSG) }
        format.xml  { render :xml => @dokter, :status => :created, :location => @dokter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dokter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dokters/1
  # PUT /dokters/1.xml
  def update
    @dokter = Dokter.find(params[:id])

    respond_to do |format|
      if @dokter.update_attributes(params[:dokter])
        format.html { redirect_to(:action => "index", :notice => UPDATE_MSG) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dokter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dokters/1
  # DELETE /dokters/1.xml
  def destroy
    @dokter = Dokter.find(params[:id])
    @dokter.destroy

    respond_to do |format|
      if @dokter.destroy
          format.html { redirect_to(:action => 'index', :id => "new", :notice => DELETE_MSG) }
        else
          format.html { redirect_to(:action => "edit", :id => @id, :error => DELETE_CASCADE_ERROR_MSG) }
        end
    end
  end
end
