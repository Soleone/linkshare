class TextileController < ApplicationController

  def index
    @text = params[:text] || request.raw_post || ''
    render :partial => 'shared/textile_preview'
  end
end
