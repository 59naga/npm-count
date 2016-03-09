// dependencies
import test from 'ava';

// target
import fetchPublications from '../src/fetchPublications';

// specs
test('returns package summary collection array', t => (
  fetchPublications('substack')
  .then((packages) => {
    packages.forEach((pkg) => {
      t.ok(pkg.name.length >= 1);
      t.ok(pkg.description.length >= 0);
      t.ok(pkg.version.length >= 0);
      t.ok(pkg.access === 'public');
    });
  })
));

test('if invalid user name, throw an exception', t => (
  fetchPublications('john doe')
  .catch((reason) => {
    t.ok(reason.message === '500: error getting packages');
  })
));
