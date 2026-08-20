# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@github/webauthn-json", to: "webauthn-json.js" # @2.1.1
# Relative imports inside a multi-file vendored package resolve against the
# importer's own digested URL and 404, so every internal file is pinned and
# every intra-package import is a bare specifier rather than a relative path.
pin "tom-select", to: "tom-select-core.js" # @2.6.2
pin "tom-select/plugins/remove_button", to: "tom-select-remove-button.js" # @2.6.2
pin "tom-select-microevent", to: "tom-select-microevent.js" # @2.6.2
pin "tom-select-microplugin", to: "tom-select-microplugin.js" # @2.6.2
pin "tom-select-highlight", to: "tom-select-highlight.js" # @2.6.2
pin "tom-select-constants", to: "tom-select-constants.js" # @2.6.2
pin "tom-select-get-settings", to: "tom-select-get-settings.js" # @2.6.2
pin "tom-select-utils", to: "tom-select-utils.js" # @2.6.2
pin "tom-select-vanilla", to: "tom-select-vanilla.js" # @2.6.2
pin "tom-select-defaults", to: "tom-select-defaults.js" # @2.6.2
pin "@orchidjs/sifter", to: "orchidjs-sifter.js" # @1.1.0
pin "@orchidjs/unicode-variants", to: "orchidjs-unicode-variants.js" # @1.1.2
pin "orchidjs-sifter-utils", to: "orchidjs-sifter-utils.js" # @1.1.0
pin "orchidjs-uv-regex", to: "orchidjs-uv-regex.js" # @1.1.2
pin "orchidjs-uv-strings", to: "orchidjs-uv-strings.js" # @1.1.2
pin "orchidjs-sifter-types", to: "orchidjs-sifter-types.js" # @1.1.0
