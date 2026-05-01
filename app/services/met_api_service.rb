require "net/http"
require "json"
require "openssl"

class MetApiService
  BASE_URL = "https://collectionapi.metmuseum.org/public/collection/v1"

  def search(query: nil, department_id: nil)
    params = { hasImages: true }
    params[:q] = query.presence || "painting"
    params[:departmentId] = department_id if department_id.present?

    response = get("#{BASE_URL}/search", params)

    Rails.logger.debug "=== Met API search response: #{response&.slice("total", "objectIDs")&.inspect}"

    return [] unless response && response["objectIDs"]
    response["objectIDs"].first(6)
  end

  def find(id)
    data = get("#{BASE_URL}/objects/#{id}")
    return nil unless data
    Artwork.new(data)
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