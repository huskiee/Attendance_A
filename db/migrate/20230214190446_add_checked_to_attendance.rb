class AddCheckedToAttendance < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :request_change, :boolean
    add_column :attendances, :daily_change, :boolean
    add_column :attendances, :monthly_change, :boolean
  end
end
