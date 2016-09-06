
class String
  # http://stackoverflow.com/a/29976927/190135
  def to_boolean
    ActiveRecord::Type::Boolean.new.type_cast_from_user(self)
  end
end

class NilClass
  def to_boolean
    false
  end
end

class TrueClass
  def to_boolean
    true
  end
end

class FalseClass
  def to_boolean
    false
  end
end
