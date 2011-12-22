class ScopedSettings < Settings
  def self.for_target(target)
    @target = target
    self
  end
  
  def self.target_id
    @target.is_a?(Class) ? nil : @target.id
  end
  
  def self.target_type
    @target.is_a?(Class) ? @target.name : @target.class.base_class.to_s
  end
end