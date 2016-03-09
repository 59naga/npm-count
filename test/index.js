// dependencies
import test from 'ava';

// target
import * as npmCount from '../src';

// specs
test('returns lastday stats', t => (
  npmCount.fetchLastDay()
  .then((lastday) => (
    npmCount.fetchTrending(lastday)
    .then((trending) => {
      t.ok(lastday);
      t.ok(trending.length);

      // todo: the data of tomorrow are mixed :(
    })
  ))
));
