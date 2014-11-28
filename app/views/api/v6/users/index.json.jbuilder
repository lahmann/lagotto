json.meta do
  json.total @users.total_entries
  json.total_pages (@users.total_entries.to_f / @users.per_page).ceil
  json.page @users.total_entries > 0 ? @users.current_page : 0
end

json.users @users do |user|
  json.cache! ['v6', user, params[:role], params[:query]], skip_digest: true do
    json.(user, :id, :name, :username, :email, :role, :publisher, :reports, :create_date, :update_date)
  end
end
