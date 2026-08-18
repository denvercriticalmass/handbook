require "rails_helper"
require "capybara/rspec"

Rails.root.glob("spec/system/support/**/*.rb").sort_by(&:to_s).each { require it }

PHONE_VIEWPORT = [ 414, 896 ].freeze

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :cuprite
    page.current_window.resize_to(*PHONE_VIEWPORT)
  end
end
