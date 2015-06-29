# Dependencies
Promise= require 'bluebird'
request= unless window? then require 'request' else require 'xhr'
moment= require 'moment'

util= require 'util'
querystring= require 'querystring'

# Private
format= 'YYYY-MM-DD'
zerofill= (total,name,days,stats=[])->
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

# Public
class NpmCount
  api:
    fetchPackages:
      'https://www.npmjs.com/profile/%s/packages?offset=%s'

    fetchDownloads:
      'https://api.npmjs.org/downloads/range/%s/%s'

    fetchDays:
      'https://api.npmjs.org/downloads/range/%s/npm'

  fetch: (owner,period='last-day')->
    @fetchPackages owner
    .then (names)=>
      @fetchDownloads names,period

  fetchPackages: (owner)->
    url= @api.fetchPackages

    new Promise (resolve,reject)=>
      names= []

      process.nextTick ->
        nextOffset 0
      nextOffset= (i)=>
        uri= util.format url,owner,i
        console.log uri if @debug
        request uri,(error,response)->
          return reject error if error

          if response?.body and response.body[0] is '{'
            result= JSON.parse response.body
            {items,hasMore}= result
            delete response.body

            names.push item.name for item in items
            return nextOffset i+1 if hasMore

          resolve names

  # Get downloads of range via Npm downloads api
  # Using bulk queries
  #
  # See: https://github.com/npm/download-counts
  fetchDownloads: (names=[],period='last-day')->
    names= names.split(',') if typeof names is 'string'
    period= '2012-10-22:'+moment.utc().format format if period is 'all'
    url= @api.fetchDownloads

    console.log url if @debug

    @fetchDays period
    .then (days)=>
      [start,...,end]= days
      packages= {}
      total= {}
      total.days= new Array(days.length)
      total.packages= {}

      new Promise (resolve,reject)=>
        step= 100

        # Avoid the "Error 756 Too long request string"
        process.nextTick ->
          nextOffset 0
        nextOffset= (i)=>
          bulkNames= names.slice i*step,i*step+step
          bulk= (querystring.escape name for name in bulkNames).join ','

          if bulk isnt ''
            uri= util.format url,period,bulk
            console.log uri if @debug
            request uri,(error,response)->
              return reject error if error

              body= response?.body or '{}'
              results= JSON.parse body
              delete response.body
              return reject results.error if results.error?

              if results.package
                tmp= {}
                tmp[results.package]= results
                results= tmp

              for name in bulk.split(',')
                stat= zerofill total,name,days,results[name]?.downloads
                packages[name]= stat

              nextOffset i+1
          else
            resolve {days,packages,total}

  fetchDays: (period='last-day')->
    period= '2012-10-22:'+moment.utc().format format if period is 'all'

    uri= util.format @api.fetchDays,period
    console.log uri if @debug
    new Promise (resolve,reject)->
      request uri,(error,response)->
        return reject error if error

        {error,start,end}= JSON.parse response.body
        return reject error if error?
        momentDay= moment start

        days= []
        while true
          days.push momentDay.format format

          break if momentDay.format(format) is end

          momentDay.add 1,'days'

        resolve days

module.exports= new NpmCount
module.exports.NpmCount= NpmCount