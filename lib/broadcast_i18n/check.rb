require 'yaml'

module BroadcastI18n
  # Checks one translation file against the English reference.
  #
  # Errors are things that would break the interface or read wrong: a key
  # English does not have, a placeholder that was renamed or dropped, HTML that
  # changed shape, a broken plural, a blank value, a long dash. A key that is
  # simply not translated yet is not an error: the application shows the
  # English until it is, so it only lowers the coverage figure.
  class Check
    Result = Struct.new(:errors, :missing, :coverage, keyword_init: true)

    PLACEHOLDER = /%\{(\w+)\}/
    TAG = %r{</?([a-z][a-z0-9]*)\b}i
    # The characters, and the HTML entities that render as them
    LONG_DASH = /[\u2013\u2014]|&[mn]dash;|&#821[12];|&#x201[34];/i
    PLURAL_KEYS = %w[zero one two few many other].freeze

    def initialize(reference:, file:, locale:)
      @reference = reference
      @file = file
      @locale = locale
    end

    def run
      english = load(@reference, 'en')
      errors = []
      translation = begin
        load(@file, @locale, errors)
      rescue Psych::Exception => e
        errors << "#{File.basename(@file)}: invalid YAML (#{e.message.lines.first.strip})"
        nil
      end
      return Result.new(errors:, missing: [], coverage: 0.0) unless translation

      compare(english, translation, [], errors)
      english_keys = leaf_keys(english)
      missing = english_keys - leaf_keys(translation)
      coverage = english_keys.empty? ? 100.0 : ((english_keys.size - missing.size) * 100.0 / english_keys.size).round(1)
      Result.new(errors:, missing:, coverage:)
    end

    private

    def load(path, locale, errors = nil)
      data = YAML.safe_load_file(path)
      unless data.is_a?(Hash) && data.keys == [ locale ]
        errors&.push("#{File.basename(path)}: top-level key must be '#{locale}'")
        return nil if errors
      end
      data[locale] || {}
    end

    def compare(english, translation, path, errors)
      translation.each do |key, value|
        key_path = (path + [ key ]).join('.')
        source = english[key]

        if source.nil?
          errors << "#{key_path}: not in the English reference"
        elsif plural?(source)
          compare_plural(source, value, key_path, errors)
        elsif source.is_a?(Hash)
          value.is_a?(Hash) ? compare(source, value, path + [ key ], errors) : errors << "#{key_path}: English has nested keys here"
        elsif value.is_a?(Hash)
          errors << "#{key_path}: English has a single string here"
        else
          compare_string(source.to_s, value.to_s, key_path, errors)
        end
      end
    end

    def compare_plural(source, value, key_path, errors)
      return errors << "#{key_path}: English has plural forms (one/other)" unless value.is_a?(Hash)
      return errors << "#{key_path}: plural needs 'other'" unless value.key?('other')

      value.each do |form, text|
        next errors << "#{key_path}.#{form}: not a plural form" unless PLURAL_KEYS.include?(form)

        compare_string(source[form] || source['other'], text.to_s, "#{key_path}.#{form}", errors, plural: true)
      end
    end

    def compare_string(source, text, key_path, errors, plural: false)
      return errors << "#{key_path}: blank" if text.strip.empty?

      errors << "#{key_path}: long dash (use a comma, a colon or parentheses)" if text.match?(LONG_DASH)

      expected = placeholders(source)
      actual = placeholders(text)
      # A plural form may leave out %{count} ("un élément") but nothing else
      expected -= [ 'count' ] if plural
      actual -= [ 'count' ] if plural
      errors << "#{key_path}: placeholders #{actual.inspect} should be #{expected.inspect}" unless expected == actual

      return unless key_path.split('.').last.end_with?('_html') || key_path.split('.')[-2].to_s.end_with?('_html')

      errors << "#{key_path}: HTML tags #{tags(text).inspect} should be #{tags(source).inspect}" unless tags(source) == tags(text)
    end

    def plural?(value) = value.is_a?(Hash) && value.key?('other') && (value.keys - PLURAL_KEYS).empty?

    def placeholders(text) = text.scan(PLACEHOLDER).flatten.uniq.sort

    def tags(text) = text.scan(TAG).flatten.map(&:downcase).sort

    def leaf_keys(hash, path = [])
      hash.flat_map do |key, value|
        if plural?(value) || !value.is_a?(Hash)
          [ (path + [ key ]).join('.') ]
        else
          leaf_keys(value, path + [ key ])
        end
      end
    end
  end
end
