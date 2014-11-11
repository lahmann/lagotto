object false

node(:error) { nil }

child @source => :data do
  attributes :name, :display_name, :group, :description, :update_date

  if current_user.is_admin_or_staff?
    attributes :article_count, :event_count, :by_day, :by_month
  end
end
