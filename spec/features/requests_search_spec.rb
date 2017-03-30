require 'spec_helper'

feature "Requests Search", "" do
	fixtures :all
	scenario "Search by nickname", :js => true do
		request = Request.order(:created_at, :id).last
		opts={}
		sign_in_as_user(users(:tspmember), opts)
		visit travel_sponsorships_path
		# Use the event filter
		# fill_in 'q_user_nickname_or_event_name_or_user_profile_full_name_cont', :with => users(:luke).profile.full_name.split(" ").first.downcase
		# click_button "search"
		# Check the url to ensure that the form have been submitted
		current_url.should match /event_id_in/
		# If so, the request should be in the first page
		find(:xpath, "//table[contains(@class,'requests')]//tbody/tr/td[1]//a[text()='##{request.id}']").click
		page.should have_content "request"
		request.expenses.each do |e|
		  page.should have_content e.subject
		  page.should have_content e.description
		end
	end
end