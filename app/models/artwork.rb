class Artwork
  attr_reader :id, :title, :artist, :date, :medium,
              :department, :image_url, :thumbnail_url,
              :dimensions, :credit_line, :on_view
    def initialize(data = {})
        @id            = data["objectID"]
        @title         = data["title"]
        @artist        = data["artistDisplayName"].presence || "Unknown"
        @date          = data["objectDate"]
        @medium        = data["medium"]
        @department    = data["department"]
        @image_url     = data["primaryImage"]
        @thumbnail_url = data["primaryImageSmall"]
        @dimensions    = data["dimensions"]
        @credit_line   = data["creditLine"]
        @on_view       = data["isOnView"]
    end

    def has_image?
        image_url.present?
    end
end