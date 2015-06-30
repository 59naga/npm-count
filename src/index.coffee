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

  fetchPackages: (owner,flatten=yes)->
    url= @api.fetchPackages

    # 1000 packages. never seen 700 or more
    promises=
      for i in [0...10]
        do (i)->
          uri= util.format url,owner,i
          console.log uri if @debug
          new Promise (resolve,reject)->
            request uri,(error,response)->
              return reject error if error

              if response?.body and response.body[0] is '{'
                result= JSON.parse response.body

                # Tip: result has `.hasMore` if is continued

              resolve result

    Promise.all promises
    .then (results)->
      packages= []

      if flatten
        for result in results
          for item in result?.items or []
            packages.push item.name

      else
        for result in results
          for item in result?.items or []
            packages.push item

      packages

  # Get downloads of range via Npm downloads api
  # Using bulk queries
  #
  # See: https://github.com/npm/download-counts
  fetchDownloads: (names=[],period='last-day')->
    names= names.split(',') if typeof names is 'string'
    period= '2012-10-22:'+moment.utc().add(-1,'days').format format if period is 'all'
    url= @api.fetchDownloads

    console.log url if @debug

    @fetchDays period
    .then (days)=>
      [start,...,end]= days
      packages= {}
      total= {}
      total.days= new Array(days.length)
      total.packages= {}

      # Avoid the "Error 756 Too long request string"
      step= 100
      page= Math.ceil names.length/step
      pages=
        for i in [0...page]
          names.slice i*step,i*step+step

      promises=
        for names in pages
          do (names)=>
            new Promise (resolve,reject)=>
              uri= util.format url,period,querystring.escape names.join(',')
              console.log uri if @debug
              request uri,(error,response)->
                return reject error if error

                body= response?.body or '{}'
                result= JSON.parse body
                
                return reject result.error if result.error?

                # single -> multi
                # {packages:"name",downloads:[...]}
                # -> {name:{downloads:[...]}}
                if result.package
                  tmp= {}
                  tmp[result.package]= result
                  result= tmp

                for name in names
                  stat= zerofill total,name,days,result[name]?.downloads
                  packages[name]= stat

                resolve()

      Promise.all promises
      .then ->
        {days,packages,total}

  fetchDays: (period='last-day')->
    period= '2012-10-22:'+moment.utc().add(-1,'days').format format if period is 'all'

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

  last: (count)->
    count?.days?.slice?(-1)?[0]

module.exports= new NpmCount
module.exports.NpmCount= NpmCount