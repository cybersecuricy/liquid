require 'time'
require 'date'

class String # :nodoc:
  def to_solid
    self
  end
end

class Symbol # :nodoc:
  def to_solid
    to_s
  end
end

class Array # :nodoc:
  def to_solid
    self
  end
end

class Hash # :nodoc:
  def to_solid
    self
  end
end

class Numeric # :nodoc:
  def to_solid
    self
  end
end

class Range # :nodoc:
  def to_solid
    self
  end
end

class Time # :nodoc:
  def to_solid
    self
  end
end

class DateTime < Date # :nodoc:
  def to_solid
    self
  end
end

class Date # :nodoc:
  def to_solid
    self
  end
end

class TrueClass
  def to_solid # :nodoc:
    self
  end
end

class FalseClass
  def to_solid # :nodoc:
    self
  end
end

class NilClass
  def to_solid # :nodoc:
    self
  end
end
