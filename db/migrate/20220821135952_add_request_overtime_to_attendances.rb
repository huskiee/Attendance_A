class AddRequestOvertimeToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :next_day, :boolean
    add_column :attendances, :work_description, :string
    add_column :attendances, :change, :boolean
    add_column :attendances, :apply_to_superior, :string
  end
end
