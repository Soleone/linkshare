# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  helper_method :render_to_string

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery :secret => 'a0e494633b1448e7c6b1e9e061abf42b'
  
  protect_from_forgery :only => [:create, :delete, :update] 
  
  before_filter :check_language
  
  protected
  def check_language
    if params[:lang]    
      Globalite.language = params[:lang]
    end
  end
end
