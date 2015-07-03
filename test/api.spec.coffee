# Dependencies
npmCount= require '../src'
moment= require 'moment'

names= require './fixtures/isaacs'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 15000

# Specs
describe 'npmCount',->
  describeFuture= unless window? then describe else xdescribe

  describeFuture '.fetch',->
    it '59naga',(done)->
      npmCount.fetch '59naga','all'
      .then (count)->

        expect(count)

        done()

  describeFuture '.fetchPackages',->
    it '59naga',(done)->
      npmCount.fetchPackages '59naga'
      .then (pkgs)->
        expect(pkgs.length).toBeGreaterThan 25
        done()

  describe '.fetchDownloads',->
    it 'isaacs\'s packages',(done)->
      npmCount.fetchDownloads names
      .then (count)->
        done()

    it 'single',(done)->
      npmCount.fetchDownloads 'is_js'
      .then (count)->
        done()

  describe '.fetchDays',->
    it 'all',(done)->
      npmCount.fetchDays 'all'
      .then (days)->
        day= 60*60*24*1000
        dayCount= Math.floor((moment.utc() - moment.utc('2012-10-22')) / day)

        expect(days.length).toBe dayCount
        done()

    it 'last-day',(done)->
      npmCount.fetchDays 'last-day'
      .then (days)->
        expect(days.length).toBe 1
        done()

    it 'last-week',(done)->
      npmCount.fetchDays 'last-week'
      .then (days)->
        expect(days.length).toBe 7
        done()

    it 'last-month',(done)->
      npmCount.fetchDays 'last-month'
      .then (days)->
        expect(days.length).toBe 30
        done()

  describe '.last',->
    it 'Compare to last-day of npm/download-counts',(done)->
      fixture=
        days: [
         '2012-10-22',
         '2015-06-23'
       ]

      npmCount.fetchDays()
      .then (days)->
        expect(days[0]).toBeGreaterThan npmCount.last fixture

        done()
    
    it 'Otherwise',->
      expect(npmCount.last null).toBe undefined
      expect(npmCount.last [null]).toBe undefined
      expect(npmCount.last {days:[]}).toBe undefined
      expect(npmCount.last {days:['foo','bar','baz']}).toBe 'baz'
