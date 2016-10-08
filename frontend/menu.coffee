{remote} = require 'electron'
{Menu} = remote

module.exports = (app)->

  template = [
    {
      label: 'Application'
      submenu: [
        {
          label: 'Go to front page'
          accelerator: 'Command+H'
          click: ->
            app.index()
        }
        {
          label: 'Filter Data'
          accelerator: 'Command+F'
          click: ->
            app.page.toggleFilter()
        }
        {
          label: 'Data Panel'
          accelerator: 'Command+D'
          click: ->
            app.page.toggleData()
        }
      ]
    }

    {
      label: 'Development'
      submenu: [
        {
          label: 'Reload'
          accelerator: 'Command+R'
          click: ->
            remote.getCurrentWindow().reload()
            return

        }
        {
          label: 'Toggle DevTools'
          accelerator: 'Alt+Command+I'
          click: ->
            remote.getCurrentWindow().toggleDevTools()
            return

        }
      ]
    }
    {
      label: 'Help'
      submenu: []
    }
  ]
  menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu menu

