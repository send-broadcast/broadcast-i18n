require_relative 'broadcast_i18n/version'

# Translations of the Broadcast admin interface.
#
# English is written in the Broadcast application itself, next to the code that
# uses it. reference/<file>.en.yml is a copy of it, published here so that
# translators can see what every key says. The translations live in locales/,
# one <file>.<language>.yml for each file in FILES.
module BroadcastI18n
  # Languages translated here, with their own names (for the language picker)
  LOCALES = {
    'it' => 'Italiano',
    'fr' => 'Français',
    'de' => 'Deutsch',
    'es' => 'Español',
    'pt-BR' => 'Português (Brasil)',
    'nl' => 'Nederlands',
    'pl' => 'Polski',
    'sv' => 'Svenska',
    'da' => 'Dansk',
    'nb' => 'Norsk bokmål',
    'fi' => 'Suomi'
  }.freeze

  # The English files translated here: admin (the interface) and activerecord
  # (field names and validation messages of the application's own models)
  FILES = %w[admin activerecord].freeze

  def self.root = File.expand_path('..', __dir__)

  def self.locale_files = Dir[File.join(root, 'locales', '*.yml')].sort

  def self.locale_file(locale, file = 'admin') = File.join(root, 'locales', "#{file}.#{locale}.yml")

  def self.reference_file(file = 'admin') = File.join(root, 'reference', "#{file}.en.yml")
end

require_relative 'broadcast_i18n/railtie' if defined?(Rails::Railtie)
