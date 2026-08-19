require "rubocop"
require "rubocop/rspec/support"

Dir[File.expand_path("../.rubocop/cops/*.rb", __dir__)].sort.each { require it }
