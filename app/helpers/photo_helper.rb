module PhotoHelper
  def resource_url(size = nil)
    size ? self.image.thumb(size).url : self.image.remote_url
  end

  def width
    self.image.width
  end

  def height
    self.image.height
  end
end
