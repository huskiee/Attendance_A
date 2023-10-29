class RenameEditDayStartedAtColumnToAttendances < ActiveRecord::Migration[5.1]
  def change
    rename_column :attendances, :edit_day_started_at, :edit_started_at
    rename_column :attendances, :edit_day_finished_at, :edit_finished_at
    rename_column :attendances, :edit_lastday_started_at, :log_started_at
    rename_column :attendances, :edit_lastday_finished_at, :log_finished_at
  end
end
