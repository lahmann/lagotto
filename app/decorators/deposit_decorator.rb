class DepositDecorator < Draper::Decorator
  delegate_all

  def id
    uuid
  end

  def source
    object.source.name
  end

  def status
    human_state_name
  end
end
