require "rubocop"
require "rubocop/rspec/support"
require_relative "../../../../.rubocop/cops/empty_action_method"

RSpec.describe RuboCop::Cop::Handbook::EmptyActionMethod, :config do
  it "flags an empty action" do
    expect_offense(<<~RUBY)
      class GuidesController
        def show
        ^^^^^^^^ Delete this empty action. Rails renders the template without it.
        end
      end
    RUBY
  end

  it "leaves an action with a body alone" do
    expect_no_offenses(<<~RUBY)
      class GuidesController
        def show
          @guide = Guide.find(params[:id])
        end
      end
    RUBY
  end

  it "leaves an empty method outside a controller alone" do
    expect_no_offenses(<<~RUBY)
      module Publishable
        def noop
        end
      end
    RUBY
  end
end
