class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @my_rooms = @user.rooms # 自分がオーナーの施設
    @my_reservations = @user.reservations # 自分が予約した履歴
  end
  
  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "プロフィールを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :introduction, :icon_image)
  end
end