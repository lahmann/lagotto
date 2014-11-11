object false

node(:total) { |m| @agents.size }
node(:error) { nil }

child @agents => :data do
  object @agent

  attributes :name, :display_name, :group, :description, :update_date

  if current_user.is_admin_or_staff?
    attributes :status
  end
end
