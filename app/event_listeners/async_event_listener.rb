class AsyncEventListener < BaseEventListener
  inheritable_accessor :router do
    Fountain::Router.create_router
  end

  route AllRobotsProgrammed do |event|
    PlayCurrentRoundJob.perform_async(event.id)
  end
end
