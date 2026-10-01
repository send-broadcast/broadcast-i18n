module BroadcastI18n
  # Adds the translations to the host application's I18n load path. The
  # reference English is not loaded: the application has its own, which is the
  # source of truth.
  class Railtie < Rails::Railtie
    initializer 'broadcast_i18n.load_path', before: 'i18n.railtie' do |app|
      app.config.i18n.load_path += BroadcastI18n.locale_files
    end
  end
end
