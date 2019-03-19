getTags = (records) ->
  func = (a, d)->
    Array::push.apply a, d.tags
    return a
  records.reduce func, []


module.exports =
  get: getTags
  getUnique: (records)->
    tags = []
    for d in getTags(records)
      if tags.indexOf(d) == -1
        tags.push d
    tags
