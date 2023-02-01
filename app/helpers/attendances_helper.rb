module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    return false
  end
  
  # 出勤時間と退勤時間を受け取り、在社時間を計算して返します。
  def working_times(start_at, finish_at)
     format("%.2f", (((finish_at - start_at) / 60) / 60.0))
  end
  # 終了時間と指定勤務終了時間を受け取り、在社時間を計算して返します。
  #def edit_working_times(edit_day_started_at, edit_day_finished_at, next_day)
    #if next_day == "1"
      #format("%.2f", (((edit_day_finished_at - edit_day_started_at) / 60) / 60.0) +24)
    #elsif next_day == "0"
      #format("%.2f", ((edit_day_finished_at - edit_day_started_at) / 60) / 60.0)
    #end
  #end
  
  # 終了時間と指定勤務終了時間を受け取り、残業時間を計算して返します。
  def working_overtimes(over_ending_time_at, designated_work_end_time, next_day)
    if  next_day
      format("%.2f", (over_ending_time_at.hour - designated_work_end_time.hour) + ((over_ending_time_at.min - designated_work_end_time.min) / 60.0) + 24)
    else
      format("%.2f", (over_ending_time_at.hour - designated_work_end_time.hour) + ((over_ending_time_at.min - designated_work_end_time.min) / 60.0))
    end
  end  
  
  def superiors(overwork_request_superior)
    User.find(overwork_request_superior)
  end
  
  def format_hour(time)
    format('%.d',((time.hour)))
  end
  
  def format_min(time)
    format("%.2d",((time.strftime('%M').to_i / 15).round) * 15)
  end
  
     # 不正な値があるか確認する
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:started_at].blank? && item[:finished_at].blank?
        next
      elsif item[:started_at].blank? || item[:finished_at].blank?
        attendances = false
        break
      elsif item[:started_at] > item[:finished_at]
        attendances = false
        break
      end
    end
    return attendances
  end
end
  