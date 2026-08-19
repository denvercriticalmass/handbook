# The body of a guide or cheat sheet is an ActionText::RichText row, so
# versioning the owner alone records title changes and nothing else.
Rails.application.config.to_prepare do
  ActionText::RichText.has_paper_trail on: %i[ create update destroy ]
end
