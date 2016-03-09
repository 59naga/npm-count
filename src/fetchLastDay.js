// dependencies
import request from 'request';
import Promise from 'bluebird';

// private
const requestAsync = Promise.promisify(request);
const api = 'https://api.npmjs.org/downloads/point/last-day/';

/**
* fetch the api.npmjs.org's lastday
*
* @module fetchLastDay
* @returns {promise<string>} "YYYY-MM-DD"
* @see https://github.com/watilde/npm/issues/4#issuecomment-193541204
*/
export default () => (
  requestAsync(api, {
    json: true,
    gzip: false,
  })
  .then(({ body }) => {
    if (body.error) {
      return {};// {"error":"no stats for this package for this period (0002)"}
    }

    return body.start;
  })
);
