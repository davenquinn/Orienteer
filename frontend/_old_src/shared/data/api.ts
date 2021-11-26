/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { request } = require("d3-request");

//# Creates an API function compatible with
//  Mike Bostock's d3 and queue-async modules
//  It can be invoked with the
//  xhr.post, xhr.get, xhr.send('method',data,callback)

module.exports = function (api_url) {
  if (api_url == null) {
    api_url = window.server_url + "/api";
  }
  return (url) =>
    request(api_url + url)
      .mimeType("application/json")
      .header("X-Requested-With", "XMLHttpRequest")
      .response((xhr) => JSON.parse(xhr.responseText));
};
