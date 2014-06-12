class DefaultCommandCallback < Fountain::Command::CommandCallback
  attr_reader :logger

  def initialize(logger = Fountain.logger)
    @logger = logger
  end

  def on_success(result)
    logger.debug(result)
  end

  def on_failure(cause)
    logger.debug("#{cause}\n#{cause.backtrace.join("\n")}")
    raise cause
  end
end
