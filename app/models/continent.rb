Continent = Data.define(:name, :cities) do
  def self.all
    YAML.load_file(Rails.root.join("config/world_rides.yml")).map do |name, cities|
      new(name:, cities: cities.map { |city, url| City.new(name: city, url:) })
    end
  end

  def slug
    name.parameterize
  end

  def linked_cities
    cities.select(&:url)
  end
end
