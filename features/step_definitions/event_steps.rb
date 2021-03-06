Then(/^the event is set to end sometime$/) do
  expect(page).to have_select('event_repeat_ends_string', selected: 'on')
end

Given(/^I am on ([^"]*) index page$/) do |page|
  case page.downcase
    when 'events'
      visit events_path
    when 'projects'
      visit projects_path
  end
end


Given(/^I click on the event body for the event named "(.*?)"$/) do |name|
  e = Event.find_by(name: name)
  page.find(:css, "#details_#{e.id}").click
end

Given(/^following events exist:$/) do |table|
  table.hashes.each do |hash|
    Event.create!(hash)
  end
end

Given(/^following events exist for project "([^"]*)" with active hangouts:$/) do |project_title, table|
  project = Project.where(title: "#{project_title}").take

  table.hashes.each do |hash|
    event = Event.create!(hash)
    event.event_instances.create(hangout_url: 'x@x.com',
                                 updated_at: 1.minute.ago,
                                 category: event.category,
                                 title: event.name,
                                 project_id: project.id
    )

  end
end

Given(/^following hangouts exist:$/) do |table|
  table.hashes.each do |hash|
    EventInstance.create!(hash)
  end
end

Then(/^I should be on the Events "([^"]*)" page$/) do |page|
  case page.downcase
    when 'index'
      expect(current_path).to eq events_path

    when 'create'
      expect(current_path).to eq events_path
    else
      pending
  end
end

Then(/^I should see multiple "([^"]*)" events$/) do |event|
  #puts Time.now
  expect(page.all(:css, 'a', text: event, visible: false).count).to be > 1
end

When(/^the next event should be in:$/) do |table|
  table.rows.each do |period, interval|
    expect(page).to have_content([period, interval].join(' '))
  end
end

Given(/^I am on the show page for event "([^"]*)"$/) do |name|
  event = Event.find_by_name(name)
  visit event_path(event)
end

Then(/^I should be on the event "([^"]*)" page for "([^"]*)"$/) do |page, name|
  event = Event.find_by_name(name)
  page.downcase!
  case page
    when 'show'
      expect(current_path).to eq event_path(event)
    else
      expect(current_path).to eq eval("#{page}_event_path(event)")
  end
end

Given(/^the date is "([^"]*)"$/) do |jump_date|
  Delorean.time_travel_to(Time.parse(jump_date))
end

When(/^I follow "([^"]*)" for "([^"]*)" "([^"]*)"$/) do |linkid, table_name, hookup_number|
  links = page.all(:css, "table##{table_name} td##{linkid} a")
  link = links[hookup_number.to_i - 1]
  link.click
end


And(/^I click on the "([^"]*)" div$/) do |arg|
  find("div.#{arg}").click
end

And(/^I select "([^"]*)" from the project dropdown$/) do |project_name|
  page.select project_name, from: "Project"
end

And(/^the event named "([^"]*)" is associated with "([^"]*)"$/) do |event_name, project_title|
  event = Event.find_by(name: event_name)
  expect(event.project.title).to eq project_title
end