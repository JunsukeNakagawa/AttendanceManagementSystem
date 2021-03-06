class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :show_user, only: [:show, :attendancetime_edit, :attendancetime_update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy, :timeupdate ]
  
  def index
    @users = User.where(activated: true).paginate(page: params[:page]).search(params[:search])
  end
  
  def show
    @work = Work.find_by(id: params[:id])
   if logged_in?
     @user = current_user
   end
   if @work.nil?
    @work = Work.new
   end
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
  end

  def new
    @user = User.new
  end
  
  def attend
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.attendance_time = Time.new(Time.now.year,Time.now.month,Time.now.day,Time.new.hour,Time.now.min,00)
    if @work.save
      flash[:success] = "出社時間を登録しました"
      redirect_to user_path
    else
      render("works/edit")
    end
  end
  
  def leave
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.leaving_time = Time.new(Time.now.year,Time.now.month,Time.now.day,Time.new.hour,Time.now.min,00)
    if @work.save
      flash[:success] = "退社時間を登録しました"
      redirect_to user_path
    else
      render("works/edit")
    end
  end
  
  def timeedit
    @user = User.find(params[:id])
  end
  
  def attendancetime_edit
    @user = User.find(params[:id])
    @first_day = params[:first_day].to_datetime
    if @work.nil?
      @work = Work.new
    end
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
  end
  
  def attendancetime_update
    @user = User.find(params[:id])
    works_params.each do |id, value|
      work=Work.find(id)
      work.update_attributes(value)
    end
    flash[:success] = "勤怠時間を編集しました"
    redirect_to user_path
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:info] = "ユーザを登録しました"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "プロフィールをアップデートしました"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def timeupdate
    @user = User.find(params[:id])
    if @user.update_attributes(time_params)
      flash[:success] = "基本時間をアップデートしました"
      redirect_to basictime_edit_path
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザーを削除しました"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation,:affiliation)
    end
    
    def time_params
      params.require(:user).permit(:workingtime,:basictime)
    end
    
    def works_params
      params.require(:work).permit(works: [:attendance_time, :leaving_time])[:works]
    end
    
    # beforeアクション

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def show_user
      @user = User.find(params[:id])
      redirect_to(root_url) if @user != User.find_by(id: session[:user_id]) unless current_user.admin?
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end