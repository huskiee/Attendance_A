class AttendancesController < ApplicationController
  include AttendancesHelper

  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month, :edit_overwork_request, :update_overwork_request]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

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
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      if attendances_invalid?
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          attendance.update_attributes!(item)
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "出勤又は退勤の一方のみの入力データがあった為、更新をキャンセルしました。"
        redirect_to attendances_edit_one_month_user_path(date: params[:date])
      end
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
    if overwork_request_params[:over_ending_time_at].present?
      @attendance.update_attributes(overwork_request_params)
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
    @attendances = Attendance.where(overwork_request_status: "申請中", apply_to_superior: @user.id).order(:worked_on).group_by(&:user_id)
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
        if item[:change] == "1"
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
  
  
  def edit_overwork_permission
     @user = User.find(params[:user_id])
    c1 = 0
    ActiveRecord::Base.transaction do # トランザクションを開始します。
      overwork_request_params.each do |id, item|
        attendance = Attendance.find(id)
        if item[:change] == "1"
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

  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note, :over_ending_time_at, :overtime, :work_description, :apply_to_superior])[:attendances]
    end
    # 個別残業申請/承認（承認時は申請者のステータスをみて書き加える。）
    def overwork_request_params
      params.require(:user).permit(attendances: [:overwork_request_status, :change])[:attendances]
    end
    # 個別残業申請の承認
    def overwork_info_params
      params.require(:user).permit(attendances: [:overwork_info_status, :change])[:attendances]
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
