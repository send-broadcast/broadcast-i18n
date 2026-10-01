require_relative 'lib/broadcast_i18n/version'

Gem::Specification.new do |spec|
  spec.name = 'broadcast-i18n'
  spec.version = BroadcastI18n::VERSION
  spec.authors = [ 'Broadcast' ]
  spec.summary = 'Translations of the Broadcast admin interface'
  spec.homepage = 'https://github.com/send-broadcast/broadcast-i18n'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.files = Dir['lib/**/*.rb', 'locales/*.yml', 'LICENSE', 'README.md']
  spec.require_paths = [ 'lib' ]
end
