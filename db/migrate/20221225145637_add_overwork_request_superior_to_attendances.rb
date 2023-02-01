class AddOverworkRequestSuperiorToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_request_superior, :integer
    add_column :attendances, :overwork_info_superior, :integer
    add_column :attendances, :daily_request_superior, :integer
    add_column :attendances, :monthly_request_superior, :integer
  end
end
