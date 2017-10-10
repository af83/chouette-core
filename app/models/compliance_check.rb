class ComplianceCheck < ActiveRecord::Base
  extend Enumerize
  belongs_to :compliance_check_set
  belongs_to :compliance_check_block
  
  enumerize :criticity, in: %i(info warning error), scope: true, default: :warning
  validates :criticity, presence: true
  validates :name, presence: true
  validates :code, presence: true
  validates :origin_code, presence: true
end
