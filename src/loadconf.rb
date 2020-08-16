require 'json'

def read 
    js = File.read '../conf/conf.json'
    dict = JSON.parse js
    return dict
end