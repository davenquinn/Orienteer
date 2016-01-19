remote = require 'remote'
Menu = remote.require 'menu'

template = [
  {
    label: 'Actions'
    submenu: [
      {
        label: 'Filter Data'
        accelerator: 'Command+F'
        click: ->
          remote.getCurrentWindow().reload()
          return

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

module.exports = ->
  menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu menu

