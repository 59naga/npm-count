// dependencies
import test from 'ava';

// target
import fetchBulkQuery from '../src/fetchBulkQuery';

// specs
test('returns always an key-value object', t => (
  fetchBulkQuery(['browserify'], { period: '2016-03-07' })
  .then((packages) => {
    t.ok(typeof packages === 'object');
    t.ok(packages.browserify.downloads === 70854);
    t.ok(packages.browserify.start === '2016-03-07');
    t.ok(packages.browserify.end === '2016-03-07');
    t.ok(packages.browserify.package === 'browserify');
  })
));

test('accept the string as 1st argument', t => (
  fetchBulkQuery('browserify', { period: '2016-03-07' })
  .then((packages) => {
    t.ok(typeof packages === 'object');
    t.ok(packages.browserify.downloads === 70854);
    t.ok(packages.browserify.start === '2016-03-07');
    t.ok(packages.browserify.end === '2016-03-07');
    t.ok(packages.browserify.package === 'browserify');
  })
));

test('if specify type is `range`, downloads will be array', t => (
  fetchBulkQuery('browserify', { period: '2016-03-07', type: 'range' })
  .then((packages) => {
    t.ok(typeof packages === 'object');
    t.ok(packages.browserify.downloads instanceof Array);
    t.ok(packages.browserify.downloads[0].downloads === 70854);
    t.ok(packages.browserify.downloads[0].day === '2016-03-07');
    t.ok(packages.browserify.start === '2016-03-07');
    t.ok(packages.browserify.end === '2016-03-07');
    t.ok(packages.browserify.package === 'browserify');
  })
));

test('if no results or error, returns an empty object', t => (
  fetchBulkQuery('no beginning no end')
  .then((packages) => {
    t.same(packages, {});

    return fetchBulkQuery('no beginning no end', { period: 'invalid' });
  })
  .then((packages) => {
    t.same(packages, {});
  })
));
