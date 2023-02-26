class AddEditDayStartedAtToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_day_started_at, :datetime
    add_column :attendances, :edit_day_finished_at, :datetime
    add_column :attendances, :edit_lastday_started_at, :datetime
    add_column :attendances, :edit_lastday_finished_at, :datetime
  end
end
