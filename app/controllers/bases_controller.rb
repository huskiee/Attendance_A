class BasesController < ApplicationController
  before_action :set_base, only: [:update, :destroy, :edit_base_info, :update_base_info]
  
  before_action :admin_user, only: [:index, :update, :show, :destroy, :edit_base_info, :update_base_info]
  
  def index
    @bases = Base.all
    if params[:id].present?
      @base = Base.find_by(id: @base.id)
    else
      @base = Base.new
    end
  end

  def show
    redirect_to bases_url
  end
  
  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "#{@base.base_name}を新規登録しました！"
    　redirect_to @base
    else
      flash[:danger] = "#{@base.base_name}の新規登録に失敗しました。<br>" + "入力エラーが#{@base.errors.count}件ありました。<br>" + @base.errors.full_messages.join("<br>")
      redirect_to bases_url
    end
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
       flash[:success] = "#{@base.base_name}の拠点情報を更新しました。"
       redirect_to @base
    else
      flash[:danger] = "#{@base.base_name}の拠点情報の更新に失敗しました。<br>" + "入力エラーが#{@base.errors.count}件ありました。<br>" + @base.errors.full_messages.join("<br>")
      redirect_to bases_url
    end
  end
  
  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "#{@base.base_name}のデータを削除しました。"
    redirect_to bases_url
  end

  def edit_base_info
    @base = Base.find(params[:id])
  end

  def update_base_info
    @base = Base.find(params[:id])
    if @base.update_attributes(base_info_params)
      flash[:success] = "#{@base.base_name}の拠点情報を更新しました。" # 更新成功時の処理
      redirect_to @base
    else
      flash[:danger] = "#{@base.base_name}の更新は失敗しました。<br>" + @base.errors.full_messages.join("<br>") # 更新失敗時の処理
      redirect_to bases_url
    end
  end

  
  private
    def set_base
      @base = Base.find(params[:id])
    end
    # paramsハッシュから拠点情報を取得します。
    def base_params
      params.require(:base).permit(:base_number, :base_name, :base_type)
    end

    def base_info_params
      params.require(:base).permit(:base_number, :base_name, :base_type)
    end    
    
end
