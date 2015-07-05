# Dependencies
_= require 'lodash'

# Public
module.exports=
  commas: (number)->
    if process.env.DEBUG
      # Cite: http://stackoverflow.com/a/2901298/2969618
      new String(number).replace /\B(?=(\d{3})+(?!\d))/g,','
    else
      number

  # eg:
  # util.total ({
  #   foo: {
  #     start: "2015-01-01",
  #     end: "2015-01-03",
  #     downloads: [
  #        {day:"2015-01-03",downloads:1}
  #     ]
  #   }
  # })
  #
  # -> 1
  total: (packages)->
    _.chain packages
    .pluck 'downloads'
    .flatten(true)
    .sum (pkg)-> pkg.downloads
    .value()

  # eg:
  # grandTotalNormalized({
  #   days: ['2015-01-01','2015-01-02','2015-01-03']
  #   packages: [
  #     {name: 'foo',stats: [0,0,1]},
  #     {name: 'bar',stats: [0,2,0,3]},
  #     {name: 'baz',stats: [0,0,0,0,4]},
  #   ]
  # },0,3)
  # -> 3
  grandTotalNormalized: (normalized,start,end)->
    pkgTotals=
      for pkg in normalized.packages
        (pkg.stats.slice start,end).reduce (a,b)-> a+b

    pkgTotals.reduce (a,b)-> a+b

  # eg:
  # totalNormalized({
  #   days: ['2015-01-01','2015-01-02','2015-01-03']
  #   packages: [
  #     {name: 'foo',stats: [0,0,1]},
  #   ]
  # },'foo',0,3)
  # -> 1
  totalNormalized: (normalized,packageName,start,end)->
    pkg= _.find normalized.packages,(tmp)-> tmp.name is packageName

    (pkg.stats.slice start,end).reduce (a,b)-> a+b

  # eg:
  # totalNormalized({
  #   days: ['2015-01-01','2015-01-02','2015-01-03']
  #   packages: [
  #     {name: 'foo',stats: [0,0,1]},
  #   ]
  # },{start:"2015-06-27",end:"2015-07-03"}
  # -> {start:978,end:984}
  getIndex: (normalized,period)->
    start= normalized.days.indexOf period.start
    end= (normalized.days.indexOf period.end)+1

    {start,end}

  # eg:
  # get({
  #   packages: {
  #     foo: {
  #       weekly: [
  #         {start,end,total,average,column},
  #         ...,
  #       ]
  #     }
  #   }
  # },'weekly',0,'foo')
  # -> {start,end,total,average,column}
  get: (calculated,periodName,periodIndex,packageName)->
    calculatedPackage= _.find calculated.packages,(pkg)-> pkg.name is packageName
    calculatedPackage[periodName][periodIndex]
