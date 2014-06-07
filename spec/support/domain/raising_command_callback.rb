class RaisingCommandCallback < Fountain::Command::CommandCallback
  def on_failure(cause)
    raise cause
  end
end
