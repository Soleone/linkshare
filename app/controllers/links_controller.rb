class LinksController < ApplicationController
  # GET /links
  # GET /links.xml
  def index
    @links = Link.find(:all)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @links }
    end
  end
  
  # GET /links/1
  # GET /links/1.xml
  def show
    @link = Link.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @link }
    end
  end
  
  # GET /links/new
  # GET /links/new.xml
  def new
    @link = Link.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @link }
    end
  end
  
  # GET /links/1/edit
  def edit
    @link = Link.find(params[:id])
  end
  
  # POST /links
  # POST /links.xml
  def create
    @link = Link.new(params[:link])
    
    respond_to do |format|
      if @link.save
        flash[:notice] = 'Link was successfully created.'
        format.html { redirect_to(@link) }
        format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /links/1
  # PUT /links/1.xml
  def update
    @link = Link.find(params[:id])
    
    respond_to do |format|
      if @link.update_attributes(params[:link])
        flash[:notice] = 'Link was successfully updated.'
        format.html { redirect_to(@link) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /links/1
  # DELETE /links/1.xml
  def destroy
  	@link = Link.find(params[:id])
    Link.transaction do
     	@link.ratings.each do |rating|
         rating.destroy
      end
      if @link.destroy
      	flash[:notice] = "\"#{@link.title}\" was successfully deleted!"
      else
	      flash[:notice] = "Could not delete link named #{@link.title}!"
      end
    end
    
    respond_to do |format|
      format.html { redirect_to(links_url) }
      format.xml  { head :ok }
    end
  end
  
  def suggest_title
    render :update do |page|
      page.title_for_url
    end
  end
  
  # this is an AJAX method call, it updates the current page!
  def add_comment
    @link = Link.find(params[:id])
    @notice = @link.add_comment params[:comment][:title], params[:comment][:text]
 		@count =  @link.comments.size
 		@comment = @link.comments[@count-1]
  end
  
  def add_rating
	  rating = Rating.new(:ip => request.env['REMOTE_ADDR'],
                        :value => params[:rating])
    @link = Link.find(params[:id])
    @link.ratings << rating
    if @link.save
    	@notice = 'Your rating was successfully saved!'
    else
      @notice = 'Sorry, your rating could not be saved!'
    end
  end

end
