# Dependencies
Promise= require 'bluebird'
request= unless window? then require 'request' else require 'xhr'
moment= require 'moment'

util= require 'util'
querystring= require 'querystring'

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
  getBulkURIs: (names,period='last-day',step=100)->
    url= @api.downloads
    names= names.split(',') if typeof names is 'string'
    if period is 'all'
      period= '2012-10-22:'+moment.utc().add(-1,'days').format @format

    page= Math.ceil names.length/step
    
    for i in [0...page]
      bulk= (names.slice i*step,i*step+step).join(',')
      safeBulk= querystring.escape bulk
      
      util.format url,period,safeBulk

  # Fetch the `start` and `end` from json
  # eg: () -> https://api.npmjs.org/downloads/range/last-day/npm
  getDayURI: (period='last-day')->
    url= @api.days
    if period is 'all'
      period= '2012-10-22:'+moment.utc().add(-1,'days').format @format
    
    util.format url,period

  # Fetch the jsons
  request: (uris)->
    uris= [uris] unless uris instanceof Array

    promises=
      for uri in uris
        do (uri)->
          new Promise (resolve,reject)->
            request uri,(error,response)->
              return reject error if error
              return reject JSON.parse(response.body).error if response.body.slice(0,9) is '{"error":'
              return resolve response.body

    Promise.all promises

  # Parse the jsons to names
  # eg:
  # [
  #   '{"items":[{name:"foo"},{name:"bar"}]}   ',
  #    undefined,
  #   '   {"items":[{name:"baz"}]}'
  # ]
  # -> ["foo","bar","baz"]
  getNames: (bodies)->
    names= []

    for body in bodies
      continue unless body?.trim
      continue if body[0] is '<'
      json= JSON.parse body
      names.push item.name for item in json.items

    names

  # Parse the jsons to downloads
  # eg:
  # ['{"foo":1}   ','   {"bar":2}',undefined,'{"baz":{"beep":3}}','<html>']
  # -> '{"foo":1,"bar":2,"baz":{"beep":3}}'
  flatten: (bodies,raw=no)->
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

    packages= JSON.parse jsons.join('').replace /\}\{/g,','
    unless raw
      delete packages.start
      delete packages.end
    packages

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

  calculate: (names,days,downloads)->
    packages= {}
    total=
      packages: {}
      days: []
    for name in names
      stat= @zerofill total,name,days,downloads[name]?.downloads
      packages[name]= stat

    {days,packages,total}

  zerofill: (total,name,days,stats=[])->
    downloads= []

    # Example:
    #   zerofill (
    #     ["2015-01-01","2015-01-02","2015-01-03"],
    #     [
    #        {day:"2015-01-03",downloads:1}
    #     ]
    #   )
    #   -> [0,0,1]
    for day,i in days
      count= 0
      for stat in stats
        break if stat.day > day

        if stat.day is day
          count= stat.downloads
          break

      downloads.push count

      total.days[i]?= 0
      total.days[i]+= count
      total.packages[name]?= 0
      total.packages[name]+= count

    downloads

module.exports.Utility= Utility
