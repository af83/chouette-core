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

    on_failure = -> {
      lref_sync.failed({
        error: e.message,
        processing_time: process_time - start_time
      })
    }

    Chouette::ErrorsManager.watch('LineReferentialSyncWorker failed', on_failure: on_failure) do
      info = Stif::CodifLineSynchronization.synchronize
      lref_sync.successful info.merge({processing_time: process_time - start_time})
    end
  end
end
