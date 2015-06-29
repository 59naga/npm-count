# Dependencies
npmCount= require '../src'
npmCount.debug = yes if process.env.DEBUG
moment= require 'moment'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 120000
packages= require './fixture'

# Specs
describe 'npmCount',->
  describe '.fetchDownloads',->
    it 'browserify',(done)->
      npmCount.fetchDownloads 'browserify','all'
      .then (count)->
        expect(count.packages.browserify[0]).toBe 40
        done()

    it 'browserify,glob',(done)->
      npmCount.fetchDownloads 'browserify,glob'
      .then (count)->
        expect(count.packages.browserify[0]).toBeGreaterThan 10000
        expect(count.packages.glob[0]).toBeGreaterThan 10000
        done()

    it 'browserify,glob,chokidar in last-week',(done)->
      npmCount.fetchDownloads ['browserify','glob','chokidar'],'last-week'
      .then (count)->
        expect(count.packages.browserify[0]).toBeGreaterThan -1
        expect(count.packages.glob[0]).toBeGreaterThan -1
        expect(count.packages.chokidar[0]).toBeGreaterThan -1
        done()

    it 'packages of substack',(done)->
      npmCount.fetchDownloads packages,'all'
      .then (count)->
        expect(Object.keys(count.packages).length).toBe 615
        expect(count.packages.browserify[0]).toBe 40
        done()

  describe '.fetchDays',(done)->
    it 'last-day',(done)->
      count= 1

      npmCount.fetchDays 'last-day'
      .then (days)->
        expect(days.length).toBe count

        done()

    it 'last-week',(done)->
      count= 7

      npmCount.fetchDays 'last-week'
      .then (days)->
        expect(days.length).toBe count

        done()

    it 'last-month',(done)->
      count= 30

      npmCount.fetchDays 'last-month'
      .then (days)->
        expect(days.length).toBe count
        
        done()

    it 'all',(done)->
      day= 60*60*24*1000
      count= Math.floor((moment.utc() - moment.utc('2012-10-22')) / day)

      npmCount.fetchDays 'all'
      .then (days)->
        expect(days.length).toBe count
        
        done()

  futureDescribe= unless window? then describe else xdescribe
  futureDescribe 'Node.js only',->
    describe 'fetch',->
      it 'Get the downloads of grand total',(done)->
        npmCount.fetch 'isaacs','all'
        .then (count)->
          expect(Object.keys(count.packages).length).toBeGreaterThan 20

          for name,days of count.packages
            expect(days.length).toBe count.days.length

          day= 60*60*24*1000
          dayCount= Math.floor((moment.utc() - moment.utc('2012-10-22')) / day)
          expect(count.days.length).toBe dayCount

          done()

      it 'Nowhere',(done)->
        npmCount.fetch 'Jane doe'
        .then (count)->
          expect(Object.keys(count.packages).length).toBe 0

          expect(count.packages).toEqual {}

          expect(count.days.length).toBe 1

          done()

    describe '.fetchPackages',->
      it '59naga',(done)->
        npmCount.fetchPackages '59naga'
        .then (packages)->
          expect(packages.length).toBeGreaterThan 20
          done()
