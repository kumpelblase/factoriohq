class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
  end

  def update
    if current_user.update(user_params)
      redirect_to edit_user_path, notice: 'Settings updated successfully.'
    else
      flash.now[:alert] = 'Failed to update settings.'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:factorio_token, :factorio_username)
  end
end