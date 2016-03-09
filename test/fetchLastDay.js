// dependencies
import test from 'ava';
import moment from 'moment';

// target
import fetchLastDay from '../src/fetchLastDay';

// specs
test('returns the yesterday based on UTC', t => (
  fetchLastDay((lastday) => {
    const utcYesterday = moment.utc().subtract(1, 'days').startOf('day').format('YYYY-MM-DD');

    t.ok(lastday === utcYesterday);
  })
));
