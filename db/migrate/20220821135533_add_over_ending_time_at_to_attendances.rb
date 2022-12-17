class AddOverEndingTimeAtToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :over_ending_time_at, :time
  end
end
