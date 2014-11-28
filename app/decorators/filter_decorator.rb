class FilterDecorator < Draper::Decorator
  delegate_all

def id
  name
end

end
