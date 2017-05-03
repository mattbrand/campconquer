class Timespan < Range
  def initialize(min, max)
    super(min.to_date, max.to_date, true)
  end

  def weekdays
    self.select {|day| day.weekday?}
  end
end
