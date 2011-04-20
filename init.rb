require 'settings'

ActiveRecord::Base.class_eval do
  def self.has_settings
    class_eval do
      def settings
        ScopedSettings.for_target(self)
      end
      
      after_destroy { |user| user.settings.target_scoped.delete_all }
      
      named_scope :with_settings, :joins => "JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                                               settings.target_type = '#{self.base_class.name}')",
                                  :select => "DISTINCT #{self.table_name}.*" 

      named_scope :with_settings_for, lambda { |var| { :joins => "JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                                                                    settings.target_type = '#{self.base_class.name}') AND
                                                                                    settings.var = '#{var}'" } }
                                                               
      named_scope :without_settings, :joins => "LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                                                       settings.target_type = '#{self.base_class.name}')",
                                     :conditions => 'settings.id IS NULL'
                                     
      named_scope :without_settings_for, lambda { |var| { :joins => "LEFT JOIN settings ON (settings.target_id = #{self.table_name}.#{self.primary_key} AND
                                                                                            settings.target_type = '#{self.base_class.name}') AND
                                                                                            settings.var = '#{var}'",
                                                          :conditions => 'settings.id IS NULL' } }
    end
  end
end