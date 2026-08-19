# The body of a guide or cheat sheet is an ActionText::RichText row, so
# versioning the owner alone records title changes and nothing else.
#
# The load hook fires once per process. A to_prepare block runs again on every
# reload, and paper_trail refuses a second has_paper_trail on a class the
# reloader never unloads.
ActiveSupport.on_load :action_text_rich_text do
  has_paper_trail on: %i[ create update destroy ]
end
