# NpmCount [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

[![Sauce Test Status][sauce-image]][sauce]

Fetch the [npm/download-counts](https://github.com/npm/download-counts#data-source).

## Installation

### Via npm
```bash
$ npm install npm-count --save
```
```js
var npmCount= require('npm-count');
console.log(npmCount); //object
```

### Via bower
```bash
$ bower install npm-count --save
```
```html
<script src="bower_components/npm-count/npm-count.min.js"></script>
<script>
  console.log(npmCount); //object
</script>
```

# Cross-platform API

## `.fetchDownloads`(names,period='last-day') -> Promise(packages)

Fetch the download counts of package names in period.

```js
// Fetch the browserify stats in last-day
npmCount.fetchDownloads('browserify')
.then(function(packages){
  console.log(packages);
  // {
  //   "browserify": {
  //     "downloads": [
  //       {
  //         "day": "2015-07-03",
  //         "downloads": 63224
  //       }
  //     ],
  //     "start": "2015-07-03",
  //     "end": "2015-07-03",
  //     "package": "browserify"
  //   }
  // }
});
```

Can use array or csv at `names`

```js
npmCount.fetchDownloads('browserify,glob')
.then(function(packages){
  console.log(packages);
  // {
  //   "browserify": {
  //     "downloads": [
  //       {
  //         "day": "2015-07-03",
  //         "downloads": 63224
  //       }
  //     ],
  //     "start": "2015-07-03",
  //     "end": "2015-07-03",
  //     "package": "browserify"
  //   },
  //   "glob": {
  //     "downloads": [
  //       {
  //         "day": "2015-07-03",
  //         "downloads": 461197
  //       }
  //     ],
  //     "start": "2015-07-03",
  //     "end": "2015-07-03",
  //     "package": "glob"
  //   }
  // }
});
```

Possible values for `period` are as following:

* last-day
* last-month
* last-week
* YYYY-MM-DD
* YYYY-MM-DD:YYYY-MM-DD

> https://github.com/npm/download-counts#examples-1

Specify the `all` if fetch the download conts in last-day from 2012-10-22.

```js
npmCount.fetchDownloads('browserify','all')
.then(function(packages){
  console.log(packages);
  // {
  //   "browserify": {
  //     "downloads": [
  //       {
  //         "day": "2012-10-22",
  //         "downloads": 40
  //       },
  //       // (...903 days...)
  //       {
  //         "day": "2015-07-03",
  //         "downloads": 63224
  //       }
  //     ],
  //     "start": "2012-10-22",
  //     "end": "2015-07-03",
  //     "package": "browserify"
  //   }
  // }
});
```

> [Nothing the past than 2012-10-22](https://api.npmjs.org/downloads/range/2012-01-01:2012-10-21).

## `.normalize`(packages) -> normalized

To convert as following:

* start,end -> `days`
* key -> packages[].name
* downloads[].downloads -> packages[].`stats`[]

`stats` are initialized to 0, with the same length as the `days`.

```js
var normalized= npmCount.normalize({
  foo: {
    start: "2015-01-01",
    end: "2015-01-03",
    downloads: [
       {day:"2015-01-03",downloads:1}
    ]
  }
});
console.log(normalized);
// {
//   days: ['2015-01-01','2015-01-02','2015-01-03']
//   packages: [
//     {name: 'foo',stats: [0,0,1]},
//   ]
// }
```

## `.calculate`(normalized) -> calculated

Calculate the total and average in periods(all, weekly, monthly, yearly) and each package(in periods).

```js

npmCount.fetchDownloads('abbrev,...','all')
.then(function(packages){
  var normalized= npmCount.normalize(packages);
  var calculated= npmCount.calculate(normalized);
  console.log(calculated);
});
// {
//   "start": "2012-10-22",
//   "end": "2015-07-03",
//   "total": 1472449362,
//   "average": 1494872.4487309644,
//   "weekly": [
//     {
//       "start": "2015-06-27",
//       "end": "2015-07-03",
//       "total": 43061905,
//       "average": 6151700.714285715,
//       "column": [
//         2882864,
//         2708772,
//         7524183,
//         8558533,
//         8155635,
//         7784042,
//         5447876
//       ]
//     },
//     //{more 140 weeks...},
//   ],
//   "monthly": [
//     {
//       "start": "2015-06-04",
//       "end": "2015-07-03",
//       "total": 193759014,
//       "average": 6458633.8,
//       "column": [
//         //(30 days...)
//       ]
//     }
//     //(more months...)
//   ],
//   "yearly": [
//     {
//       "start": "2014-07-04",
//       "end": "2015-07-03",
//       "total": 1242984915,
//       "average": 3405438.1232876712,
//       "column": [
//         //(365 days...)
//       ]
//     }
//     //(more years...)
//   ],
//   "packages": [
//     {
//       "name": "abbrev",
//       "total": 34287587,
//       "average": 34809.732994923856,
//       "weekly": [
//         {
//           "start": "2015-06-27",
//           "end": "2015-07-03",
//           "total": 932771,
//           "average": 133253,
//           "column": [
//             //(7 days...)
//           ]
//         }
//         //(more weeks...)
//       ],
//       "monthly": [
//         {
//           "start": "2015-06-04",
//           "end": "2015-07-03",
//           "total": 4426192,
//           "average": 147539.73333333334,
//           "column": [
//             //(30 days...)
//           ]
//         }
//         //(more months...)
//       ],
//       "yearly": [
//         {
//           "start": "2014-07-04",
//           "end": "2015-07-03",
//           "total": 26857890,
//           "average": 73583.2602739726,
//           "column": [
//             //(365 days...)
//           ]
//         }
//         //(more years...)
//       ],
//     },
//     //(many many packages...)
//   ],
// }
```

# Node.js API

## `.fetch`(author,period='last-day') -> Promise(packages)

Fetch the download counts of author in period.

Works only in Node.js:

* Using the informal API
* URL not have `Access-Control-Allow-Origin`

```js
npmCount.fetch('substack')
.then(function(packages){
  console.log(packages);
  // {
  //   "charm": {
  //     "downloads": [
  //       {
  //         "day": "2015-07-03",
  //         "downloads": 12168
  //       }
  //     ],
  //     "start": "2015-07-03",
  //     "end": "2015-07-03",
  //     "package": "charm"
  //   },
  //   // (...442 packages...)
  //   "webglew": {
  //     "downloads": [
  //       {
  //         "day": "2015-07-03",
  //         "downloads": 40
  //       }
  //     ],
  //     "start": "2015-07-03",
  //     "end": "2015-07-03",
  //     "package": "webglew"
  //   }
  // }
});
```

## `.fetchPackages`(author,flatten=true) -> Promise(names or informations)

Fetch the package informations using [informal API](https://www.npmjs.com/profile/substack/packages?offset=0).

```js
npmCount.fetchPackages('substack')
.then(function(names){
  console.log(names);
});
// ["accountdown",(...660packages...),"zygote"]

npmCount.fetchPackages('substack',false)
.then(function(informations){
  console.log(informations);
});
// [
//   {
//     "dist-tags": {},
//     "homepage": "https://github.com/substack/accountdown",
//     "version": "4.1.0",
//     "description": "persistent accounts backed to leveldb",
//     "bugs": {
//       "email": null,
//       "url": "https://github.com/substack/accountdown/issues"
//     },
//     "access": "public",
//     "versions": {},
//     "name": "accountdown"
//   },
//   // (... 660 packages ...)
//   {
//     "dist-tags": {},
//     "homepage": null,
//     "version": "0.0.1",
//     "description": "cellular differentiation for seaport clusters",
//     "access": "public",
//     "versions": {},
//     "name": "zygote"
//   }
// ]
```

# TEST & DEBUG
```bash
git clone https://github.com/59naga/npm-count.git
cd npm-count
npm install

# nodejs
npm test

# browser
npm run localhost

# cloud-test(requirement SAUCE_USERNAME and SAUCE_ACCESS_KEY in env)
npm test-cloud
```

License
---
[MIT][License]

[License]: http://59naga.mit-license.org/

[sauce-image]: http://soysauce.berabou.me/u/59798/npm-count.svg
[sauce]: https://saucelabs.com/u/59798
[npm-image]:https://img.shields.io/npm/v/npm-count.svg?style=flat-square
[npm]: https://npmjs.org/package/npm-count
[travis-image]: http://img.shields.io/travis/59naga/npm-count.svg?style=flat-square
[travis]: https://travis-ci.org/59naga/npm-count
[coveralls-image]: http://img.shields.io/coveralls/59naga/npm-count.svg?style=flat-square
[coveralls]: https://coveralls.io/r/59naga/npm-count?branch=master
