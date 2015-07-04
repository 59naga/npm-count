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

  # eg: TODO
  grandTotal: (packages)->
    _.chain packages
    .pluck 'downloads'
    .flatten(true)
    .sum (pkg)-> pkg.downloads
    .value()

  # eg: TODO
  grandTotalNormalized: (normalized,start,end)->
    pkgTotals=
      for pkg in normalized.packages
        (pkg.stats.slice start,end).reduce (a,b)-> a+b

    pkgTotals.reduce (a,b)-> a+b

  # eg: TODO
  total: (pkg)->
    _.chain pkgs
    .pluck 'downloads'
    .flatten(true)
    .sum (pkg)-> pkg.downloads
    .value()

  # eg:
  # totalNormalized({
  #   days: ['2015-01-01','2015-01-02','2015-01-03']
  #   packages: [
  #     {name: 'foo',stats: [0,0,1]},
  #   ]
  # },'foo',0,3)
  # ->
  # 1
  totalNormalized: (normalized,packageName,start,end)->
    pkg= _.find normalized.packages,(tmp)-> tmp.name is packageName

    (pkg.stats.slice start,end).reduce (a,b)-> a+b

  # eg:
  # "2015-06-27" -> 978
  # "2015-07-03" -> 984
  getIndex: (normalized,period)->
    start= normalized.days.indexOf period.start
    end= (normalized.days.indexOf period.end)+1

    {start,end}

  # eg: TODO
  getColumn: (calculated,periodName,periodIndex,packageName)->
    calculatedPackage= _.find calculated.packages,(pkg)-> pkg.name is packageName
    calculatedPackageColumn= calculatedPackage[periodName][periodIndex].column
    calculatedPackageColumn

  # eg: TODO
  get: (calculated,periodName,periodIndex,packageName)->
    calculatedPackage= _.find calculated.packages,(pkg)-> pkg.name is packageName
    calculatedPackagePeriod= calculatedPackage[periodName][periodIndex]
    calculatedPackagePeriod
