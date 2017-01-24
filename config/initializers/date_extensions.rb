class ::Date
  def weekend?
    saturday? or sunday?
  end
  def weekday?
    not weekend?
  end
end
