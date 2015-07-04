# Dependencies
npmCount= require '../src'
_= require 'lodash'

names= require './fixtures/isaacs'

# Fixture
sum= (packages)->
  _.chain packages
  .pluck 'downloads'
  .flatten(true)
  .sum (pkg)-> pkg.downloads
  .value()

# Specs
describe 'total of download counts',->
  it 'of the last-day',(done)->
    npmCount.fetchDownloads names
    .then (packages)->
      total= sum packages

      expect(total).toBeGreaterThan 100000

      done()

  it 'of the last-week',(done)->
    npmCount.fetchDownloads names,'last-week'
    .then (packages)->
      total= sum packages
      
      expect(total).toBeGreaterThan 1000000

      done()

  it 'of the last-month',(done)->
    npmCount.fetchDownloads names,'last-month'
    .then (packages)->
      total= sum packages
      
      expect(total).toBeGreaterThan 10000000

      done()

  it 'of isaacs',(done)->
    npmCount.fetchDownloads names,'all'
    .then (packages)->
      total= sum packages

      expect(total).toBeGreaterThan 100000000

      done()
