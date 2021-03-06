# frozen-string-literal: true

module Mobility
=begin

Defines methods for a set of locales to access translated attributes in those
locales directly with a method call, using a suffix including the locale:

  article.title_pt_br

If no locales are passed as an option to the initializer,
+I18n.available_locales+ will be used by default.

@example
  class Post
    def title
      "title in #{Mobility.locale}"
    end
    include Mobility::LocaleAccessors.new("title", locales: [:en, :fr])
  end

  Mobility.locale = :en
  post = Post.new
  post.title
  #=> "title in en"
  post.title_fr
  #=> "title in fr"

=end
  class LocaleAccessors < Module
    # @param [String] One or more attributes
    # @param [Array<Symbol>] Locales
    def initialize(*attributes, locales: I18n.available_locales)
      warning_message = "locale passed as option to locale accessor will be ignored".freeze

      attributes.each do |attribute|
        locales.each do |locale|
          normalized_locale = Mobility.normalize_locale(locale)
          define_method "#{attribute}_#{normalized_locale}" do |**options|
            warn warning_message if options.delete(:locale)
            Mobility.with_locale(locale) { send(attribute, options) }
          end
          define_method "#{attribute}_#{normalized_locale}?" do |**options|
            warn warning_message if options.delete(:locale)
            Mobility.with_locale(locale) { send("#{attribute}?", options) }
          end
          define_method "#{attribute}_#{normalized_locale}=" do |value, **options|
            warn warning_message if options.delete(:locale)
            Mobility.with_locale(locale) { send("#{attribute}=", value, options) }
          end
        end
      end
    end
  end
end
