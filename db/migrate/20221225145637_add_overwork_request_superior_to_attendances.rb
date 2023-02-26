class AddOverworkRequestSuperiorToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_request_superior, :string
    add_column :attendances, :overwork_info_superior, :string
    add_column :attendances, :daily_request_superior, :string
    add_column :attendances, :monthly_request_superior, :string
  end
end
