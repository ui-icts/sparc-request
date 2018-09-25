class ExcelApiController < ApplicationController

  def consolidated_request
    @protocol = Protocol.find 1799
    render :layout => false
  end
end
