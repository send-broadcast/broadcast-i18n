require 'minitest/autorun'
require 'tmpdir'
require 'broadcast_i18n/check'

class CheckTest < Minitest::Test
  ENGLISH = {
    'greeting' => 'Hello %{name}',
    'intro_html' => 'Read the <strong>guide</strong> first',
    'items' => { 'one' => '%{count} item', 'other' => '%{count} items' },
    'save' => 'Save'
  }.freeze

  def check(translation, locale = 'fr')
    Dir.mktmpdir do |dir|
      reference = File.join(dir, 'admin.en.yml')
      file = File.join(dir, "admin.#{locale}.yml")
      File.write(reference, { 'en' => ENGLISH }.to_yaml)
      File.write(file, translation.is_a?(String) ? translation : { locale => translation }.to_yaml)
      BroadcastI18n::Check.new(reference: reference, file: file, locale: locale).run
    end
  end

  def test_a_faithful_translation_passes
    result = check('greeting' => 'Bonjour %{name}', 'intro_html' => 'Lisez d’abord le <strong>guide</strong>',
                   'items' => { 'one' => '%{count} élément', 'other' => '%{count} éléments' }, 'save' => 'Enregistrer')
    assert_empty result.errors
    assert_equal 100.0, result.coverage
  end

  def test_missing_keys_lower_coverage_but_do_not_fail
    result = check('save' => 'Enregistrer')
    assert_empty result.errors
    assert_equal %w[greeting intro_html items], result.missing.sort
    assert_equal 25.0, result.coverage
  end

  def test_a_key_english_does_not_have_fails
    assert_includes check('sav' => 'Enregistrer').errors.join, 'sav: not in the English reference'
  end

  def test_a_changed_interpolation_fails
    assert_includes check('greeting' => 'Bonjour %{nom}').errors.join, 'greeting: placeholders'
  end

  def test_a_changed_html_tag_fails
    assert_includes check('intro_html' => 'Lisez d’abord le <em>guide</em>').errors.join, 'intro_html: HTML tags'
  end

  def test_a_plural_needs_its_other_form
    assert_includes check('items' => { 'one' => '%{count} élément' }).errors.join, "items: plural needs 'other'"
  end

  def test_a_string_where_english_has_plurals_fails
    assert_includes check('items' => '%{count} éléments').errors.join, 'items: English has plural forms'
  end

  def test_a_blank_value_fails
    assert_includes check('save' => ' ').errors.join, 'save: blank'
  end

  def test_long_dashes_fail
    assert_includes check('save' => "Enregistrer \u2014 maintenant").errors.join, 'save: long dash'
    assert_includes check('save' => "de 5\u201310").errors.join, 'save: long dash'
    assert_includes check('save' => "Enregistrer &#{'m'}dash; maintenant").errors.join, 'save: long dash'
    assert_includes check('save' => 'de 5&#8211;10').errors.join, 'save: long dash'
  end

  def test_the_file_must_be_for_its_language
    assert_includes check({ 'de' => { 'save' => 'Speichern' } }.to_yaml).errors.join, "top-level key must be 'fr'"
  end

  def test_invalid_yaml_fails
    assert_includes check("fr:\n  save: \"unterminated\n").errors.join, 'YAML'
  end
end
