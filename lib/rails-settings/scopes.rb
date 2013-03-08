module RailsSettings
  module Scopes
    def with_settings
      joins("INNER JOIN settings ON #{settings_join_condition}").
      uniq
    end

    def with_settings_for(var)
      raise ArgumentError.new('Symbol expected!') unless var.is_a?(Symbol)
      joins("INNER JOIN settings ON #{settings_join_condition} AND settings.var = '#{var}'")
    end

    def without_settings
      joins("LEFT JOIN settings ON #{settings_join_condition}").
      where('settings.id IS NULL')
    end

    def without_settings_for(var)
      raise ArgumentError.new('Symbol expected!') unless var.is_a?(Symbol)
      joins("LEFT JOIN settings ON  #{settings_join_condition} AND settings.var = '#{var}'").
      where('settings.id IS NULL')
    end

    def settings_join_condition
      "settings.target_id   = #{table_name}.#{primary_key} AND
       settings.target_type = '#{base_class.name}'"
    end
  end
end
