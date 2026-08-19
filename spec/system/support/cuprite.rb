require "capybara/cuprite"

Capybara.default_max_wait_time = 2
Capybara.disable_animation = true
Capybara.save_path = Rails.root.join("tmp/capybara")
