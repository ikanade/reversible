require 'spec_helper'

describe "reversible application" do

  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end

  it "should reverse unicode string 'l’issue'" do 
  	get '/reverse', input: "l’issue"
  	result = JSON.parse(last_response.body)["output"]
  	expect(result).to eq("eussi’l")
  end

  it "should reverse unicode string 'händ eussi’l'" do 
  	get '/reverse', input: "händ eussi’l"
  	result = JSON.parse(last_response.body)["output"]
  	expect(result).to eq("l’issue dnäh")
  end

  it "should reverse the string 'ishan'" do 
  	get '/reverse', input: "ishan"
  	result = JSON.parse(last_response.body)["output"]
  	expect(result).to eq("nahsi")
  end

  it "should respond with unprocessable entity error for missing input" do 
  	get '/reverse'
  	expect(last_response.status).to be(422)
  end

end