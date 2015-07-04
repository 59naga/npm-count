# Dependencies
npmCount= require '../src'
moment= require 'moment'

names= require './fixtures/59naga'

# Environment
jasmine.DEFAULT_TIMEOUT_INTERVAL= 15000

# Specs
describe 'npmCount',->
  describe '.fetchDownloads',->
    it 'browserify',(done)->
      npmCount.fetchDownloads 'browserify','all'
      .then (packages)->
        expect(packages.browserify.downloads[0].downloads).toBe 40
        done()

    it 'browserify,glob',(done)->
      npmCount.fetchDownloads 'browserify,glob'
      .then (packages)->
        expect(packages.browserify.downloads[0].downloads).toBeGreaterThan 10000
        expect(packages.glob.downloads[0].downloads).toBeGreaterThan 10000
        done()

    it '59naga\'s packages',(done)->
      npmCount.fetchDownloads names,'last-month'
      .then (downloads)->
        expect(downloads[name]).toBeTruthy() for name in names

        done()

    it 'single',(done)->
      npmCount.fetchDownloads 'is_js'
      .then (downloads)->
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

describe 'npmCount(nodejs)',->
  return if window?

  describe '.fetch',->
    it '59naga',(done)->
      npmCount.fetch '59naga','all'
      .then (downloads)->

        done()

  describe '.fetchPackages',->
    it '59naga',(done)->
      npmCount.fetchPackages '59naga'
      .then (pkgs)->
        expect(pkgs.length).toBeGreaterThan 25

        done()
