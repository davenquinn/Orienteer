/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const d3 = require("d3");

// Maybe should use a more standardized
// version of this module
const xml2json = require("xml2json");

let url = "http://localhost:8000/tiles/wmts/1.0.0/WMTSCapabilities.xml";

const doRequest = function () {
  const xo = d3.xhr(url);
  return new Promise((resolve, reject) =>
    xo.get(function (e, d) {
      if (e) {
        return reject(e);
      } else {
        return resolve(d);
      }
    })
  );
};

const convertToJSON = function (response) {
  const _ = xml2json.toJson(response.responseText);
  return JSON.parse(_);
};

const getLayerData = function (d) {
  let ts;
  const c = d.Capabilities.Contents;

  const tileSets = {};
  for (ts of Array.from(c.TileMatrixSet)) {
    const id = ts["ows:Identifier"];
    tileSets[id] = ts;
  }

  console.log(d);
  const layers = c.Layer;
  for (let l of Array.from(layers)) {
    ts = l.TileMatrixSetLink.TileMatrixSet;
    l.TileMatrixSet = tileSets[ts];
  }

  return layers;
};

const createLayers = function (layers) {
  // Create leaflet layers from WMTS datasources
  const output = {};
  for (let l of Array.from(layers)) {
    const _ = "ows:Identifier";
    // Setup layers
    const tmsid = l.TileMatrixSet[_];
    url = l.ResourceURL.template
      .replace("{TileMatrixSet}", tmsid)
      .replace("TileMatrix", "z")
      .replace("TileCol", "x")
      .replace("TileRow", "y");

    const tm = l.TileMatrixSet.TileMatrix;

    const id = l[_];
    const lyr = L.tileLayer(url, {
      minZoom: Number(tm[0][_]),
      maxZoom: Number(tm[tm.length - 1][_]),
      tileSize: tm[0].TileWidth,
      continuousWorld: true,
      detectRetina: true,
    });

    lyr.id = id;
    const name = l["ows:Title"];
    output[name] = lyr;
  }
  return output;
};

module.exports = () =>
  doRequest().then(convertToJSON).then(getLayerData).then(createLayers);
