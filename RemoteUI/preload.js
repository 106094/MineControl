const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electron', {
  triggerButtonClicked: (data) => {
    ipcRenderer.send('button-click', data);
  }
})

