// dependencies
import moment from 'moment';
import Promise from 'bluebird';
import request from 'request';
import JSONStream from 'JSONStream';
import immutable from 'immutable';

// self dependencies
import fetchBulkQuery from './fetchBulkQuery';

// private
const api = 'https://skimdb.npmjs.com/-/all/since';

/**
* fetch the package stats base on `date`
*
* @module fetchTrending
* @param {string} date - fetch based on date(YYYY-MM-DD)
* @param {object} [options]
* @param {number} [options.step=10] - bulk query split size
* @returns {promise<collection>} info
* @see https://github.com/watilde/npm/issues/4#issuecomment-192640770
*/
export default (date, options = {}) => (
  new Promise((resolve, reject) => {
    const opts = immutable.fromJS({
      step: 10,
    }).mergeDeep(options).toJS();

    // npmのdbから変更日を元にパッケージ情報を取得
    const startkey = moment.utc(date).startOf('day')._d.getTime();
    const endkey = moment.utc(date).endOf('day')._d.getTime();
    const url = `${api}?stale=update_after&startkey=${startkey}&endkey=${endkey}`;
    const stream = request(url, {
      headers: { host: 'registry.npmjs.org' },
      // see: https://github.com/bitinn/node-fetch/issues/15
      agentOptions: {
        rejectUnauthorized: false,
      },
    });

    stream
    .on('error', reject)
    .on('response', (response) => {
      if (response.statusCode >= 400) {
        return stream.on('data', (data) => {
          const { error, reason } = JSON.parse(data.toString());
          reject(`${response.statusCode} ${error}: ${reason}`);
        });
      }

      // パッケージの更新情報にダウンロード数を付与する
      const index = {};
      const summaries = [];
      const bulkQueries = [];
      let pendingNames = [];
      return stream
      .pipe(JSONStream.parse('*'))
      .on('data', (data) => {
        if (data.name === undefined) {
          return;
        }

        // まれにdownloadsが取得できないパッケージがあるので、0で初期化する
        summaries.push({
          ...data,
          downloads: 0,
        });
        index[data.name] = summaries.length - 1;

        // step件数溜まったらリクエストを発行
        pendingNames.push(data.name);
        if (pendingNames.length >= opts.step) {
          bulkQueries.push(fetchBulkQuery(pendingNames));
          pendingNames = [];
        }
      })
      .on('end', () => {
        // 未解消のリクエストを開放
        if (pendingNames.length) {
          bulkQueries.push(fetchBulkQuery(pendingNames));
          pendingNames = [];
        }

        // 全てのリクエストが終了したらパッケージ情報とマージ
        Promise.all(bulkQueries)
        .then((jsons) => {
          jsons.forEach((json) => {
            for (const key in json) {
              if (json.hasOwnProperty(key) === false) {
                continue;
              }

              const stat = json[key];
              const summary = summaries[index[key]];
              if (summary) {
                summary.downloads = stat.downloads;
              }
            }
          });

          resolve(summaries);
        });
      });
    });
  })
);
