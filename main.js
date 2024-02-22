const { app, BrowserWindow, ipcMain , clipboard , shell , dialog} = require('electron')
const path = require('path');
const { spawn } = require('child_process');
const child_process = require('child_process');
//const ProgressBar = require('electron-progressbar');

function runPowershellScriptAndReload(paraD,winD) {
  return new Promise((resolve, reject) => {
	  /*
	const progressBar = paraD.processbar;
      let width = 0;
      const intervalId = setInterval(() => {
        if (width < 100) {
          width += 10;
          progressBar.style.width = width + '%';
        } else {
          clearInterval(intervalId);
        }
      }, 500);  
	  */
	let powershellOutput = ''; 
	  
    const powershell = spawn('powershell.exe', [
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      'remote_update.ps1',
	  '-ipend',
	  paraD.message,
	  '-mnend',
	  paraD.machine
    ]);

	
    powershell.stdout.on('data', (data) => {
      powershellOutput += data.toString();
      console.log(`stdout: ${data}`);
    });

    powershell.stderr.on('data', (data) => {
      console.error(`stderr: ${data}`);
    });
	
	/*
    powershell.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
      resolve(); // 当PowerShell脚本执行完毕时，解析Promise
    });
	*/
	
	powershell.on('close', (code) => {
    console.log(`child process exited with code ${code}`);
    if (powershellOutput.match(/Success/)) {
      const powershell = spawn('powershell.exe', [
			'-ExecutionPolicy',
			'Bypass',
			//'-File',
			//'remote2.ps1',
			//'-name',
			//'John'
			'-Command',
			'mstsc.exe /shadow:1 /v ' + paraD.message +  ' /control /prompt /noConsentPrompt'
		]);


		powershell.stdout.on('paraD', (paraD) => {
			console.log(`stdout: ${paraD}`);
		});

		powershell.stderr.on('paraD', (paraD) => {
			console.error(`stderr: ${paraD}`);
		});

		powershell.on('close', (code) => {
			console.log(`child process exited with code ${code}`);
		});
		
		clipboard.writeText(paraD.machine);

		winD.loadFile('interface.html');
		
    } else {
      /*callback(`PowerShell script exited with code ${code}`);*/
	  //electron.dialog.showMessageBox({ message: `Connect Failed` });
	  const options = {
		type: 'warning',
		title: 'Caution',
		message: `${paraD.machine} Connect Failed`,
		buttons: ['OK']
	  };

	  const buttonIndex = dialog.showMessageBoxSync(options);

	  console.log(options.buttons[buttonIndex]);
    }
  });

  });
}

function runPowershellScriptAndReloadAll() {
  return new Promise((resolve, reject) => {
    const powershell = spawn('powershell.exe', [
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      'remote_updateAll.ps1'
    ]);

    powershell.stdout.on('data', (data) => {
      console.log(`stdout: ${data}`);
    });

    powershell.stderr.on('data', (data) => {
      console.error(`stderr: ${data}`);
    });

    powershell.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
      resolve(); // 当PowerShell脚本执行完毕时，解析Promise
    });
  });
}

function runPowershellScriptAndReloadF(paraD) {
  return new Promise((resolve, reject) => {
    const powershell2 = spawn('powershell.exe', [
		'-ExecutionPolicy',
		'Bypass',
		'-File',
		'test.ps1',
		'-Eleid',
		paraD,
	]);
				
	powershell2.stdout.on('data', (data) => {
		console.log(`stdout: ${data}`);
	});

	powershell2.stderr.on('data', (data) => {
		console.error(`stderr: ${data}`);
	});

	powershell2.on('close', (code) => {
		console.log(`child process exited with code ${code}`);
		resolve();
	});
  });
}

function runPowershellScriptAndReloadS(paraD) {
  return new Promise((resolve, reject) => {
    const powershell2 = spawn('powershell.exe', [
		'-ExecutionPolicy',
		'Bypass',
		'-File',
		'test.ps1',
		'-Eleid',
		paraD,
		'-Action',
		1,
	]);
				
	powershell2.stdout.on('data', (data) => {
		console.log(`stdout: ${data}`);
	});

	powershell2.stderr.on('data', (data) => {
		console.error(`stderr: ${data}`);
	});

	powershell2.on('close', (code) => {
		console.log(`child process exited with code ${code}`);
		resolve();
	});
  });
}


