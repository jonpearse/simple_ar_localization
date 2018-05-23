require 'simple_ar_localizer/version'
require 'simple_ar_localizer/map'
require 'simple_ar_localizer/localizer'

module SimpleARLocalizer

  # Convenience accessort to SimpleARLocalizer::Localizer::transform()
  def self.transform( model_name, language, l10n_data )

    Localizer.transform( model_name, language, l10n_data )

  end

end
