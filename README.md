Npm Count
---

<p align="right">
  <a href="https://npmjs.org/package/npm-count">
    <img src="https://img.shields.io/npm/v/npm-count.svg?style=flat-square">
  </a>
  <a href="https://travis-ci.org/59naga/npm-count">
    <img src="http://img.shields.io/travis/59naga/npm-count.svg?style=flat-square">
  </a>
  <a href="https://codeclimate.com/github/59naga/npm-count/coverage">
    <img src="https://img.shields.io/codeclimate/github/59naga/npm-count.svg?style=flat-square">
  </a>
  <a href="https://codeclimate.com/github/59naga/npm-count">
    <img src="https://img.shields.io/codeclimate/coverage/github/59naga/npm-count.svg?style=flat-square">
  </a>
  <a href="https://gemnasium.com/59naga/npm-count">
    <img src="https://img.shields.io/gemnasium/59naga/npm-count.svg?style=flat-square">
  </a>
</p>

> a  [npm/download-counts](https://github.com/npm/download-counts) wrapper

[API Documentation](https://cdn.berabou.me/npm-count/docs/)

Usage
---
```bash
npm install npm-count
```

```js
const npmCount = require('npm-count');

npmCount.fetchLastDay()
.then((lastday) => (
  npmCount.fetchTrending(lastday)
  .then((trending) => {
    // sort by downloads desc, name asc
    trending.sort((a, b) => {
      if (a.downloads > b.downloads) {
        return -1;
      }
      if (a.downloads < b.downloads) {
        return 1;
      }
      if (a.name.toLowerCase() > b.name.toLowerCase()) {
        return -1;
      }
      if (a.name.toLowerCase() < b.name.toLowerCase()) {
        return -1;
      }

      return 0;
    });

    const top10 = trending.slice(0, 10).map((publication) => ({
      name: publication.name,
      downloads: publication.downloads,
    }));
    console.log(lastday, top10);
  })
));
```

becomes:

```js
// 2016-03-09
// [ { name: 'accepts', downloads: 383431 },
//   { name: 'js-yaml', downloads: 355826 },
//   { name: 'tough-cookie', downloads: 320130 },
//   { name: 'babel-core', downloads: 182993 },
//   { name: 'ast-types', downloads: 171452 },
//   { name: 'babylon', downloads: 167286 },
//   { name: 'recast', downloads: 159671 },
//   { name: 'invariant', downloads: 100457 },
//   { name: 'ansi-escapes', downloads: 93092 },
//   { name: 'babel-types', downloads: 86348 } ]
```

Development
---
```bash
git clone https://github.com/59naga/npm-count.git
cd npm-count
npm test
```

License
---
[MIT](http://59naga.mit-license.org/)
