class LineReferentialSyncWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker
  extend Concerns::FailingSupport
  
  sidekiq_options retry: true

  def process_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC, :second)
  end

  def perform(lref_sync_id)
    start_time = process_time
    lref_sync  = LineReferentialSync.find lref_sync_id
    lref_sync.run if lref_sync.may_run?
    begin
      info = Stif::CodifLineSynchronization.synchronize
      lref_sync.successful info.merge({processing_time: process_time - start_time})
    rescue Exception => e
      Rails.logger.error "LineReferentialSyncWorker failed: #{e.message} - #{e.backtrace.join("\n")}"
      lref_sync.failed({
        error: e.message,
        processing_time: process_time - start_time
      })
    end
  end
end
