module Common
    # Make sure we are in dev mode unless explicitly disabled
    def production_mode?
        ENV['PRODUCTION_MODE'] == 'true' ? true : false
    end

    def resolve_user_name
        production_mode? ? self.user.id : 'U08U56D5K'
    end
end