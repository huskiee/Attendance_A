class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info, :show_read_only]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  #before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: [:show, :show_read_only]
  before_action :admin_or_correct_user, only: [:show]

  def index
    @users = User.paginate(page: params[:page], per_page: 20)
    @users = @users.where(admin: false)
    if params[:id].present?
      @user = User.find_by(id: @users.id)
    else
      @user = User.new
    end
  end

  def attendant_employees
    @users = User.all.includes(:attendances)
  end

  def import
    if params[:file].blank?
      flash[:warning] = "CSVファイルが選択されていません。"
      redirect_to user_url
    else
      User.import(params[:file])
      flash[:success] = "ユーザー情報をインポートしました。"
      redirect_to users_url
    end
  end

  def show
    redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    get_show_attendances
  end

  def show_read_only
    #redirect_to(root_url) unless current_user?(@user) || current_user.admin?
    get_show_attendances
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    @users = User.paginate(page: params[:page], per_page: 20)
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "アカウント情報を更新しました。"
      redirect_to users_url
    else
      redirect_to users_url      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。" # 更新成功時の処理
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>") # 更新失敗時の処理
    end
    redirect_to users_url
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation, :employee_number, :uid, :basic_work_time, :designated_work_time, :designated_work_start_time, :designated_work_end_time)
    end

    def basic_info_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation, :employee_number, :uid, :basic_work_time, :designated_work_time, :designated_work_start_time, :designated_work_end_time)
    end    

    def get_show_attendances
      @worked_sum = @attendances.where.not(started_at: nil).count
      @overwork_request = Attendance.where(overwork_request_status: "申請中", overwork_request_superior: @user.id)
      @overwork_info = Attendance.where(overwork_info_status: "申請中", overwork_info_superior: @user.id)
      @daily_request = Attendance.where(daily_request_status: "申請中", daily_request_superior: @user.id)
      @monthly_request = Attendance.where(monthly_request_status: "申請中", monthly_request_superior: @user.id)
      #@overwork_sum = Attendance.where(over_request_status: "申請中", over_request_superior: @user.id).count
      #@edit_day_sum = Attendance.where(edit_day_request_status: "申請中", edit_day_request_superior: @user.id).count
      @superiors = User.where(superior: true).where.not(id: @user.id)
      @apply = @user.attendances.find_by(worked_on: @first_day)
    end

    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "閲覧権限がありません。"
        redirect_to user_path(current_user.id)
      end  
    end
end
