# Creates a Locomotive::Site record
#
# examples:
# - I have the site: "some site" set up
# - I have the site: "some site" set up with name: "Something", domain: "test2"
#
Given /^I have the site: "([^"]*)" set up(?: with #{capture_fields})?$/ do |site_factory, fields|
  Thread.current[:site] = nil
  @site = FactoryGirl.create(site_factory, parse_fields(fields))
  @site.should_not be_nil

  @admin = @site.memberships.first.account
  @admin.should_not be_nil
end

Given /^I have a site set up$/ do
  step %{I have the site: "test site" set up}
end

Given /^I have a designer and an author$/ do
  FactoryGirl.create(:designer, :site => Locomotive::Site.first)
  FactoryGirl.create(:author, :site => Locomotive::Site.first)
end

Then /^I should be a administrator of the "([^"]*)" site$/ do |name|
  site = Locomotive::Site.where(:name => name).first
  m = site.memberships.detect { |m| m.account_id == @admin._id && m.admin? }
  m.should_not be_nil
end

# sets the robot_txt for a site

Given /^a robot_txt set to "([^"]*)"$/ do |value|
  @site.update_attributes(:robots_txt => value)
end

Then /^I should be able to add a domain to my site$/ do
  visit edit_current_site_path

  fill_in 'domain', :with => 'monkeys.com'
  click_link '+ add'
  click_button 'Save'

  page.should have_content 'My site was successfully updated'
  @site.reload.domains.should include 'monkeys.com'
end

class PluginClass
  include Locomotive::Plugin
end

Given /^I have registered the plugin "([^"]*)"$/ do |plugin_id|
  LocomotivePlugins.register_plugin(PluginClass, plugin_id)
end

Then /^I should be able to add the plugin "([^"]*)" to my site$/ do |plugin_id|
  visit edit_current_site_path

  check "site_enabled_plugins_#{plugin_id}"
  click_button 'Save'

  enabled_plugin_ids = @site.enabled_plugins.collect(&:plugin_id)
  enabled_plugin_ids.count.should == 1
  enabled_plugin_ids.should include(plugin_id)
end
