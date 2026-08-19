class History
  Entry = Data.define(:at, :change, :by) do
    def summary
      by ? "#{change} by #{by}" : change
    end
  end

  def initialize(record)
    @record = record
  end

  def entries
    @entries ||= versions.sort_by(&:created_at).reverse.map do
      Entry.new(at: it.created_at, change: change_in(it), by: names[it.whodunnit])
    end
  end

  private

    attr_reader :record

    def versions
      @versions ||= record.versioned_records.flat_map(&:versions)
    end

    # Seeds and console edits leave no whodunnit, so a name can be missing.
    def names
      @names ||= User.where(id: versions.filter_map(&:whodunnit)).pluck(:id, :name).to_h
    end

    def change_in(version)
      return "Body" if version.item_type == "ActionText::RichText"
      return "Created" if version.event == "create"

      version.changeset.keys.excluding("updated_at").map(&:humanize).to_sentence
    end
end
