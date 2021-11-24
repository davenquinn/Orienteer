/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
const { remote } = require("electron");
const { Menu } = remote;

module.exports = function (app) {
  const template = [
    {
      label: "Application",
      submenu: [
        {
          label: "Sidebar",
          accelerator: "Command+S",
          click() {
            return app.toggleSidebar();
          },
        },
      ],
    },

    {
      label: "Development",
      submenu: [
        {
          label: "Reload",
          accelerator: "Command+R",
          click() {
            remote.getCurrentWindow().reload();
          },
        },
        {
          label: "Toggle DevTools",
          accelerator: "Alt+Command+I",
          click() {
            remote.getCurrentWindow().toggleDevTools();
          },
        },
      ],
    },
    {
      label: "Help",
      submenu: [],
    },
  ];
  const menu = Menu.buildFromTemplate(template);
  return Menu.setApplicationMenu(menu);
};
