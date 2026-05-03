class ArtworksController < ApplicationController
  def index
    @query         = params[:q]
    @department_id = params[:department_id]
    @api           = MetApiService.new
    object_ids     = @api.search(query: @query, department_id: @department_id, page: (params[:page] || 1).to_i, per_page: (params[:per_page] || 20).to_i)
    Rails.logger.debug "=== Object IDs returned: #{object_ids.inspect}"

    @artworks      = object_ids.map { |id| @api.find(id) }.compact
    Rails.logger.debug "=== Artworks loaded: #{@artworks.count}"

  end

  def show
    @artwork = MetApiService.new.find(params[:id])
    redirect_to artworks_path, alert: "Artwork not found" unless @artwork
  end
end
