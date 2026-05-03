require "net/http"
require "json"
require "openssl"

class MetApiService
  BASE_URL = "https://collectionapi.metmuseum.org/public/collection/v1"

  def search(query: nil, department_id: nil, page: 1, per_page: 20)
    params = { hasImages: true }
    params[:q] = query.presence || "painting"
    params[:departmentId] = department_id if department_id.present?
    Rails.cache.fetch("met-api/search/#{params[:q]}/#{params[:departmentId]}/#{page}", expires_in: 24.hours) do
      response = get("#{BASE_URL}/search", params)
      offset = (page - 1) * per_page
      response&.dig("objectIDs")&.drop(offset)&.first(per_page) || []
    end
  end

  def find(id)
    Rails.cache.fetch("met-api/objects/#{id}", expires_in: 24.hours) do
      data = get("#{BASE_URL}/objects/#{id}")
      Artwork.new(data) if data
    end
  end

  private

  def get(url, params = {})
    uri       = URI(url)
    uri.query = URI.encode_www_form(params) if params.any?

    http          = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl  = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.cert_store = OpenSSL::X509::Store.new.tap do |store|
      store.set_default_paths
      store.add_file(Gem.find_files("rubygems/ssl_certs/*.pem").first.to_s) rescue nil
    end

    request  = Net::HTTP::Get.new(uri)
    response = http.request(request)

    return nil unless response.is_a?(Net::HTTPSuccess)
    JSON.parse(response.body)
  rescue => e
    Rails.logger.error "Met API error: #{e.message}"
    nil
  end
end