function createWindow() {
  const win = new BrowserWindow({
    width: 1500,
    height: 800,
	autoHideMenuBar: true,
	webPreferences: {
      nodeIntegration: true, // 允許 Node.js 整合到渲染進程中
	  preload: path.join(__dirname, 'preload.js'), // 設定 preload 檔案
    },
  });

  win.loadFile('interface.html'); // 替换 'your-webpage.html' 为你的网页文件路径

  ipcMain.on('button-click', (event, data) => {
	
	
	
	if(data.buttonId === 'ScanButton'){
		runPowershellScriptAndReloadAll()
    .then(() => {
      win.loadFile('interface.html');
    })
    .catch((error) => {
      console.error(error);
    });
	
	    //waitting process complete , restart electron
	}
	
	
	if(data.buttonId.match(/Remote/)){
		/*
		const powershell = spawn('powershell.exe', [
			'-ExecutionPolicy',
			'Bypass',
			//'-File',
			//'remote2.ps1',
			//'-name',
			//'John'
			'-Command',
			'mstsc.exe /shadow:1 /v ' + data.message +  ' /control /prompt /noConsentPrompt'
		]);


		powershell.stdout.on('data', (data) => {
			console.log(`stdout: ${data}`);
		});

		powershell.stderr.on('data', (data) => {
			console.error(`stderr: ${data}`);
		});

		powershell.on('close', (code) => {
			console.log(`child process exited with code ${code}`);
		});
		
		clipboard.writeText(data.machine);
		
		
		
			runPowershellScriptAndReload(data)
		.then(() => {
		  win.loadFile('interface.html');
		})
		.catch((error) => {
		  console.error(error);
		});
		*/
		
		runPowershellScriptAndReload(data,win)
	}
	
	if(data.buttonId.match(/explorer/)){
		//const command = `explorer "${path.resolve(data.message)}"`;
		//child_process.exec(command);
		//openExplorerWithPath(data.message);
		
		//console.log('(Get-Content -Path "interface.html" -Raw) -replace "(\'load0\').{22}", \'$1\' -replace "(\'load0\'>).{10}", \'$1Fail. Please reconnect.\' | Set-Content -Path "interface.html"');
		// 將字串以換行符分割成陣列
		const lines = data.message.split('\n');

		// 選取第一行文字
		const datamessage = lines[0];

		console.log(datamessage);
	
		const powershell = spawn('powershell.exe', [
			'-ExecutionPolicy',
			'Bypass',
			'-Command',
			'Get-ChildItem -Path "' + datamessage + '"',
		]);
		
		let temp = ""
		
		powershell.stdout.on('data', (data) => {
			temp += data.toString();
			console.log(`stdout: ${data}`);
		});

		powershell.stderr.on('data', (data) => {
			console.error(`stderr: ${data}`);
			console.log(0);
		});

		powershell.on('close', (code) => {
			console.log(`child process exited with code ${code}`);
			
			//data.buttonId[data.buttonId.length - 1]
			//(Get-Content -Path "interface.html" -Raw) -replace "('load0').{22}", '$1' | Set-Content -Path "interface.html"
			if(code === 0){
				//#AAA
				console.log("AAA")
				console.log(data.loadbtn)
				
				const command = `explorer "${path.resolve(data.message)}"`;
				child_process.exec(command);
				
				if(data.loadbtn.match(/Fail/)){
					console.log("ReloadSuccess")
					runPowershellScriptAndReloadS(data.buttonId[data.buttonId.length - 1])
						.then(() => {
					  win.loadFile('interface.html');
					})
					.catch((error) => {
					  console.error(error);
					});
				}
				/*
				const powershell2 = spawn('powershell.exe', [
					'-ExecutionPolicy',
					'Bypass',
					'-Command',
					'(Get-Content -Path "interface.html").Replace("Loading...","") | Set-Content "interface.html"',
				]);
				
				powershell2.stdout.on('data', (data) => {
					console.log(`stdout: ${data}`);
				});

				powershell2.stderr.on('data', (data) => {
					console.error(`stderr: ${data}`);
				});

				powershell2.on('close', (code) => {
					console.log(`child process exited with code ${code}`);
				});
				*/
				win.loadFile('interface.html');
			}else{
				//#AAA
				console.log("BBB")
				console.log(`${data.buttonId[data.buttonId.length - 1]}`);
				
				runPowershellScriptAndReloadF(data.buttonId[data.buttonId.length - 1])
					.then(() => {
				  win.loadFile('interface.html');
				})
				.catch((error) => {
				  console.error(error);
				});
				
				//win.loadFile('interface.html');
			}
		});
		
		//const command = `explorer "${path.resolve(data.message)}"`;
		//child_process.exec(command);
	}
  });
  
  
  
  //win.webContents.openDevTools()
  // 可以添加更多的功能，如菜单、快捷键等
  win.on('closed', () => {
    // 在窗口关闭时执行的代码
  });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

