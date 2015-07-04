# Dependencies
calculator= require '../src/calculator'

fs= require 'fs'

# Fixtures
pkgs= require './fixtures/pkgs'
util= require './util'

# Specs
describe 'calculator',->
  normalized= calculator.normalize pkgs
  calculated= calculator.calculate pkgs

  grand= {}
  grand.total= util.grandTotal pkgs
  grand.average= grand.total / normalized.days.length

  describe '.normalize',->
    it 'zerofilled all packages',->
      {days,packages}= normalized

      for {name,stats} in packages
        expect(days.length).toBe stats.length
        expect(NaN).not.toBe (stats.reduce (a,b)-> a+b)

  describe '.calculate the packages of isaacs',->
    it 'total and average of all',->
      expect(grand.total).toBe calculated.total
      expect(grand.average).toBe calculated.average

    it 'total and average per period of all',->
      periods= [
        {periodName:'weekly',day:7}
        {periodName:'monthly',day:30}
        {periodName:'yearly',day:365}
      ]

      console.log '' if process.env.DEBUG

      for {periodName,day} in periods
        periodTotals=
          for period,periodIndex in calculated[periodName]
            if process.env.DEBUG
              console.log '%s: sum:%s avg:%s',
                (periodName+'('+period.start+':'+period.end+')'),period.total,period.average

            {start,end}= util.getIndex normalized,period
            for pkg in normalized.packages
              column= util.getColumn calculated,periodName,periodIndex,pkg.name

              expect(pkg.stats.slice start,end).toEqual column

            should= {}
            should.total= util.grandTotalNormalized normalized,start,end
            should.average= should.total / day

            expect(should.total).toBe period.total
            expect(should.average).toBe period.average

            period.total

        # sum of the total of period equal to the grand total
        total= periodTotals.reduce (a,b)-> a+b
        average= total / normalized.days.length
        expect(grand.total).toBe total
        expect(grand.average).toBe average

    it 'total and average per period of each package',->
      periods= [
        {periodName:'weekly',day:7}
        {periodName:'monthly',day:30}
        {periodName:'yearly',day:365}
      ]

      console.log '' if process.env.DEBUG

      for {periodName,day} in periods
        for period,periodIndex in calculated[periodName]
          {start,end}= util.getIndex normalized,period

          if process.env.DEBUG
            console.log '%s: sum:%s avg:%s',
              period.start+':'+period.end,period.total,period.average

          periodTotals=
            for pkg in normalized.packages
              if process.env.DEBUG
                console.log '%s/%s: sum:%s avg:%s',
                  (period.start+':'+period.end),pkg.name,period.total,period.average

              {column,total,average}= util.get calculated,periodName,periodIndex,pkg.name

              should= {}
              should.column= pkg.stats.slice start,end
              should.total= util.totalNormalized normalized,pkg.name,start,end
              should.average= should.total / day

              expect(should.column).toEqual column
              expect(util.commas should.total).toBe util.commas total
              expect(util.commas should.average).toBe util.commas average

              total

          # sum of the package's total of period equal to the grand total of period
          should= {}
          should.total= periodTotals.reduce (a,b)-> a+b
          should.average= should.total / day
          expect(util.commas should.total).toBe util.commas calculated[periodName][periodIndex].total
          expect(util.commas should.average).toBe util.commas calculated[periodName][periodIndex].average
