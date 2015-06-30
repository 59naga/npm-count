# NpmCount [![NPM version][npm-image]][npm] [![Build Status][travis-image]][travis] [![Coverage Status][coveralls-image]][coveralls]

[![Sauce Test Status][sauce-image]][sauce]

Fetch the npm stats for easy calculation using [download-counts](https://github.com/npm/download-counts).

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

## `.fetchDownloads`(packages,period='last-day') -> Promise(count)

Fetch the download count and total of period of specified packages.

```js
npmCount.fetchDownloads('browserify')
.then(function(count){
  console.log(count);
});
// {
//   "days": [
//     "2015-06-23"
//   ],
//   "packages": {
//     "browserify": [
//       54778
//     ]
//   },
//   "total": {
//     "days": [
//       54778
//     ],
//     "packages": {
//       "browserify": 54778
//     }
//   }
// }
```

Can use array or csv at `packages`

```js
npmCount.fetchDownloads('browserify,glob')
.then(function(count){
  console.log(count);
});
// {
//   "days": [
//     "2015-06-23"
//   ],
//   "packages": {
//     "browserify": [
//       54778
//     ],
//     "glob": [
//       665597
//     ]
//   },
//   "total": {
//     "days": [
//       720375
//     ],
//     "packages": {
//       "browserify": 54778,
//       "glob": 665597
//     }
//   }
// }
```

Can use the following as an `period`:
* last-day
* last-month
* last-week
* YYYY-MM-DD
* YYYY-MM-DD:YYYY-MM-DD

> https://github.com/npm/download-counts#examples-1

Can fetch the `all` download count of specified packages to last-day from 2012-10-22 using __all__ of `period`.

```js
npmCount.fetchDownloads('browserify','all')
.then(function(count){
  console.log(count);
});
// {
//   "days": [
//     "2012-10-22",
//     ...
//     "2015-06-23"
//   ],
//   "packages": {
//     "browserify": [
//       40,
//       ...
//       54778
//     ]
//   },
//   "total": {
//     "days": [
//       40,
//       ...
//       54778
//     ],
//     "packages": {
//       "browserify": 12991291
//     }
//   }
// }
```

> [The past than 2012-10-22 is nothing](https://api.npmjs.org/downloads/range/2012-01-01:2012-10-21).

## `.last`(count) -> day

Get the last day of `count`.

```js
var count= {
   "days": [
     "2012-10-22",
     "2015-06-23"
   ],
   "packages": {
     "browserify": [
       40,
       54778
     ]
   },
   "total": {
     "days": [
       40,
       54778
     ],
     "packages": {
       "browserify": 12991291
     }
   }
 };

 npmCount.last(count);
 // -> "2015-06-23"
 ```

# Node.js API

## `.fetch`(owner,period='last-day') -> Promise(count)

Fetch the download count and total of period of specified owner.

Works only in Node.js:
* Using the informal API
* URL not have `Access-Control-Allow-Origin`

```js
npmCount.fetch('substack')
.then(function(count){
  console.log(count);
});
// {
//   "days": [
//     "2012-10-22",
//     ...
//     "2015-06-23"
//   ],
//   "packages": {
//     "browserify": [...]
//     ...
//     "zygote": [...]
//   },
//   "total": {
//     "days": [
//       ...
//       ...
//       ...
//     ],
//     "packages": {
//       "browserify": ...
//       ...
//       "zygote": ...
//     }
//   }
// }
```

## `.fetchPackages`(owner,flatten=true) -> Promise(packages)

Fetch the package informations using [informal API](https://www.npmjs.com/profile/substack/packages?offset=0).

```js
npmCount.fetchPackages('substack')
.then(function(names){
  console.log(names);
});
// ["accountdown",...,"zygote"]

npmCount.fetchPackages('substack',false)
.then(function(packages){
  console.log(packages);
});
// [
//   {
//     "bugs": {
//       "email": null,
//       "url": "https://github.com/substack/accountdown/issues"
//     },
//     "versions": {},
//     "version": "4.1.0",
//     "homepage": "https://github.com/substack/accountdown",
//     "dist-tags": {},
//     "access": "public",
//     "description": "persistent accounts backed to leveldb",
//     "name": "accountdown"
//   },
//   {
//     "name": "zygote",
//     "access": "public",
//     "version": "0.0.1",
//     "versions": {},
//     "homepage": null,
//     "dist-tags": {},
//     "description": "cellular differentiation for seaport clusters"
//   }
// ]
```

# TEST & DEBUG
```bash
git clone https://github.com/59naga/npm-count.git
cd npm-count
npm install

npm test
# or...
DEBUG=on npm test # show uris
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
