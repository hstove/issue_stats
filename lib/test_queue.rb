class TestQueue < ::Queue
  attr_writer :consumer

  def initialize(consumer_options = {})
    super()
    @consumer_options = consumer_options
  end

  def consumer
    @consumer ||= ThreadedQueueConsumer.new(self, @consumer_options)
  end

  # Drain the queue, running all jobs in a different thread. This method
  # may not be available on production queues.
  def drain
    # run the jobs in a separate thread so assumptions of synchronous
    # jobs are caught in test mode.
    consumer.drain
  end

  def push(job)
    super.tap { drain }
  end
  alias <<  push
  alias enq push
end

class ThreadedQueueConsumer
  attr_accessor :logger

  def initialize(queue, options = {})
    @queue = queue
    @logger = options[:logger]
    @fallback_logger = Logger.new($stderr)
  end

  def start
    @thread = Thread.new { consume }
    self
  end

  def shutdown
    @queue.push nil
    @thread.join
  end

  def drain
    while job = @queue.pop(true)
      job.run
    end
  rescue ThreadError
  end

  def consume
    while job = @queue.pop
      run job
    end
  end

  def run(job)
    job.run
  rescue Exception => exception
    handle_exception job, exception
  end

  def handle_exception(job, exception)
    (logger || @fallback_logger).error "Job Error: #{job.inspect}\n#{exception.message}\n#{exception.backtrace.join("\n")}"
  end
end