# Dependencies
Promise= require 'bluebird'
request= unless window? then require 'request' else require 'xhr'
moment= require 'moment'

util= require 'util'

# Public
class Utility
  format: 'YYYY-MM-DD'
  api:
    packages:
      'https://www.npmjs.com/profile/%s/packages?offset=%s'

    downloads:
      'https://api.npmjs.org/downloads/range/%s/%s'

    days:
      'https://api.npmjs.org/downloads/range/%s/npm'

  # 100 package info per 1 offset
  # max 1000 packages. never seen 700 or more
  # eg:
  # '59naga'
  # -> [
  #       'https://www.npmjs.com/profile/59naga/packages?offset=0',
  #       ...
  #       'https://www.npmjs.com/profile/59naga/packages?offset=9',
  #    ]
  getPackageURIs: (author,limit=10)->
    url= @api.packages

    for i in [0...limit]
      uri= util.format url,author,i
  
  # Avoid the "Error 756 Too long request string"
  # eg:
  #
  # 'a,b,c'
  # -> ['https://api.npmjs.org/downloads/range/last-day/a%2Cb%2Cc',]
  # ["abbrev",(...173 more)]
  # -> [
  #      'https://api.npmjs.org/downloads/range/last-day/abbrev%2C(more 99)',
  #      'https://api.npmjs.org/downloads/range/last-day/npm-registry-readme-trim%2C(more 73)',
  #    ]
  getBulkURIs: (names,period='last-day',step=30)->
    url= @api.downloads
    names= names.split(',') if typeof names is 'string'
    if period is 'all'
      period= '2012-10-22:'+moment.utc().add(-1,'days').format @format

    page= Math.ceil names.length/step
    
    for i in [0...page]
      bulk= (names.slice i*step,i*step+step).join(',')
      safeBulk= encodeURIComponent bulk
      
      util.format url,period,safeBulk

  # Fetch the `start` and `end` from json
  # eg: () -> https://api.npmjs.org/downloads/range/last-day/npm
  getDayURI: (period='last-day')->
    url= @api.days
    if period is 'all'
      period= '2012-10-22:'+moment.utc().add(-1,'days').format @format
    
    util.format url,period

  # Fetch the bodies
  request: (uris)->
    uris= [uris] unless uris instanceof Array

    promises=
      for uri in uris
        do (uri)->
          new Promise (resolve,reject)->
            request uri,{gzip:yes},(error,response)->
              return reject error if error
              return reject JSON.parse(response.body).error if response.body.slice(0,9) is '{"error":'
              return resolve response.body

    Promise.all promises

  # Parse the bodies to names
  # eg:
  # utility.getPackages([
  #   '{"items":[{name:"foo"},{name:"bar"}]}   ',
  #    undefined,
  #   '   {"items":[{name:"baz"}]}'
  #   '<html>'
  # ])
  # -> ["foo","bar","baz"]
  getPackages: (bodies,flatten=yes)->
    packages= []

    for body in bodies
      continue unless body?.trim
      continue if body[0] is '<'

      json= JSON.parse body
      for item in json.items
        if flatten
          packages.push item.name
        else
          packages.push item

    packages

  # Parse the bodies to downloads
  # eg:
  # ['{"foo":1}   ','   {"bar":2}',undefined,'{"baz":{"beep":3}}','<html>']
  # -> '{"foo":1,"bar":2,"baz":{"beep":3}}'
  flatten: (bodies)->
    jsons= []

    for body in bodies
      continue unless body?.trim
      continue if body[0] is '<'
      json= body.trim()

      # Single to key-values
      # eg:
      # {"downloads":[{"day":"2015-07-02","downloads":46983}],"start":"2015-07-02","end":"2015-07-02","package":"browserify"}
      # -> {"browserify":{"downloads":[{"day":"2015-07-02","downloads":46983}],"start":"2015-07-02","end":"2015-07-02","package":"browserify"}}
      unless json.slice(-2) is '}}'
        object= JSON.parse json
        
        tmp= {}
        tmp[object.package]= object
        json= JSON.stringify tmp

      jsons.push json

    JSON.parse jsons.join('').replace /\}\{/g,','

  # eg:
  # '2012-10-22','2015-07-03'
  # -> ['2012-10-22',(...982 days),'2015-07-03']
  getDays: (start,end)->
    throw new Error 'Invalid arguments' if start>end
    days= []
    
    momentDay= moment start
    while true
      days.push momentDay.format @format

      break if momentDay.format(@format) is end

      momentDay.add 1,'days'

    days
  
module.exports.Utility= Utility
