class AddOverworkRequestStatusToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_request_status, :string
    add_column :attendances, :overwork_info_status, :string
    add_column :attendances, :daily_request_status, :string
    add_column :attendances, :monthly_request_status, :string
  end
end
