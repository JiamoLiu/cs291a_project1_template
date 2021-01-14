# frozen_string_literal: true

require 'json'
require 'jwt'
require 'pp'





def main(event:, context:)
  # You shouldn't need to use context, but its fields are explained here:
  # https://docs.aws.amazon.com/lambda/latest/dg/ruby-context.html
  #response(body: event, status: 200)
  jsonStr = event.to_json


  json = JSON.parse(jsonStr)
  puts '\n==================================\n'

  if (!(is_valid_path(get_path(json))))
    return response(status:404)
  end

  if (!is_valid_method(get_method(json), get_path(json)))
    return response(status:405)
  end

  if (!valid_token?(get_token(json),get_method(json),get_path(json)))
    return response(status:403)
  end



  if (!is_valid_media(get_media_type(json)))
    return response(status:415)
  end

  if (!valid_json?(get_body(json), get_method(json)))
    return response(status:422)
  end



  if (get_method(json) == 'POST')
    return response(body:{"token"=>generate_token()},status:201)
  end

  return response(status:200)
end

def valid_token?(token, method,path)
  auth_ep = {"GET" => "/"}

  if (!(auth_ep[method] == path))
    return true
  end



  JWT.decode(token)
  return true
  
rescue
    return false
end 

def valid_json?(json,method)
  if method == "GET"
    return true
  end

  JSON.parse(json)
  return true
  
  rescue 
    return false
end


def response(body:nil, status: 200)
  {
    body: body ? body.to_json + "\n" : '',
    statusCode: status
  }
end	

def is_valid_method(method, path)

  url_methods = { "GET" => "/", "POST" => "/token"}

  if (!(method == 'GET') &&  !(method =='POST'))
    return false
  end

  if (!(url_methods[method] == path))
    return false
  end
  return true
end

def is_valid_media(media)
  #puts media
  if (!(media == 'application/json'))
    return false
  end
  return true
end

def get_body(json)
  return json['body']
end


def get_method(json)
  return json['httpMethod']
end

def get_media_type(json)
  #puts json
  headers = json["headers"].transform_keys(&:downcase)
  #puts json["headers"]
  puts headers
  #puts headers['content-type']
  return headers['content-type']
end


def is_valid_path(path)
  #puts path
  #puts (!(path == '/'))
  #puts (!(path == '/token'))
  if (!(path == '/') && !(path == '/token'))
    return false
  end
  return true
end


def get_token(json)
  headers = json["headers"].transform_keys(&:downcase)
  return headers['authorization']
end

def generate_token()
  ENV['JWT_SECRET'] = "default secret"
  payload = {
    data: { user_id: 128 },
    exp: Time.now.to_i + 1,
    nbf: Time.now.to_i
  }
  token = JWT.encode payload, ENV['JWT_SECRET'], 'HS256'
  return token
end


def get_path(json)
  return json['path']
end



if $PROGRAM_NAME == __FILE__
  # If you run this file directly via `ruby function.rb` the following code
  # will execute. You can use the code below to help you test your functions
  # without needing to deploy first.
  ENV['JWT_SECRET'] = 'NOTASECRET'

  # Call /token
  PP.pp main(context: {}, event: {
               'body' => '{"name": "bboe"}',
               'headers' => { 'Content-Type' => 'application/json' },
               'httpMethod' => 'POST',
               'path' => '/token'
             })


  PP.pp main(context: {}, event: {
              'body' => '{"name": "bboe"}',
              'headers' => { 'Content-Type' => 'application/json' },
              'httpMethod' => 'POST',
              'path' => '/token'
            })

  PP.pp main(context: {}, event: {
              'body' => '{"name": "bboe"}',
              'headers' => { 'Content-Type' => 'application/json' },
              'httpMethod' => 'POST',
              'path' => '/abc'
            })

  PP.pp main(context: {}, event: {
              'body' => '{"name": "bboe"}',
              'headers' => { 'Content-Type' => 'application/json' },
              'httpMethod' => 'GET',
              'path' => '/token'
            })
  PP.pp main(context: {}, event: {
              'body' => '{"name": "bboe"}',
              'headers' => { 'Content-TyPe' => 'application/json' },
              'httpMethod' => 'GET',
              'path' => '/token'
            })
             

  PP.pp main(context: {}, event: {
              'body' => '{"name": "bboe"}',
              'headers' => { 'Content-Type' => 'applicationssss/json' },
              'httpMethod' => 'POST',
              'path' => '/token'
            })

  PP.pp main(context: {}, event: {
              'body' => '}',
              'headers' => { 'Content-Type' => 'application/json' },
              'httpMethod' => 'POST',
              'path' => '/token'
            })
  PP.pp main(context: {}, event: {
              'body' => '[\'a\', 1, \'b\']',
              'headers' => { 'Content-Type' => 'application/json' },
              'httpMethod' => 'POST',
              'path' => '/token'
            })

  # Generate a token
  payload = {
    data: { user_id: 128 },
    exp: Time.now.to_i + 1,
    nbf: Time.now.to_i
  }
  token = JWT.encode payload, ENV['JWT_SECRET'], 'HS256'
  # Call /
  PP.pp main(context: {}, event: {
               'headers' => { 'Authorization' => "Bearer #{token}",
                              'Content-Type' => 'application/json' },
               'httpMethod' => 'GET',
               'path' => '/'
             })
end
