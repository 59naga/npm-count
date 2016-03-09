// dependencies
import request from 'request';
import Promise from 'bluebird';
import immutable from 'immutable';

// private
const requestAsync = Promise.promisify(request);
const api = 'https://www.npmjs.com/profile';

/**
* fetch the author's publications
*
* @module fetchPublications
* @param <string> author - npm user name
* @returns {promise<collection>} author's publications summary
* @see https://www.npmjs.com/profile/substack/packages?offset=0
*/
export default (author) => (
  Promise.all(
    immutable.Range(0, 11).map((offset) => (
      requestAsync(`${api}/${author}/packages?offset=${offset}`, {
        json: true,
        gzip: true,
      })
      .then(({ statusCode, body }) => {
        if (typeof body === 'string') {
          return Promise.reject(new Error(`${statusCode}: ${body}`));
        }

        return body.items;
      })
    ))
  )
  .then((pages) => pages.reduce((prev, current) => current.concat(prev), []))
);
