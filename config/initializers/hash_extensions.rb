class Hash
  def grab *keys
    keys = keys.map(&:to_sym)
    with_indifferent_access.select { |key, value| keys.include?(key.to_sym) }
  end

  alias pick grab

  alias + merge

  alias << merge!

  # rails serialization is SO WEIRD
  def serializable_hash(options=nil)
    self.stringify_keys
  end

end
