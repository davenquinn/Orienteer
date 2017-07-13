module.exports =
  getIndexById: (array, d)->
    # Function to get index of matching element
    # of array using `id` as a comparator key
    array.findIndex (v)->v.id == d.id

  _not: (fn)->
    # Inverts a boolean-returning function
    -> not fn(arguments...)


