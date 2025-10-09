class DestroyUserJob < ApplicationJob
  queue_as :default

  def perform(user_id:)
    user = User.find(user_id)
    user.incinerate!
  end
end
