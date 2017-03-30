require 'spec_helper'

feature "Requests Search", "" do
	fixtures :all
	scenario "Search by nickname", :js => true do
		sign_in_as_user(users(:luke))
	    visit event_path(events(:dagobah_camp))
	    click_link "Travel support"

	    # Request creation
	    page.should have_content "New travel support request"
	    fill_in "travel_sponsorship_description", :with => "I need to go because a ghost told me to do it"
	    select "Gas", :from => "travel_sponsorship_expenses_attributes_0_subject"
	    fill_in "travel_sponsorship_expenses_attributes_0_description", :with => "Gas"
	    fill_in "travel_sponsorship_expenses_attributes_0_estimated_amount", :with => "100"
	    select "EUR", :from => "travel_sponsorship_expenses_attributes_0_estimated_currency"
	    click_link "add expense"
	    within(:xpath, "//tr[@class='nested-fields'][last()]") do
	      find('select[name$="[subject]"]').set "Droid rental"
	      find('input[name$="[description]"]').set "R2D2"
	      #find('input[name$="[estimated_amount]"]').set "50"
	      #find('input[name$="[estimated_currency]"]').set "EUR"
	    end
	    click_button "Create travel support request"
	    page.should have_content "request was successfully created"
	    page.should have_content "then submit the request using the 'Action' button"
		request = Request.order(:created_at, :id).last
		opts={}
		click_link "Log out"
		sign_in_as_user(users(:tspmember), opts)
		visit travel_sponsorships_path
		# Use the event filter
		fill_in 'q_user_nickname_or_event_name_or_user_profile_full_name_cont', :with => users(:luke).profile.full_name.split(" ").first.downcase
		click_button "search"
		# # Check the url to ensure that the form have been submitted
		current_url.should match /event_id_in/
		puts page
		puts page.inspect
		# If so, the request should be in the first page
		find(:xpath, "//table[contains(@class,'requests')]//tbody/tr/td[1]//a[text()='##{request.id}']").click
		page.should have_content "request"
		request.expenses.each do |e|
		  page.should have_content e.subject
		  page.should have_content e.description
		end
	end
end