class CacheDatastore
  constructor: (@name)->

  get: =>
    data = window.localStorage.getItem @name
    JSON.parse data

  set: (data)=>
    _ = JSON.stringify data
    window.localStorage.setItem @name, _

  exists: => @get()?

module.exports = CacheDatastore
