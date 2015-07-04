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

# Calculate

can be calculated using the [lodash](https://npmjs.org/package/lodash).

```bash
$ npm install lodash --save
```

```js
var sum= function(packages){
  return _.chain(packages)
  .pluck('downloads')
  .flatten(true)
  .sum(function(pkg){
    return pkg.downloads;
  })
  .value()
}

npmCount.fetch('isaacs').then(function(packages){
  console.log(sum(packages));// 5447876
});

npmCount.fetch('isaacs','last-week').then(function(packages){
  console.log(sum(packages));// 43061905
});

npmCount.fetch('isaacs','last-month').then(function(packages){
  console.log(sum(packages));// 193759014
});

npmCount.fetch('isaacs','all').then(function(packages){
  console.log(sum(packages));// 1472449362
});
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
