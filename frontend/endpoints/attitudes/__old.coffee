    @map = new Map
      el: @$ ".map"
    @map.addData @data

    @sidebar.addData @data
    @dataPanel = new DataPanel
      el: @$ ".data-panel"
    @map.invalidateSize()

    @listenToOnce @data.constructor, "updated", =>
      console.log "Finished loading data"
      @$(".app-status").removeClass "loading"

    @listenTo @data.constructor, "hovered", (d)=>
      # If hover-out, data will not be defined
      return unless d?
      @$(".navbar div.info")
        .html infoTemplate
          id: d.id
          strike: f(d.properties.strike)
          dip: f(d.properties.dip)
          tags: d.tags
          showTags: d.tags.length > 0

