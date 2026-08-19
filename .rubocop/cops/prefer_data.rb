module RuboCop
  module Cop
    module Handbook
      # Data is frozen, compares by value, and raises on an unknown member
      # where a Struct or a Hash returns nil.
      #
      #   # bad
      #   Season = Struct.new(:weekday, :gathers_at)
      #   WINTER = { weekday: :sunday, gathers_at: "1:30pm" }.freeze
      #
      #   # good
      #   Season = Data.define(:weekday, :gathers_at)
      #   WINTER = Season.new(weekday: :sunday, gathers_at: "1:30pm")
      #
      # A struct whose block assigns to its own members is left alone, and so is
      # a hash holding anything other than literals, which is usually an options
      # bag on its way to some other method rather than a value of its own.
      class PreferData < Base
        STRUCT_MSG = "Use Data.define unless this has to mutate."
        HASH_MSG = "Use Data.define for a record with named fields."
        LITERALS = %i[ sym str int float true false ].freeze

        # @!method struct_new?(node)
        def_node_matcher :struct_new?, <<~PATTERN
          (send (const {nil? cbase} :Struct) :new ...)
        PATTERN

        # @!method frozen_hash_constant(node)
        def_node_matcher :frozen_hash_constant, <<~PATTERN
          (casgn _ _ (send $(hash ...) :freeze))
        PATTERN

        def on_send(node)
          return unless struct_new?(node)
          return if mutates_a_member?(node)

          add_offense(node, message: STRUCT_MSG)
        end

        def on_casgn(node)
          hash = frozen_hash_constant(node)

          add_offense(hash, message: HASH_MSG) if hash && record?(hash)
        end

        private

          def record?(hash)
            hash.pairs.length > 1 &&
              hash.pairs.all? { it.key.sym_type? && LITERALS.include?(it.value.type) }
          end

          def mutates_a_member?(node)
            block = node.block_node
            return false if block.nil?

            members = node.arguments.select(&:sym_type?).map(&:value)

            block.each_descendant(:send, :op_asgn, :or_asgn, :and_asgn).any? do |call|
              members.include?(member_written_by(call))
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
