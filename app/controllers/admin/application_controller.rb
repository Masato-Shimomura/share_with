class Admin::ApplicationController < ActionController::Base
  layout 'admin'
  before_action :authenticate_admin!
end