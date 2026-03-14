class RoomsController < ApplicationController
  # ログインしていないと登録できないようにする（Devise導入済みの場合）
  before_action :authenticate_user!, except: [:index, :show, :search]

  def index
    @rooms = Room.all
  end

  def show
    @room = Room.find(params[:id])
    @reservation = Reservation.new
  end

  def posts
    # ログインしているユーザーが投稿した（登録した）施設だけを取得する
    @rooms = current_user.rooms
  end

  def search
    keyword = params[:keyword]
    address = params[:address]
  
    @rooms = Room.all
  
    # 1. キーワード検索（ここを強化します！）
    if keyword.present?
      k = "%#{keyword.strip}%"
      # 名前(name) か 紹介文(introduction) か 住所(address) のどれかにキーワードが含まれるものを探す
      @rooms = @rooms.where('name LIKE ? OR introduction LIKE ? OR address LIKE ?', k, k, k)
      
      # もしキーワードに「京都」と入れた場合も、東京都を弾く
      if keyword.strip == "京都"
        @rooms = @rooms.where.not('address LIKE ?', "%東京都%")
      end
    end
  
    # 2. エリア検索（入力欄 or 画像リンク）
    if address.present?
      a = "%#{address.strip}%"
      @rooms = @rooms.where('address LIKE ?', a)
      
      # エリアで「京都」が選ばれた時も、東京都を弾く
      if address.strip == "京都"
        @rooms = @rooms.where.not('address LIKE ?', "%東京都%")
      end
    end
  end

  # --- ここから施設登録用の機能 ---

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    @room.user_id = current_user.id # 誰が登録したか紐付け
    if @room.save
      redirect_to room_path(@room), notice: "施設を登録しました！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @room = Room.find(params[:id])
    if @room.user != current_user
      redirect_to rooms_path, alert: "他人の施設は編集できません。"
    end
  end

  def update
    @room = Room.find(params[:id])
    if @room.update(room_params)
      redirect_to room_path(@room), notice: "施設情報を更新しました！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @room = Room.find(params[:id])
    if @room.user == current_user
      @room.destroy
      redirect_to rooms_path, notice: "施設を削除しました。"
    else
      redirect_to rooms_path, alert: "削除権限がありません。"
    end
  end

  # 予約編集画面
  def edit
    @reservation = Reservation.find(params[:id])
    @room = @reservation.room
    # 自分以外の予約を編集できないようにガード
    redirect_to posts_rooms_path, alert: "権限がありません" if @reservation.user != current_user
  end

  # 予約更新
  def update
    @reservation = Reservation.find(params[:id])
    if @reservation.update(reservation_params)
      redirect_to reservations_path, notice: "予約内容を更新しました"
    else
      @room = @reservation.room
      render :edit, status: :unprocessable_entity
    end
  end

  # 予約削除
  def destroy
    @reservation = Reservation.find(params[:id])
    if @reservation.user == current_user
      @reservation.destroy
      redirect_to reservations_path, notice: "予約をキャンセルしました"
    else
      redirect_to reservations_path, alert: "削除権限がありません"
    end
  end
  
  private

  def room_params
    # room_image（画像）が含まれているか確認してください
    params.require(:room).permit(:name, :introduction, :price, :address, :room_image)
  end
end