require "rubocop"
require "rubocop/rspec/support"

# Every cop in .rubocop/cops, so adding one needs no wiring here. No Rails, so
# these run in a fraction of a second.
Dir[File.expand_path("../.rubocop/cops/*.rb", __dir__)].sort.each { require it }
