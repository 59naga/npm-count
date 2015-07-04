# Dependencies
Utility= (require '../src/utility').Utility
utility= new Utility

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
      expect(queries[0]).toBe prefix+encodeURIComponent 'is_js'

    it 'convert 174 names to bulk queries',->
      queries= utility.getBulkURIs names,'last-day'

      prefix= 'https://api.npmjs.org/downloads/range/last-day/'

      expect(names.length).toBe 174
      expect(queries.length).toBe 2
      for query,i in queries
        expect(query).toBe prefix+encodeURIComponent names.slice(i*100,i*100+100).join(',')

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

  describe '.getPackages',->
    fixture= [
      '{"items":[{"name":"foo"},{"name":"bar"}]}   ',
       undefined,
      '   {"items":[{"name":"baz"}]}'
      '<html>'
    ]

    it 'convert bodies to package names',->
      names= utility.getPackages fixture
      expect(names).toEqual ['foo','bar','baz']

    it 'convert bodies to packages',->
      packages= utility.getPackages fixture,false
      expect(packages).toEqual [{name:'foo'},{name:'bar'},{name:'baz'}]
  
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

  describe '.getDays',->
    it 'one day',->
      days= utility.getDays '2016-02-29','2016-02-29'

      expect(days.length).toBe 1
      expect(days[0]).toBe '2016-02-29'

    it '7 days',->
      days= utility.getDays '2016-02-29','2016-03-06'

      expect(days.length).toBe 7
      expect(days[0]).toBe '2016-02-29'
      expect(days[1]).toBe '2016-03-01'
      expect(days[2]).toBe '2016-03-02'
      expect(days[3]).toBe '2016-03-03'
      expect(days[4]).toBe '2016-03-04'
      expect(days[5]).toBe '2016-03-05'
      expect(days[6]).toBe '2016-03-06'

    it '30 days',->
      days= utility.getDays '2016-02-29','2016-03-29'

      expect(days.length).toBe 30
      expect(days[ 0]).toBe '2016-02-29'
      expect(days[ 1]).toBe '2016-03-01'
      expect(days[ 2]).toBe '2016-03-02'
      expect(days[ 3]).toBe '2016-03-03'
      expect(days[ 4]).toBe '2016-03-04'
      expect(days[ 5]).toBe '2016-03-05'
      expect(days[ 6]).toBe '2016-03-06'
      expect(days[ 7]).toBe '2016-03-07'
      expect(days[ 8]).toBe '2016-03-08'
      expect(days[ 9]).toBe '2016-03-09'
      expect(days[10]).toBe '2016-03-10'
      expect(days[11]).toBe '2016-03-11'
      expect(days[12]).toBe '2016-03-12'
      expect(days[13]).toBe '2016-03-13'
      expect(days[14]).toBe '2016-03-14'
      expect(days[15]).toBe '2016-03-15'
      expect(days[16]).toBe '2016-03-16'
      expect(days[17]).toBe '2016-03-17'
      expect(days[18]).toBe '2016-03-18'
      expect(days[19]).toBe '2016-03-19'
      expect(days[20]).toBe '2016-03-20'
      expect(days[21]).toBe '2016-03-21'
      expect(days[22]).toBe '2016-03-22'
      expect(days[23]).toBe '2016-03-23'
      expect(days[24]).toBe '2016-03-24'
      expect(days[25]).toBe '2016-03-25'
      expect(days[26]).toBe '2016-03-26'
      expect(days[27]).toBe '2016-03-27'
      expect(days[28]).toBe '2016-03-28'
      expect(days[29]).toBe '2016-03-29'

      expect(days.length).toBe 30

    it 'invalid',->
      expect(-> utility.getDays '2016-03-01','2016-02-29').toThrow()
