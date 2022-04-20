class Base < ApplicationRecord
  
  validates :base_number, presence: true, uniqueness: true, numericality: { :greater_than_or_equal_to => 0 } 
  validates :base_name, presence: true
  validates :base_type, presence: true

  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["base_number", "base_name", "base_type"]
  end

end
