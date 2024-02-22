
//----------define----------------------------------------
const ipcRenderer = window.ipcRenderer;

const setButton = document.getElementById('ScanButton')
const remotebutton = document.querySelectorAll('input')
const remind = document.getElementById('remindtext')

const buttons = [[],[],[]];

const abuttons = [[],[]];
var list = document.querySelectorAll("a")
//-----------------------------------------------------------------


const tr = document.getElementsByTagName("tr")
for(var i = 1; i <= tr.length-1; i++){
    const td = tr[i].getElementsByTagName("td")
	buttons[1].push(td[4].innerText)
	buttons[2].push(td[2].innerText)
	abuttons[1].push(td[6].innerText)
}

remotebutton.forEach((value, index) => {
  
  
  
  
  
  const buttontemp = 'Remote' + (index);
  buttons[0].push(buttontemp);

  // 获取按钮元素并添加点击事件处理程序
  const buttonElement = document.getElementById(buttontemp);
  if (buttonElement) {
    buttonElement.addEventListener('click', () => {
      // 在这里执行按钮的点击事件处理逻辑
      //console.log('按钮 ' + buttontemp + ' 被点击了');
	  const buttonIndex = buttons[0].indexOf(buttontemp); // 查找按钮在数组中的索引
      if (buttonIndex !== -1) {
        const content = buttons[1][buttonIndex]; // 使用索引获取相应的内容
		const machineName = buttons[2][buttonIndex]; // 使用索引获取相应的内容
        //console.log('按钮 ' + buttontemp + ' 被点击了，对应的内容是: ' + content);
		
		const data = { buttonId: buttontemp, message: content , machine : machineName};
		electron.triggerButtonClicked(data);

		//window.location.href = 'interface.html?parameter=' + content;
		
      }
    });
  }
});

setButton.addEventListener('click', () => {
  remind.style.display = "";
  const data = { buttonId: 'ScanButton' };
  electron.triggerButtonClicked(data);
})



let targetElement

list.forEach((value, index) => {
	const atemp = 'explorer' + (index);
    abuttons[0].push(atemp);
    
    const buttonElement = document.getElementById(atemp);

    if (buttonElement) {
    buttonElement.addEventListener('click', (event) => {
        // 在这里执行按钮的点击事件处理逻辑
        //console.log('按钮 ' + buttontemp + ' 被点击了');
		event.preventDefault();
		
	    const buttonIndex = abuttons[0].indexOf(atemp); // 查找按钮在数组中的索引|
        if (buttonIndex !== -1) {
			const content = abuttons[1][buttonIndex]; // 使用索引获取相应的内容
			
			//ipcRenderer.send('button-click', '你點擊了超連結');
			
			const controlId = 'load' + index;
            targetElement = document.getElementById(controlId);
            if (targetElement) {
                // 移除 display: none 样式
                targetElement.style.display = '';
            }
			
			const data = { buttonId: atemp ,  message : content , loadbtn : targetElement.innerText };
			electron.triggerButtonClicked(data);
			
		
 
        }
    });
  }
})