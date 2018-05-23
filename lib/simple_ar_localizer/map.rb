module SimpleARLocalizer

  # Default mapping from inbound localisation data to I18n keys. These can be supplemented/overridden via the
  # <tt>Rails.application.config.ar_localization_rules</tt> configuration variable.
  DEFAULT_MAP = {

    # per-model stuff
    'name':          'activerecord.models.%{model}',
    'name/singular': 'activerecord.models.%{model}.one',
    'name/plural':   'activerecord.models.%{model}.other',
    'name/:key':     'activerecord.models.%{model}.%{key}',
    'errors/:error': 'activerecord.errors.models.%{model}.%{error}',

    # per-attribute stuff
    'attributes/:attr':      'activerecord.attributes.%{model}.%{attr}', # only specifying a name
    'attributes/:attr/name': 'activerecord.attributes.%{model}.%{attr}', # verbose specification
    'attributes/:attr/errors/:error': 'activerecord.errors.models.%{model}.attributes.%{attr}.%{error}'

  }

end
