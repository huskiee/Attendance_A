class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :set_user, only: [:edit_one_month, :update_one_month, :edit_monthly_request, :log_attendant]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overwork_request, :update_overwork_request, :edit_monthly_request]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only:[:edit_one_month, :edit_monthly_request]

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
    @superiors = User.where(superior: true).where.not(id: @user.id)
     respond_to do |format|
      format.html
      format.csv do |csv|
        send_attendance_csv(@attendances)
      end
    end
  end
  
  def update_one_month
    #ActiveRecord::Base.transaction do # トランザクションを開始します。
      #if attendances_invalid?
        #attendances_params.each do |id, item|
          #attendance = Attendance.find(id)
          #attendance.update_attributes!(item)
        #end
        #flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        #redirect_to user_url(date: params[:date])
      #else
        #flash[:danger] = "出勤又は退勤の一方のみの入力データがあった為、更新をキャンセルしました。"
        #redirect_to attendances_edit_one_month_user_path(date: params[:date])
      #end
    #end
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      attendances_params.each do |id, item|
        attendance = Attendance.find(id) # Attendanceテーブルから1つのidを見つける
        if item[:daily_request_superior].present?
          item[:daily_request_status] = "申請中"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    if c1 > 0
      flash[:success] = "勤怠編集を#{c1}件、申請しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "上長を選択してください"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  # 残業申請フォーム
  def edit_overwork_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    @superiors = User.where(superior: true).where.not(id: @user.id)
    #@day = Date.parse(params[:day])
    #@attendance = @user.attendances.find_by(worked_on: @day)
  end

  # 申請者の残業変更送信
  def update_overwork_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:attendance_id])
    params[:attendance][:overwork_request_status] = "申請中"
    if overwork_params[:over_ending_time_at].present?
      @attendance.update_attributes(overwork_params)
      flash[:success] = "残業申請をしました。"
    else
      flash[:danger] = "残業申請をキャンセルしました。"
    end
    redirect_to @user
  end
  
  # 上長の個別残業申請のお知らせモーダル
  def edit_overwork_info
    @user = User.find(params[:user_id])
    #@attendance = Attendance.where(overwork_request_status: "申請中", overwork_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
    #@apply_users = User.where(id: Attendance.where(overwork_request: @user.name, overwork_request_status: "申請中").select(:user_id))
    #@overwork_lists = Attendance.where(overwork_request: @user.name, overwork_request_status: "申請中")
    #@attendances = Attendance.where(overwork_request_status: "申請中", overwork_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
    @attendances = Attendance.where(overwork_request_status: "申請中", overwork_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
    #@attendance_lists = Attendance.where(overwork_request_status: "申請中", confirmer: @user.name).order(:user_id, :worked_on).group_by(&:user_id)
    @request_user = User.where(id: Attendance.where(confirmer: @user.name, overwork_request_status: "申請中").select(:user_id))
    #@request_users = Attendance.where(overwork_request_status: "申請中", apply_to_superior: @user.id).order(:worked_on).group_by(&:user_id)
  end
  
  # 上長の個別残業申請の変更送信（承認）
  def update_overwork_info
    @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      overwork_request_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:request_change] == "1"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "残業申請の結果を#{c1}件、送信しました"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  # 上長の勤怠編集のお知らせモーダル
  def edit_daily_info
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(daily_request_status: "申請中", daily_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
    @request_user = User.where(id: Attendance.where(confirmer: @user.name, daily_request_status: "申請中").select(:user_id))
  end
  
  # 上長の勤怠編集申請の変更送信（承認）
  def update_daily_info
    @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      daily_request_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:daily_change] == "1"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "残業申請の結果を#{c1}件、送信しました"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to @user
  end
  
  # １ヶ月分のまとめた申請
  def edit_monthly_request
    @offer = @user.attendances.find_by(worked_on: params[:date])
    params[:monthly_request_status] = "申請中"
    @offer.update_attributes(monthly_request_params)
    flash[:success] = "1ヶ月分の勤怠情報を申請しました。"
    redirect_to user_url(current_user)
  end
  
  def update_monthly_request
  end

  # １ヶ月分のお知らせ承認
  def edit_monthly_info
    @user = User.find(params[:user_id])
    @attendances = Attendance.where(monthly_request_status: "申請中", monthly_request_superior: @user.id).order(:worked_on).group_by(&:user_id)
    @request_user = User.where(id: Attendance.where(confirmer: @user.name, monthly_request_status: "申請中").select(:user_id))
  end
  
  # １ヶ月分のお知らせ承認
  def update_monthly_info
    @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      monthly_info_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:monthly_check] == "1"
          c1 += 1
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "所属長承認の勤怠申請（１ヶ月分）を#{c1}件、結果を送信しました"
    redirect_to @user
  end

  # 勤怠修正ログ画面をモーダルで表示
  def log_attendant
    @user = User.find(params[:id])
    @search = @user.attendances.where(daily_request_status: "承認").order(:worked_on).ransack(params[:q])
    @attendances = @search.result
    #if params[:month].present?
      #first_day = (params[:month] + "-1").to_date
      #last_day = first_day.end_of_month
      #this_month = [first_day..last_day]
    #end
    #@attendances = @user.attendances.where(worked_on: this_month).where(monthly_request_status: "承認")
    #if params["select_year(1i)"].present? && params["select_month(2i)"].present?
     #@first_day = (params["select_year(1i)"] + "-" + params["select_month(2i)"] + "-01").to_date
      #@attendances = @user.attendances.where(worked_on: @first_day..@first_day.end_of_month, daily_request_status: "承認").order(:worked_on)
    #end
  end

  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :over_ending_time_at, :next_day, :overtime, :work_description, 
                                                 :overwork_request_superior, :overwork_request_status,
                                                 :edit_day_started_at, :edit_day_finished_at, :edit_lastday_started_at, :edit_lastday_finished_at])[:attendances]
    end
    
    def overwork_params
      params.require(:attendance).permit(:over_ending_time_at, :work_description, :next_day, :overwork_request_superior, :overwork_request_status)
    end

    # 個別残業申請/承認（承認時は申請者のステータスをみて書き加える。）
    def overwork_request_params
      params.require(:user).permit(attendances: [:overwork_request_status, :request_change])[:attendances]
    end
    
    # 勤怠編集の申請/承認
    def daily_request_params
      params.require(:user).permit(attendances: [:daily_request_status, :daily_change])[:attendances]
    end

    # 所属長承認の勤怠申請（１ヵ月分）
    def monthly_request_params
      params.permit(:monthly_request_superior, :monthly_request_status)
    end

    # 所属長の勤怠承認（１ヵ月分）
    def monthly_info_params
      params.require(:user).permit(attendances: [:monthly_request_status, :monthly_change])[:attendances]
    end

    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可します。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end
    end

end