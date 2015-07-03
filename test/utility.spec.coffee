# Dependencies
Utility= (require '../src/utility').Utility
utility= new Utility

querystring= require 'querystring'

names= require './fixtures/isaacs'

# Specs
describe 'utility',->
  describe '.getPackageURIs',->
    it '59naga',->
      author= '59naga'

      uris= utility.getPackageURIs author

      expect(uris.length).toBe 10
      expect(uris[0]).toBe 'https://www.npmjs.com/profile/59naga/packages?offset=0'
      expect(uris[9]).toBe 'https://www.npmjs.com/profile/59naga/packages?offset=9'

  describe '.getBulkURIs',->
    it 'single',->
      queries= utility.getBulkURIs 'is_js','last-day'

      prefix= 'https://api.npmjs.org/downloads/range/last-day/'

      expect(queries.length).toBe 1
      expect(queries[0]).toBe prefix+querystring.escape 'is_js'

    it 'convert 174 names to bulk queries',->
      queries= utility.getBulkURIs names,'last-day'

      prefix= 'https://api.npmjs.org/downloads/range/last-day/'

      expect(names.length).toBe 174
      expect(queries.length).toBe 2
      for query,i in queries
        expect(query).toBe prefix+querystring.escape names.slice(i*100,i*100+100).join(',')

  describe '.request',->
    it 'http://example.com/',(done)->
      utility.request 'http://example.com/'
      .then (bodies)->

        expect(bodies.length).toBe 1
        expect(bodies[0]).toBeTruthy()
        done()

    it 'http://example.com/,http://example.com/',(done)->
      utility.request ['http://example.com/','http://example.com/']
      .then (bodies)->

        expect(bodies.length).toBe 2
        expect(bodies[0]).toBeTruthy()
        expect(bodies[1]).toBeTruthy()
        done()

  describe '.getNames',->
    it 'convert bodies to package names',->
      fixture= [
        '{"items":[{"name":"foo"},{"name":"bar"}]}   ',
         undefined,
        '   {"items":[{"name":"baz"}]}'
      ]

      string= utility.getNames fixture
      expect(string).toEqual ['foo','bar','baz']
  
  describe '.flatten',->
    it 'convert bodies to json',->
      fixture= [
        '{"foo":{}}   '
        '   {"bar":{}}'
        undefined
        '{"baz":{"beep":{}}}'
        '<html>'
      ]

      string= utility.flatten fixture
      expect(string).toEqual {'foo':{},'bar':{},'baz':{'beep':{}}}

    it 'single to key-values',->
      fixture= [
        '{"downloads":[{"day":"2015-07-02","downloads":46983}],"start":"2015-07-02","end":"2015-07-02","package":"browserify"}'
      ]

      string= utility.flatten fixture
      expect(string).toEqual {'browserify':{'downloads':[{'day':'2015-07-02','downloads':46983}],'start':'2015-07-02','end':'2015-07-02','package':'browserify'}}

  # TODO
  xdescribe '.getDays'
  xdescribe '.calculate'
  xdescribe '.zerofill'
