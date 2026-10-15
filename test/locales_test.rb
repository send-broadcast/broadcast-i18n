require 'minitest/autorun'
require 'yaml'
require 'broadcast_i18n'

# The language picker in Broadcast offers BroadcastI18n::LOCALES, and Rails loads
# every file in locales/. The two have to agree: a file nobody can pick is dead
# weight, and a language listed without a file shows English under its name.
# Every language has one file for each English file in FILES.
class LocalesTest < Minitest::Test
  # [name, locale] for "admin.pt-BR.yml"
  def split(file) = File.basename(file, '.yml').split('.', 2)

  def file_locales(name)
    BroadcastI18n.locale_files.map { |file| split(file) }.select { |file_name, _| file_name == name }.map(&:last)
  end

  def test_every_listed_language_has_a_file
    BroadcastI18n::FILES.each do |name|
      missing = BroadcastI18n::LOCALES.keys - file_locales(name)
      assert_empty missing, "listed in LOCALES but no locales/#{name}.<code>.yml: #{missing.join(', ')}"
    end
  end

  def test_every_file_is_a_listed_language
    BroadcastI18n::FILES.each do |name|
      unlisted = file_locales(name) - BroadcastI18n::LOCALES.keys
      assert_empty unlisted, "locales/ has #{name} files not listed in LOCALES: #{unlisted.join(', ')}"
    end
  end

  def test_every_file_translates_a_reference
    unknown = BroadcastI18n.locale_files.map { |file| split(file).first }.uniq - BroadcastI18n::FILES
    assert_empty unknown, "locales/ has files for no English in FILES: #{unknown.join(', ')}"
    BroadcastI18n::FILES.each do |name|
      assert File.exist?(BroadcastI18n.reference_file(name)), "reference/#{name}.en.yml is missing"
    end
  end

  def test_each_file_is_for_the_language_in_its_name
    BroadcastI18n.locale_files.each do |file|
      locale = split(file).last
      assert_equal [ locale ], YAML.load_file(file).keys, "#{file} must have #{locale} as its only top-level key"
    end
  end

  def test_each_language_is_named_in_itself
    BroadcastI18n::LOCALES.each do |code, name|
      refute_empty name.to_s.strip, "#{code} needs its own name for the language picker"
    end
  end
end
