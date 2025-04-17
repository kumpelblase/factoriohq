class Admin::SiteSettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin

  def index
    @registration_enabled = SiteSetting.get('registrations_enabled', 'true') == 'true'
  end

  def update
    SiteSetting.set('registrations_enabled', params[:registrations_enabled] == '1' ? 'true' : 'false')
    redirect_to admin_site_settings_path, notice: 'Settings updated successfully'
  end

  private

  def ensure_admin
    redirect_to root_path, alert: 'Access denied' unless current_user.admin?
  end
end