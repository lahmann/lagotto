json.user do
  json.cache! ['v6', @user], skip_digest: true do
    json.(@user, :id, :name, :username, :email, :role, :publisher, :reports, :create_date, :update_date)
  end
end
