require 'bundler/setup'

Bundler.require(:default, :test, :development)

require 'active_support/all'

class App < Sinatra::Base

  get '/'do 
    "Welcome to the reversible."
  end

  get '/reverse' do 
    request.body.rewind
    content_type :json
    data = JSON.parse(request.body.read).with_indifferent_access
  
    result = {
      meta_info: {
        served_at: Time.now,
        served_by: "#{`hostname`}".chomp
      },
      output: "#{data[:input]}".mb_chars.reverse.to_s 
    }
  
    result.to_json
  end
end