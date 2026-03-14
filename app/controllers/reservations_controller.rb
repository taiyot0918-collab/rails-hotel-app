class ReservationsController < ApplicationController
  before_action :authenticate_user!
  # 編集・更新・削除の前に、対象の予約データをセットする共通処理
  before_action :set_reservation, only: [:edit, :update, :destroy]
  # 自分以外の予約を操作できないようにするガード
  before_action :ensure_correct_user, only: [:edit, :update, :destroy]

  def index
    @reservations = current_user.reservations.order(created_at: :desc)
  end

  def confirm
    @reservation = current_user.reservations.build(reservation_params)
    @room = Room.find(params[:reservation][:room_id])
    
    # バリデーションチェック
    return render_show if @reservation.invalid?

    # 宿泊日数の計算
    @stay_days = (@reservation.end_date - @reservation.start_date).to_i

    if @stay_days <= 0
      @reservation.errors.add(:end_date, "はチェックイン日より後の日付を選択してください")
      return render_show
    end
  
    @total_price = @reservation.person_count * @stay_days * @room.price
  end

  def create
    @reservation = current_user.reservations.build(reservation_params)
    
    if @reservation.save
      redirect_to reservations_path, notice: "予約が完了しました"
    else
      @room = Room.find(params[:reservation][:room_id])
      render_show
    end
  end

  def edit
    @room = @reservation.room
  end 

  def update
    if @reservation.update(reservation_params)
      redirect_to reservations_path, notice: "予約を更新しました。"
    else
      @room = @reservation.room 
      render :edit, status: :unprocessable_entity
    end
  end 

  def destroy
    @reservation.destroy
    redirect_to reservations_path, notice: "予約をキャンセルしました。"
  end

  private

  def reservation_params
    params.require(:reservation).permit(:start_date, :end_date, :person_count, :room_id)
  end

  # 指定したIDの予約を取得する
  def set_reservation
    @reservation = Reservation.find(params[:id])
  end

  # ログインユーザーが予約の持ち主か確認する
  def ensure_correct_user
    if @reservation.user != current_user
      redirect_to reservations_path, alert: "権限がありません。"
    end
  end

  # エラー時に詳細画面へ戻る処理を共通化
  def render_show
    render "rooms/show", status: :unprocessable_entity
  end
end