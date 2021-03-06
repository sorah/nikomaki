module PlaceNameAccessor
  def place_name
    self.place.try(:name)
  end

  def place_name=(o)
    self.place = Place.find_or_create_by(name: o) if o.present?

    o
  end
end
