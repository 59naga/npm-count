# Dependencies
Utility= (require './utility').Utility

# Public
class NpmCount extends Utility
  # TODO:
  #   "packages" descending order by download count
  #
  # eg:
  # npmCount.fetch('substack','all')
  # -> {
  #   "days": [
  #     "2015-06-23"
  #     (more days)...
  #   ],
  #   "packages": {
  #     "browserify": [
  #       54778
  #       ...
  #     ],
  #     (more packages)...
  #   },
  #   "total": {
  #     "days": [
  #       720375
  #       (more days total)...
  #     ],
  #     "packages": {
  #       "browserify": 54778,
  #       (more packages total)...
  #     }
  #     "lastDay":   {"packages":{...},"all":99999}
  #     "lastWeek":  {"packages":{...},"all":999999}
  #     "lastMonth": {"packages":{...},"all":9999999}
  #     "all":       {"packages":{...},"all":99999999}
  #   }
  #   handled as a population parameter If downloaded one or more in that day
  #   "average": {
  #     "days": [
  #       1200.625
  #       (more days average)...
  #     ],
  #     "lastDay":   {"packages":{...},"all":999.999}
  #     "lastWeek":  {"packages":{...},"all":9999.999}
  #     "lastMonth": {"packages":{...},"all":99999.999}
  #     "all":       {"packages":{...},"all":999999.999}
  #   }
  # }
  fetch: (author,period='last-day')->
    @fetchPackages author
    .then (names)=>

      @fetchDays period
      .then (days)=>

        @fetchDownloads names,period
        .then (downloads)=>
          
          @calculate names,days,downloads

  # TODO: flatten option(restore)
  fetchPackages: (author)->
    uris= @getPackageURIs author,10

    @request uris
    .then (bodies)=>
      @getNames bodies

  fetchDownloads: (names,period='last-day')->
    uris= @getBulkURIs names,period

    @request uris
    .then (bodies)=>
      @flatten bodies

  fetchDays: (period='last-day')->
    uri= @getDayURI period

    @request uri
    .then (bodies)=>
      {error,start,end}= JSON.parse bodies[0]
      throw error if error?

      @getDays start,end

  last: (count)->
    count?.days?.slice?(-1)?[0]
  
module.exports= new NpmCount
module.exports.NpmCount= NpmCount
