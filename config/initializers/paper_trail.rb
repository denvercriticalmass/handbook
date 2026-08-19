ActiveSupport.on_load :action_text_rich_text do
  has_paper_trail on: %i[ create update destroy ]
end
