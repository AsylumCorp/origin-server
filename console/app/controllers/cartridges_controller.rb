class CartridgesController < ConsoleController
  include Console::ModelHelper

  def index
     # on index get, redirect back to application details page
     redirect_to application_path(params[:application_id])
  end

  def show
    @application = Application.find(params[:application_id], :as => current_user)
    @application_type = ApplicationType.find @application.framework
    @cartridge = @application.find_cartridge params[:id]
  end

  def create
    name = (params[:cartridge] || {})[:name].presence
    url = (params[:cartridge] || {})[:url].presence
    gear_size = (params[:cartridge] || {})[:gear_size].presence

    @application = Application.find(params[:application_id], :as => current_user)
    @capabilities = @application.domain.capabilities
    @cartridge_type = url ? CartridgeType.for_url(url) : CartridgeType.find(name)
    @gear_sizes = add_cartridge_gear_sizes(@application, @cartridge_type, @capabilities)
    @cartridge = Cartridge.new(:url => url, :name => url ? nil : name, :gear_size => gear_size, :as => current_user, :application => @application)

    if @cartridge.save
      @wizard = true

      message = @cartridge.remote_results
      flash[:info_pre] = message

      redirect_to application_path(@application)
    else
      Rails.logger.debug @cartridge.errors.inspect
      @application_id = @application.id
      render 'cartridge_types/show'
    end
  end
end

