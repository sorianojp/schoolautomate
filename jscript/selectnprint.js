document.onselectstart=new Function('return false');
function ds(e) {
	return false;
}
function ra() {
	return true;
}
document.onmousedown=ds;document.onclick=ra;

function p1(){
	for(pp=0;pp<document.all.length;pp++) {
		if(document.all[pp].style.visibility!='hidden')
			document.all[pp].style.visibility='hidden';document.all[pp].id='ph'
	}
}
function p2() {
	for (pp=0;pp<document.all.length;pp++)
		if(document.all[pp].id=='ph')document.all[pp].style.visibility=''
}
	
window.onbeforeprint=p1;window.onafterprint=p2;

document.oncontextmenu=new Function("return false")

/*** added code to disable right click **/
if (document.layers){
	document.captureEvents(Event.MOUSEDOWN);
	document.onmousedown=clickNS4;
}
else if (document.all&&!document.getElementById){
	document.onmousedown=clickIE4;
}


function clickIE4(){
	browserIndex = 1;
	if (event.button==2)
		return false;
}

function clickNS4(e){
	browserIndex = 0;
	if (document.layers||document.getElementById&&!document.all){
		if (e.which==2||e.which==3)
			return false;
	}
}
/*** added code to disable right click **/






/////////////////added to disable hot keys.
/** Not needed as of now.. 
function disableCtrlKeyCombination(e){
    //list all CTRL + key combinations you want to disable
	var forbiddenKeys = new Array(‘a’, ‘n’, ‘c’, ‘x’, ‘v’, ‘j’);
	var key;
	var isCtrl;
	if(window.event){
		key = window.event.keyCode;     //IE
		if(window.event.ctrlKey)
			isCtrl = true;
		else
			isCtrl = false;
	}
	else {
		key = e.which;     //firefox
		if(e.ctrlKey)
			isCtrl = true;
		else
			isCtrl = false;
	}

	//if ctrl is pressed check if other key is in forbidenKeys array
	if(isCtrl) {
		for(i=0; i<forbiddenkeys .length; i++){
			//case-insensitive comparation
			if(forbiddenKeys[i].toLowerCase() == String.fromCharCode(key).toLowerCase()){
				alert("Key combination CTRL +" + String.fromCharCode(key) + "has been disabled.");
				return false;
			}
		}
	}
	return true;
}
**/