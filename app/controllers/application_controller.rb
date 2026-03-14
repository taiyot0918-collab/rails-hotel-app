class ApplicationController < ActionController::Base
  # deviseの機能が使われる前に、このメソッドを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # 新規登録時に name と icon_image を許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :icon_image])
    # アカウント更新時に name, introduction, icon_image を許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :introduction, :icon_image])
  end
end