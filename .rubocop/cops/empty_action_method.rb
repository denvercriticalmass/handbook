module RuboCop
  module Cop
    module Handbook
      # Rails renders a controller's template without an action method, so an
      # empty one carries no information.
      #
      #   # bad
      #   def show
      #   end
      #
      #   # good
      #   (no method at all)
      class EmptyActionMethod < Base
        MSG = "Delete this empty action. Rails renders the template without it."

        def on_def(node)
          add_offense(node) if node.body.nil? && controller?(node)
        end

        private

        def controller?(node)
          enclosing_class = node.each_ancestor(:class).first

          enclosing_class && enclosing_class.identifier.source.end_with?("Controller")
        end
      end
    end
  end
end
