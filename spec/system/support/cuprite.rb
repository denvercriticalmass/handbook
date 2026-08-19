require "capybara/cuprite"

# Only Capybara-level settings belong here. Rails re-registers the :cuprite
# driver itself inside driven_by, so any register_driver block for that name is
# silently discarded -- driver options go through driven_by in system_helper.
Capybara.default_max_wait_time = 2
Capybara.disable_animation = true
Capybara.save_path = Rails.root.join("tmp/capybara")
