class Reversible < Sinatra::Base

  get '/'do 
    "Welcome to Reversible, now with a test suit. Yaay!"
  end

  get '/reverse' do 
    content_type :json
    request.body.rewind

    data = 
      if request.body.read.empty?
        if  request.params.present? && request.params["input"].present?
          { input: request.params["input"] }.with_indifferent_access
        end
      else
        request.body.rewind
        JSON.parse(request.body.read).with_indifferent_access
      end

    if data.present?
      result = {
        meta_info: {
          served_at: Time.now,
          served_by: "#{`hostname`}".chomp
        },
        output: "#{data[:input]}".mb_chars.reverse.to_s 
      }
      result.to_json
    else
      status = 422
    end 
  end

  error 422 do
    {"error": "Provide a valid Input string"}.to_json
  end

end
