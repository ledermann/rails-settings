class ScopedSettings < Settings
  def self.for_target(target)
    @target = target
    self
  end
  
  def self.target_id
    @target.id
  end
  
  def self.target_type
    @target.class.base_class.to_s
  end
end