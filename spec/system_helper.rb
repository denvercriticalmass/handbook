require "rails_helper"
require "capybara/rspec"

Rails.root.glob("spec/system/support/**/*.rb").sort_by(&:to_s).each { require it }

PHONE_VIEWPORT = [ 414, 896 ].freeze

# A cold CI runner outlasts Ferrum's 10 second default. Dup because driven_by
# deletes from the hash.
CUPRITE_OPTIONS = {
  process_timeout: 30,
  browser_options: ENV["CI"] ? { "no-sandbox" => nil, "disable-dev-shm-usage" => nil } : {}
}.freeze

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :cuprite, screen_size: PHONE_VIEWPORT, options: CUPRITE_OPTIONS.dup
  end
end
