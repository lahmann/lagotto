class ImportJob < ActiveJob::Base
  queue_as :critical

  def perform(klass, options)
    import = klass.constantize.new(options)
    import.process_data(options[:offset].to_i)
  end
end
