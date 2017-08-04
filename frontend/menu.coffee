{remote} = require 'electron'
{Menu} = remote

module.exports = (app)->

  template = [
    {
      label: 'Application'
      submenu: [
        {
          label: 'Sidebar'
          accelerator: 'Command+S'
          click: ->
            app.toggleSidebar()
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

