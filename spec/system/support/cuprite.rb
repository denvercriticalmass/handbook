require "capybara/cuprite"

sandboxless_chrome = { "no-sandbox" => nil, "disable-dev-shm-usage" => nil }

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    browser_options: ENV["CI"] ? sandboxless_chrome : {},
    process_timeout: 15,
    inspector: ENV["INSPECTOR"]
  )
end

Capybara.default_driver = :cuprite
Capybara.javascript_driver = :cuprite
Capybara.default_max_wait_time = 2
Capybara.disable_animation = true
Capybara.save_path = Rails.root.join("tmp/capybara")
