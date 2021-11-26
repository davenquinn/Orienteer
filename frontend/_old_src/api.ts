const api = require("./shared/data/api");

//# Creates an API function compatible with
//  Mike Bostock's d3 and queue-async modules
//  It can be invoked with the
//  xhr.post, xhr.get, xhr.send('method',data,callback)

module.exports = api(window.server_url + "/api");
