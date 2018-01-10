class ComplianceControlSet < ActiveRecord::Base
  has_paper_trail class_name: 'PublicVersion'
  belongs_to :organisation
  has_many :compliance_control_blocks, dependent: :destroy
  has_many :compliance_controls, dependent: :destroy

  validates :name, presence: true
  validates :organisation, presence: true

  scope :where_updated_at_between, ->(period_range) do
    where('updated_at BETWEEN :begin AND :end', begin: period_range.begin, end: period_range.end)
  end
end
