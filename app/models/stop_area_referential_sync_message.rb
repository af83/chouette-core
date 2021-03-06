class StopAreaReferentialSyncMessage < ApplicationModel
  belongs_to :stop_area_referential_sync
  enum criticity: [:info, :warning, :error]

  validates :criticity, presence: true
end
