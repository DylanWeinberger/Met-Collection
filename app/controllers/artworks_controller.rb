class ArtworksController < ApplicationController
  

  def index
    load_artworks
  end

  def more
    load_artworks
    render partial: "artworks/artwork_card", collection: @artworks, as: :artwork, layout: false
  end

  def show
    @artwork = MetApiService.new.find(params[:id])
    redirect_to artworks_path, alert: "Artwork not found" unless @artwork
  end

  private

  def load_artworks
    @query         = params[:q]
    @department_id = params[:department_id]
    @api           = MetApiService.new
    object_ids     = @api.search(query: @query, department_id: @department_id, page: (params[:page] || 1).to_i, per_page: (params[:per_page] || 20).to_i)
    @artworks  = []
    object_ids.each do |id|
        this_art = @api.find(id)
        if this_art && this_art.image_url.present?
          @artworks << this_art
        end
        break if @artworks.count >= (params[:per_page] || 20).to_i
    end
  end
end
