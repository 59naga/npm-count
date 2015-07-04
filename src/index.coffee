# Dependencies
Utility= (require './utility').Utility

# Public
class NpmCount extends Utility
  fetch: (author,period='last-day')->
    @fetchPackages author
    .then (names)=>

      @fetchDays period
      .then (days)=>

        @fetchDownloads names,period

  fetchPackages: (author,flatten=yes)->
    uris= @getPackageURIs author,10

    @request uris
    .then (bodies)=>
      @getPackages bodies,flatten

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

module.exports= new NpmCount
module.exports.NpmCount= NpmCount
