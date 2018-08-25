class WorksController < ApplicationController
  
  def new
   if logged_in?
     @user  = current_user
     #@working_days = Work.group(:leaving_time).where(userid: current_user).count
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
  
  def show
    @work = Work.find_by(id: params[:id])
  end
  
  def attend
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.attendance_time = Time.now
    if @work.save
      flash[:success] = "出社時間を登録しました"
      redirect_to root_url
    else
      render("works/edit")
    end
  end
  
  def leave
    @work = Work.find_by(day: Date.today, userid: current_user.id)
    @work.leaving_time = Time.now
    if @working_days.nil?
    end
    if @work.save
      flash[:success] = "退社時間を登録しました"
      redirect_to root_url
    else
      render("works/edit")
    end
  end
  
  def edit
    @user  = current_user
    @work = Work.find_by(id: current_user.id)
    if !params[:first_day].nil?
      @first_day = Date.parse(params[:first_day])
    else
      @first_day = Date.new(Date.today.year, Date.today.month)
    end
    @last_day = @first_day.end_of_month
  end
  
  def update
    works_params.each do |id, value|
      work=Work.find(id)
      work.update_attributes(value)
    end
    flash[:notice] = "勤怠時間を編集しました"
    redirect_to("/works/edit")
  end
  
  private
    def works_params
      params.require(:work).permit(works: [:attendance_time, :leaving_time])[:works]
    end

    
end
