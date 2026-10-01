require 'minitest/autorun'
require 'yaml'
require 'broadcast_i18n'

# The language picker in Broadcast offers BroadcastI18n::LOCALES, and Rails loads
# every file in locales/. The two have to agree: a file nobody can pick is dead
# weight, and a language listed without a file shows English under its name.
class LocalesTest < Minitest::Test
  def file_locales
    BroadcastI18n.locale_files.map { |file| File.basename(file, '.yml').delete_prefix('admin.') }
  end

  def test_every_listed_language_has_a_file
    missing = BroadcastI18n::LOCALES.keys - file_locales
    assert_empty missing, "listed in LOCALES but no locales/admin.<code>.yml: #{missing.join(', ')}"
  end

  def test_every_file_is_a_listed_language
    unlisted = file_locales - BroadcastI18n::LOCALES.keys
    assert_empty unlisted, "locales/ has files not listed in LOCALES: #{unlisted.join(', ')}"
  end

  def test_each_file_is_for_the_language_in_its_name
    BroadcastI18n.locale_files.each do |file|
      locale = File.basename(file, '.yml').delete_prefix('admin.')
      assert_equal [ locale ], YAML.load_file(file).keys, "#{file} must have #{locale} as its only top-level key"
    end
  end

  def test_each_language_is_named_in_itself
    BroadcastI18n::LOCALES.each do |code, name|
      refute_empty name.to_s.strip, "#{code} needs its own name for the language picker"
    end
  end
end
