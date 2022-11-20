# frozen_string_literal: true

# Reorganizes photo collection
class PhotoOrganizer
  attr_accessor :collection

  MAX_NUM_OF_PHOTOS = 100
  PHOTO_FORMAT = /^([a-zA-Z]{1,20}).(jpg|jpeg|png), ([A-Z][a-z]{1,19}), (20([01]\d|20)-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01]) ([01]\d|2[0-4]|):([0-5]\d|60):([0-5]\d|60))$/.freeze

  # @param [String] collection
  # List of photos. Each line has the format: {name}.{extension}, {city_name}, yyyy-mm-dd hh:mm:ss
  def initialize(collection)
    @collection = collection
  end

  # @return [String] Reorganized list of photos
  # @raise [ArgumentError] If one of the photo formats is wrong
  def organize
    reorganized_collection = []
    grouped_photos.each do |city, photos|
      num_of_digits = Math.log10(photos.size).to_i + 1
      photos
        .sort_by { |photo| photo[:date] }
        .each_with_index do |photo, index|
        photo_index = (index + 1).to_s.rjust(num_of_digits, '0')
        reorganized_collection[photo[:initial_index]] = "#{city}#{photo_index}.#{photo[:extension]}"
      end
    end
    reorganized_collection.join("\n")
  end

  private

  # @return [Hash] Collection of photos grouped by city
  def grouped_photos
    grouped_collection = {}
    photos = collection.split("\n")
    unless photos.length.between?(1, MAX_NUM_OF_PHOTOS)
      raise ArgumentError, "Number of photos should be in 1-#{MAX_NUM_OF_PHOTOS} range."
    end

    photos.each_with_index do |photo_information, index|
      _name, extension, city, taken_at = parse_photo(photo_information)
      grouped_collection[city] ||= []
      grouped_collection[city] << { initial_index: index, date: taken_at, extension: extension }
    end
    grouped_collection
  end

  # @param [String] raw_photo Raw photo information
  # @return [Array<String>]
  def parse_photo(raw_photo)
    parsed_photo = raw_photo.match(PHOTO_FORMAT)
    raise ArgumentError, "#{raw_photo} is not a valid photo information format." if parsed_photo.nil?

    parsed_photo.to_a.slice(1, 4)
  end
end
