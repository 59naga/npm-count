// dependencies
import test from 'ava';
import moment from 'moment';

// target
import fetchTrending from '../src/fetchTrending';

// specs
test('returns the package names that updated on the specified date', t => (
  fetchTrending('2016-03-06')
  .then((packages) => {
    packages.forEach((pkg) => {
      t.ok(pkg.name.length >= 0);
      t.ok(pkg.downloads >= 0);
      t.ok(pkg.time.modified);
      t.ok(pkg.versions);
      t.ok(pkg['dist-tags'].latest.length >= 0);

      // the data of tomorrow are mixed :(
      t.ok(moment(pkg.time.modified).format('YYYY-MM-DD') >= '2016-03-06');
    });
  })
));
