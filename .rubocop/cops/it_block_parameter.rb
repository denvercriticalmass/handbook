module RuboCop
  module Cop
    module Handbook
      # Prefer Ruby's implicit `it` over naming a block parameter when the
      # block body is one line. A name earns its keep once the body is long
      # enough that the reader loses sight of where the value came from.
      #
      #   # bad
      #   normalizes :email_address, with: ->(e) { e.strip.downcase }
      #
      #   # good
      #   normalizes :email_address, with: -> { it.strip.downcase }
      class ItBlockParameter < Base
        include RangeHelp
        extend AutoCorrector

        MSG = "Use the `it` block parameter."

        def on_block(node)
          return unless node.arguments.one?
          return unless node.first_argument.arg_type?
          return unless one_line_body?(node)
          return if nests_another_block?(node)

          references(node).each do |reference|
            add_offense(reference) do |corrector|
              corrector.remove(parameters_with_leading_space(node))
              corrector.replace(reference, "it")
            end
          end
        end

        private

        # Taking the space to the left leaves `{ it` and `do` tidy, where
        # taking it from the right would leave a double space or a dangling
        # space before the newline.
        def parameters_with_leading_space(node)
          range_with_surrounding_space(node.arguments.source_range, side: :left, newlines: false)
        end

        def one_line_body?(node)
          node.body && !node.body.begin_type? && node.body.single_line?
        end

        # An inner `it` would win over the outer one, so a body containing
        # another block keeps its named parameter.
        def nests_another_block?(node)
          node.body.block_type? ||
            node.body.numblock_type? ||
            node.body.itblock_type? ||
            node.body.each_descendant(:block, :numblock, :itblock).any?
        end

        def references(node)
          name = node.first_argument.source

          node.body.each_descendant(:lvar).select { it.source == name }
        end
      end
    end
  end
end
