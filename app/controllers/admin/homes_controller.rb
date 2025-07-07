class Admin::HomesController < Admin::ApplicationController
  skip_before_action :authenticate_admin!, only: [:top]
  
  def top
  end
end
