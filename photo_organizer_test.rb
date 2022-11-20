# frozen_string_literal: true

require 'minitest/autorun'
require_relative './photo_organizer'

describe 'PhotoOrganizer' do
  def subject(input)
    PhotoOrganizer.new(input).organize
  end

  def assert_argument_error(input, message)
    assert_raises(ArgumentError, message) { subject(input) }
  end

  it 'renames photos using city names keeping the extension' do
    assert_equal(subject('photo.jpeg, Krakow, 2013-09-05 14:08:15'), 'Krakow1.jpeg')
  end

  it 'orders photos taken in the same city by date' do
    input = <<~INPUT
      photo.jpg, Krakow, 2013-09-05 14:08:15
      myFriends.png, Krakow, 2013-09-05 14:07:13
    INPUT
    assert_equal(subject(input), "Krakow2.jpg\nKrakow1.png")
  end

  it 'assigns order with equal number of digits to photos taken in the same city' do
    input = <<~INPUT
      photo.jpg, Krakow, 2013-09-05 14:08:15
      myFriends.png, Krakow, 2013-09-05 14:07:13
      me.jpg, Krakow, 2013-09-06 15:40:22
      a.png, Krakow, 2016-02-13 13:33:50
      b.jpg, Krakow, 2016-01-02 15:12:22
      c.jpg, Krakow, 2016-01-02 14:34:30
      d.jpg, Krakow, 2016-01-02 15:15:01
      e.png, Krakow, 2016-01-02 09:49:09
      f.png, Krakow, 2016-01-02 10:55:32
      g.jpg, Krakow, 2016-02-29 22:13:11
      Mike.png, London, 2015-06-20 15:13:22
      BOB.jpg, London, 2015-08-05 00:02:03
    INPUT
    output_array = subject(input).split("\n")
    output_array.first(10).each { |photo| assert_match(/^Krakow\d{2}.(jpg|jpeg|png)$/, photo) }
    output_array.last(2).each { |photo| assert_match(/^London\d{1}.(jpg|jpeg|png)$/, photo) }
  end

  it 'returns photos in the same order as in the given string' do
    input = <<~INPUT
      myFriends.png, Krakow, 2013-09-05 14:07:13
      Mike.jpeg, London, 2015-06-20 15:13:22
      photo.jpg, Krakow, 2013-09-05 14:08:15
      BOB.jpg, London, 2015-08-05 00:02:03
    INPUT
    output = "Krakow1.png\nLondon1.jpeg\nKrakow2.jpg\nLondon2.jpg"
    assert_equal(subject(input), output)
  end

  describe 'validation' do
    it "accepts maximum #{PhotoOrganizer::MAX_NUM_OF_PHOTOS} photos" do
      input = (PhotoOrganizer::MAX_NUM_OF_PHOTOS + 1).times.map do |index|
        "photo#{index}.jpg, London, 2015-08-05 00:02:03"
      end.join("\n")

      assert_argument_error input, "Number of photos should be in 1-#{PhotoOrganizer::MAX_NUM_OF_PHOTOS} range."
    end

    it 'does not accept an empty input' do
      assert_argument_error '', "Number of photos should be in 1-#{PhotoOrganizer::MAX_NUM_OF_PHOTOS} range."
    end

    it 'accepts photos taken from years 2000 to 2020' do
      old_photo = 'photo.jpg, Krakow, 1999-09-05 14:08:15'
      assert_argument_error old_photo, "#{old_photo} is not a valid photo information format."

      newer_photo = 'photo.jpg, Krakow, 2021-09-05 14:08:15'
      assert_argument_error newer_photo, "#{newer_photo} is not a valid photo information format."
    end

    it 'accepts photos with maximum 20 characters in the name' do
      input = "#{'a' * 21}.jpg, Krakow, 2021-09-05 14:08:15"
      assert_argument_error input, "#{input} is not a valid photo information format."
    end

    it 'accepts city names with maximum of 20 characters' do
      input = "photo.jpg, K#{'a' * 20}, 2021-09-05 14:08:15"
      assert_argument_error input, "#{input} is not a valid photo information format."
    end

    it 'checks that the city name starts with a capital letter' do
      input = 'photo.jpg, krakow, 2021-09-05 14:08:15'
      assert_argument_error input, "#{input} is not a valid photo information format."
    end

    it 'accepts only jpg, jpeg and png photo extensions' do
      input = 'photo.gif, krakow, 2021-09-05 14:08:15'
      assert_argument_error input, "#{input} is not a valid photo information format."
    end
  end
end
