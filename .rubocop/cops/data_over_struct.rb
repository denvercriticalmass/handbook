module RuboCop
  module Cop
    module Handbook
      # Data is frozen, compares by value, and raises on an unknown member
      # where a Struct or a Hash returns nil. Struct earns its place only when
      # the value has to change in place.
      #
      #   # bad
      #   Season = Struct.new(:weekday, :gathers_at)
      #
      #   # good
      #   Season = Data.define(:weekday, :gathers_at)
      class DataOverStruct < Base
        MSG = "Use Data.define unless this has to mutate."

        # @!method struct_new?(node)
        def_node_matcher :struct_new?, <<~PATTERN
          (send (const {nil? cbase} :Struct) :new ...)
        PATTERN

        def on_send(node)
          return unless struct_new?(node)
          return if mutates_a_member?(node)

          add_offense(node)
        end

        private

          # A block that assigns to one of its own members is the case Struct
          # is still for, so leave it alone.
          def mutates_a_member?(node)
            block = node.block_node
            return false if block.nil?

            members = node.arguments.select(&:sym_type?).map(&:value)

            block.each_descendant(:send, :op_asgn, :or_asgn, :and_asgn).any? do
              members.include?(member_written_by(it))
            end
          end

          # `self.count = 1` is a send; `self.count += 1` is an op_asgn wrapping
          # one, so both shapes have to be checked.
          def member_written_by(node)
            if node.send_type?
              node.method_name.to_s.chomp("=").to_sym if node.assignment_method?
            else
              target = node.children.first
              target.method_name if target.respond_to?(:method_name)
            end
          end
      end
    end
  end
end
