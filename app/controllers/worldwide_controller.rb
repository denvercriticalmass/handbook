class WorldwideController < PublicController
  def show
    @continents = Continent.all
    @cloud = @continents.map { { continent: it.slug, cities: it.cities.map(&:name) } }
  end
end
