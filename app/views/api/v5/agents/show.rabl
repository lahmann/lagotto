object false

node(:error) { nil }

child @agent => :data do
  attributes :name, :display_name, :group, :update_date

  if current_user.is_admin_or_staff?
    attributes :state, :jobs, :responses, :error_count, :status
  end
end
