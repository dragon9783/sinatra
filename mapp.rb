require 'erb'
require 'logger'
require 'nokogiri'
require 'time'
require 'sinatra'
require 'sinatra/base'

class WeixiApp < Sinatra::Base

    configure :production do
        
        set :environment, 'production'  
        set :port, 8881
        
        Logger.class_eval { alias :write :'<<' }
        logger = ::Logger.new("log/production.log",'weekly')
        use Rack::CommonLogger, logger
          
        Dir.mkdir('logs') unless File.exist?('logs')
        
#        $logger = Logger.new('log/common.log','weekly')
#        $logger.level = Logger::WARN
#        
#        # Spit stdout and stderr to a file during production
#        # in case something goes wrong
#        $stdout.reopen("log/production.log", "w")
#        $stdout.sync = true
#        $stderr.reopen($stdout)
    end
    
    configure :development do

#    enable :logging         
        Logger.class_eval { alias :write :'<<' }
        logger = ::Logger.new("log/development.log",'weekly')
        use Rack::CommonLogger, logger
#        $logger = Logger.new(STDOUT)
        set :bind, '0.0.0.0'
        set :port, 9494
#        set :app_file, 'mapp.rb'
        set :root, File.dirname(__FILE__)
    end
    
   
    
    not_found do
      'This is nowhere to be found'
    end
    
    error do
      'Sorry there was a nasty error - ' + env['sinatra.error'].name
    end
    
    use Rack::Session::Pool, :expire_after => 2592000
    
    get '/' do
        'this is application'
    end
    
    get '/file' do
        attachment 'sample.xml'
        send_file './sample.xml'
    end
    
    post '/' do
      logger.info "sdfe"
      data = { :to_name => 'to', :from_name => 'from', \
        :time => Time.now, :type => 'text', :content => "message" }
      status 200
      headers \
        "Content-Type" => "application/xml;charset=utf-8"
      soap_message = Nokogiri::XML(request.body.read)
      data[:from_name] = soap_message.xpath("//ToUserName").text
      data[:to_name] = soap_message.xpath("//FromUserName").text
      body erb :index, :locals => data
    end
    
    run! if app_file == $0
end