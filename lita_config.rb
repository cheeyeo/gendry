require './handlers/nextbike.rb'

Lita.configure do |config|

  # Core
  config.robot.name = "Gendry"
  config.robot.alias = "#"
  config.robot.locale = :en
  config.robot.log_level = :info
  #config.robot.adapter = :shell
  config.robot.admins = ["U3NREU9U0", "U09ADE44V"]

  # Adapter
  config.robot.adapter = :slack
  config.adapters.slack.token = ""
  config.adapters.slack.link_names = true
  config.adapters.slack.parse = "full"
  config.adapters.slack.unfurl_links = false
  config.adapters.slack.unfurl_media = false

  # Redis & HTTP
  config.redis.host = ""
  config.redis.port = 6379
  config.http.port = 7777

  # Plugins
  
  # lita-dig
  config.handlers.dig.default_resolver = '8.8.8.8'

  # lita-ai
  config.handlers.ai.api_user = ''
  config.handlers.ai.api_key = '' 

end
