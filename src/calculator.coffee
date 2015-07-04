# coffeelint: disable=no_trailing_whitespace

# Dependencies
Utility= (require './utility').Utility

_= require 'lodash'

# Private
backSlice= (stats,i,volume,label=[])->
  if (-i+1) is 0
    [start,...,end]= label.slice -i*volume
    column= stats.slice -i*volume
  else
    [start,...,end]= label.slice(-i*volume,(-i+1)*volume)
    column= stats.slice(-i*volume,(-i+1)*volume)

  # console.log start,end,column.length

  {start,end,column}

# Public
class Calculator extends Utility
  periods: [
    {name:'weekly',days:7}
    {name:'monthly',days:30}
    {name:'yearly',days:365}
  ]

  # eg.
  # calc({
  #   "charm": {
  #     "downloads": [
  #       {
  #         "day": "2015-07-03",
  #         "downloads": 12168
  #       }
  #       # (more 984 days...)
  #     ],
  #     "start": "2015-07-03",
  #     "end": "2015-07-03",
  #     "package": "charm"
  #   },
  #   # (more 443 packages...)
  # })
  #
  # ->
  #
  # {
  #   "name": "2012-10-22:2015-07-03",
  #   "total": 1472449362,
  #   "average": 1494872.4487309644,
  #   "weekly": [
  #     {
  #       "start": "2015-06-27",
  #       "end": "2015-07-03",
  #       "total": 43061905,
  #       "average": 6151700.714285715,
  #       "column": [
  #         #(7 days...)
  #       ]
  #     },
  #     #{more 140 weeks...},
  #   ],
  #   "monthly": [
  #     {
  #       "start": "2015-06-04",
  #       "end": "2015-07-03",
  #       "total": 193759014,
  #       "average": 6458633.8,
  #       "column": [
  #         #(30 days...)
  #       ]
  #     }
  #     #(more months...)
  #   ],
  #   "yearly": [
  #     {
  #       "start": "2014-07-04",
  #       "end": "2015-07-03",
  #       "total": 1242984915,
  #       "average": 3405438.1232876712,
  #       "column": [
  #         #(365 days...)
  #       ]
  #     }
  #     #(more years...)
  #   ],
  #   "packages": [
  #     {
  #       "name": "abbrev",
  #       "total": 34287587,
  #       "average": 34809.732994923856,
  #       "weekly": [
  #         {
  #           "start": "2015-06-27",
  #           "end": "2015-07-03",
  #           "total": 932771,
  #           "average": 133253,
  #           "column": [
  #             #(7 days...)
  #           ]
  #         }
  #         #(more weeks...)
  #       ],
  #       "monthly": [
  #         {
  #           "start": "2015-06-04",
  #           "end": "2015-07-03",
  #           "total": 4426192,
  #           "average": 147539.73333333334,
  #           "column": [
  #             #(30 days...)
  #           ]
  #         }
  #         #(more months...)
  #       ],
  #       "yearly": [
  #         {
  #           "start": "2014-07-04",
  #           "end": "2015-07-03",
  #           "total": 26857890,
  #           "average": 73583.2602739726,
  #           "column": [
  #             #(365 days...)
  #           ]
  #         }
  #         #(more years...)
  #       ],
  #     },
  #     #(many many packages...)
  #   ],
  # }
  
  calculate: (pkgs,addLabel=no)->
    normalized= @normalize pkgs

    packages=
      for pkg,pkgI in normalized.packages
        periods=
          for period in @periods
            length= Math.ceil(pkg.stats.length / period.days)

            i= 1
            while i <= length
              {start,end,column}= backSlice pkg.stats,i++,period.days,normalized.days

              total= _.sum column,(stat)-> stat
              average= total/period.days

              column.unshift pkg.name if addLabel

              {start,end,total,average,column}

        total=
          _.chain pkg.stats
          .sum (stat)-> stat
          .value()
        average= total/pkg.stats.length
        # TODO division the total in current day from published(approximation) day

        # Expose
        pkg=
          {name:pkg.name,total,average}

        pkg[@periods[i].name]= period for period,i in periods
        pkg

    periods=
      for period in @periods
        for page,i in packages[0][period.name] or []
          {start,end}= page

          column=
            for cell,j in page.column
              packages.reduce (left,right)->
                left= left[period.name]?[i].column[j] ? left
                left + right[period.name]?[i].column[j]

          total= _.sum column,(stat)-> stat
          average= total/(period.days)

          column.unshift period.name if addLabel

          {start,end,total,average,column}

    total=
      _.chain normalized.packages
      .pluck 'stats'
      .flatten true
      .sum (stat)-> stat
      .value()
    average= total/(normalized.days.length)

    name= normalized.days.slice(0,1)+':'+normalized.days.slice(-1)

    calculated=
      {name,total,average}
    calculated[@periods[i].name]= period for period,i in periods
    calculated.packages= packages

    calculated

  # eg:
  #   npmCountCalc.normalize ({
  #     foo: {
  #       start: "2015-01-01",
  #       end: "2015-01-03",
  #       downloads: [
  #          {day:"2015-01-03",downloads:1}
  #       ]
  #     }
  #   })
  #
  #   ->
  #   {
  #     days: ['2015-01-01','2015-01-02','2015-01-03']
  #     packages: [
  #       {name: 'foo',stats: [0,0,1]},
  #     ]
  #   }
  normalize: (pkgs)->
    days= null

    packages=
      for name,pkg of pkgs
        {downloads,start,end}= pkg
        days?= @getDays start,end

        stats= []

        j= 0
        for day,i in days
          stat= 0
          for j in [j...downloads.length]
            download= downloads[j]
            break if download.day > day

            if download.day is day
              stat= download.downloads
              break

          stats.push stat

        {name,stats}

    {days,packages}

module.exports= new Calculator
module.exports.Calculator= Calculator
