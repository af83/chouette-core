require 'net/http'
class NetexImport < Import
  validates :referential_id, presence: true
  validates :workbench_id, presence: true

  after_commit :launch_java_import


  def launch_java_import
    logger.warn  "Call iev get #{Rails.configuration.iev_url}/boiv_iev/referentials/importer/new?id=#{id}"
    begin
      Net::HTTP.get(URI("#{Rails.configuration.iev_url}/boiv_iev/referentials/importer/new?id=#{id}"))
    rescue Exception => e
      logger.error "IEV server error : #{e.message}"
      logger.error e.backtrace.inspect
    end
  end
end
