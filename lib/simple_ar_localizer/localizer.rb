require 'singleton'

module SimpleARLocalizer

  # Localizer provides a slightly easier way of hooking into the depths of Rails’ Internationalization functionality.
  #
  # By default, it allows you to specify the human name (with plurality), human attribute names, and any custom error messages
  # on both a per-model and per-attribute level via a simple hash… rather than having to worry about exactly where things
  # get nested in .YAML files.
  #
  # It takes a bit of explaining to start with, but should be way nicer in the long-run =)
  class Localizer
    include Singleton

    # Default map of inbound keys to outbound
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

    # Constructor logic. This should not be called directly.
    def initialize

      @custom_rules = {}

      # if we have a custom startup hook
      if defined?( Rails ) and Rails.application.config.respond_to?( :ar_localization_rules )

        @custom_rules = Rails.application.config.ar_localization_rules

      end

    end

    # Does the actual translation from the nicely-formatted hash, to a more Rails i18n-friendly one.
    #
    # === Parameters
    #
    # [model_name]  the model we’re specifying localisations for
    # [language]    the ISO-639 language code of the language we’re providing a localisation for
    # [L10n_data]   a hash containing localisation data for the model/language combination
    def self.transform( model_name, language, l10n_data )

      self.instance.send( :perform_translation, model_name, language, l10n_data )

    end

    protected

      # Callback from self.transform that actually does the work.
      #
      # === Parameters
      #
      # [model_name]  the model we’re specifying localisations for
      # [language]    the ISO-639 language code of the language we’re providing a localisation for
      # [L10n_data]   a hash containing localisation data for the model/language combination
      def perform_translation( model_name, language, l10n_data )

        # normalise the model name
        model_name = model_name.name.underscore.to_sym if model_name.is_a?( Class )

        # normalise the language, while we’re at it
        language = language.to_sym unless language.is_a?( Symbol )

        # compile our rules into a tree for easier matching
        @rules = DEFAULT_MAP.merge( @custom_rules ).deep_stringify_keys

        # parse everything
        parsed = deep_parse( l10n_data.deep_stringify_keys, { model: model_name })

        # squish it out to a hash
        hsh = {}
        parsed.each{ |k,v| deep_assign( hsh, k, v ) }

        # drop in the language and return
        retval = {}
        retval[language] = hsh
        retval

      end

      # Performs the grunt work of recursing through the inbound array and turning it into a hash where keys are the
      # dotted internationalization keys, and the values are the translated value for that key.
      #
      # === Parameters
      #
      # [data_in] the current level of the hash to parse
      # [replacements] a hash containing values of tokens that should be replaced when generating internationalization keys
      # [curr_path] the current path within the hash for use when looking up mapping values
      def deep_parse( data_in, replacements, curr_path = '' )

        # start a return value
        retval = {}

        # find some rules that match at this level
        local_paths = @rules.keys
        local_paths.select!{ |p| p.starts_with?( curr_path ) } unless curr_path.blank?

        # finally, strip off any trailing stuff so we only have the current stub, then sort them so wildcards go at the end
        local_paths = local_paths.map{ |p| p.gsub(curr_path, '').gsub(/\/(.*)/, '') }.uniq.sort.reverse

        # now, stash some replacements somewhere
        local_replacements = replacements.dup

        # start iterating through keys at this level
        data_in.each do |key, value|

          # search for candidates
          candidates = local_paths.select{ |p| ((p === key) or p.starts_with?( ':' )) }
          next if candidates.empty?
          matched_path = candidates.first

          # if we’ve matched a symbol
          local_replacements[matched_path[1..-1].to_sym] = key if matched_path.starts_with?( ':' )

          # if it’s a hash, recurse
          if value.is_a?( Hash )

            retval.merge!( deep_parse( value, local_replacements, "#{curr_path}#{matched_path}/" ))

          else

            # do some substitution + cast to an array (so we can do multiple at once)
            full_rule  = @rules["#{curr_path}#{matched_path}"]
            full_rule  = [ full_rule ] unless full_rule.is_a?( Array )

            # and then…
            full_rule.each do |r|

              # allow passing in more complex rules as hashes
              if r.is_a?( Hash )

                value = r['proc'].call( value )
                r = r['key']

              end

              # write it to the array
              retval[ r.gsub( /%\{(\w+)\}/ ){ |m| local_replacements[ $1.to_sym ] }] = value

            end

          end

        end

        # return the result
        retval

      end

      def deep_assign( hsh, key, data )

        # prepare for some recursion fun
        target = hsh
        path   = key.to_s.split( '.' ).map( &:to_sym )
        final  = path.pop

        # unravel stuff a bit
        path.each do |k|

          target[k] = {} unless target.key?( k )
          target = target[k]

        end

        # push the final data…
        target[final] = data

        # … + return
        hsh

      end

  end

end
