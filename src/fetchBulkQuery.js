// dependencies
import request from 'request';
import Promise from 'bluebird';
import immutable from 'immutable';

// private
const requestAsync = Promise.promisify(request);
const api = 'https://api.npmjs.org/downloads';

/**
* fetch the stats via https://github.com/npm/download-counts
*
* @module fetchBulkQuery
* @param {(string|array<string>)} names - package names
* @param {object} [options]
* @param {string} [options.type='point'] - api type
* @param {string} [options.period='last-day'] - stats period
* @param {string} [options.requestOptions={json:true,gzip:true}] - pass to `request`
* @returns {promise<object>} always key-value stats (e.g: {name: stats, ...})
* @see https://github.com/npm/download-counts#readme
*/
export default (names, options = {}) => {
  const opts = immutable.fromJS({
    type: 'point',
    period: 'last-day',
    requestOptions: {
      json: true,
      gzip: true,
    },
  }).mergeDeep(options).toJS();

  const params = typeof names === 'string' ? [names] : names;
  const url = `${api}/${opts.type}/${opts.period}/${encodeURIComponent(params.join(','))}`;
  return requestAsync(url, opts.requestOptions)
  .then(({ body }) => {
    if (body.error) {
      return {};// e.g. {"error":"reason description"}
    }

    // transform key-value stats
    // パッケージ名をカンマで区切るとjsonの書式が変わるので、カンマ区切りの時の書式に合わせる
    if (params.length === 1) {
      return { [body.package]: body };
    }

    return body;
  });
};
