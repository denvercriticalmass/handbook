class History
  Entry = Data.define(:at, :change)

  def initialize(record)
    @record = record
  end

  def entries
    @entries ||= versions.sort_by(&:created_at).reverse.map { Entry.new(at: it.created_at, change: change_in(it)) }
  end

  private

    attr_reader :record

    def versions
      record.versions + (record.rich_text_body&.versions || [])
    end

    def change_in(version)
      return "Body" if version.item_type == "ActionText::RichText"
      return "Created" if version.event == "create"

      version.changeset.keys.excluding("updated_at").map(&:humanize).to_sentence
    end
end
