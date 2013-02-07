class ScopedSettings < Settings

  @klasses = {}

  def self.for_target(target)
    @klasses[target] ||= self.dup.instance_eval do
      def name; "ScopedSettings"; end # Required by ActiveModel::Naming
      @target = target
      self
    end
  end
  
  def self.target_id
    @target.is_a?(Class) ? nil : @target.id
  end
  
  def self.target_type
    @target.is_a?(Class) ? @target.name : @target.class.base_class.to_s
  end
end