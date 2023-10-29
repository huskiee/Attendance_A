class AddEditDayStartedAtToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :edit_started_at, :datetime
    add_column :attendances, :edit_finished_at, :datetime
    add_column :attendances, :log_started_at, :datetime
    add_column :attendances, :log_finished_at, :datetime
  end
end
