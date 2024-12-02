module ApplicationHelper
  def random_image
    images = ['social_1.jpg', 'social_2.jpg', 'social_3.jpg'] # List your image filenames
    image_tag images.sample, alt: 'Random Image', class: 'random-image'
  end
end
