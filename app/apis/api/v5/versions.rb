module API
  class V5
    class Versions < Grape::API
      before do
        request_variant # may not be necessary
      end

      resource :versions do
        desc 'Version API', headers: API::Root::HEADERS
        params do
          OSS = Settings.app_version.s3.file.to_h.keys.map(&:to_s)
          requires :os, type: String, values: OSS
        end
        get do
          os = params[:os]

          settings = Settings.app_version.s3
          region   = settings.region
          bucket   = settings.bucket
          file     = settings.file[os]
          url      = "https://s3-#{region}.amazonaws.com/#{bucket}/#{file}"

          version = ENV["#{os.upcase}_VERSION"] || ::Faraday.get(url).body.chomp

          { meta: { code: 200, access_token: @access_token },
            data: { version: version } }
        end
      end
    end
  end
end
