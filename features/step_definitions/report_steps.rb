### GIVEN ###

Given /^we have report "(.*?)"$/ do |name|
  @report = FactoryGirl.create(:report, :name => name)
end

Given /^we have selected the report$/ do
  @report.users << @user
end

### WHEN ###

When /^I check the checkbox for the report "(.*?)"$/ do |name|
  check name
end

When /^I uncheck the checkbox for the report "(.*?)"$/ do |name|
  page.driver.render("tmp/capybara/#{name}.png") if @wip
  uncheck name
end

### THEN ###

Then /^I should see the report "(.*?)"$/ do |name|
  page.has_css?('td', :text => name, :visible => true).should be true
end

Then /^I should not see the report "(.*?)"$/ do |name|
  page.has_css?('td', :text => name, :visible => true).should_not be true
end

Then(/^I should see the "(.*?)" link$/) do |name|
  page.driver.render("tmp/capybara/#{name}.png") if @wip
  page.has_link?(name).should be true
end
