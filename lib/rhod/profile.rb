class Rhod::Profile < Hash
  @@profiles = {}

  def initialize(name, options={})
    # When creating new profiles, copy from the global default, incase it was customized.
    if @@profiles[:default]
      default = @@profiles[:default].dup
    else
      default = {}
    end

    default.each {|k,v| self[k] = v }

    options.each {|k,v| self[k] = v }

    # Syntax sugar: named .with_#{profile} methods on this class and the module
    @@profiles[name] = self

    self.class.__send__(:define_method, :"with_#{name}") do |*args, &block|
      Rhod::Command.execute(*args, @@profiles[name], &block)
    end

    Rhod.class.__send__(:define_method, :"with_#{name}") do |*args, &block|
      Rhod::Command.execute(*args, @@profiles[name], &block)
    end

    self
  end
end

Rhod::Profile.new(:default,
  retries: 0,
  backoffs: Rhod::Backoffs::Logarithmic.new(1.3),
  fallback: nil,
  pool: ConnectionPool.new(size: 1, timeout: 0) { nil },
  exceptions: [Exception, StandardError],
)