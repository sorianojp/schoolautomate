//////////////// for simple AJAX, this does not support dynamic page reload like in Yahoo/cnn
//////////////// this only reloads a value or innerHTML tag in a page.
//draw back of time delay -- after everything is typed, user must press
//space bar.
/**
var iStartTime = 0;
var iCurTime   = 0;//to get the time delay.
var iTimeDelay = 300;//400ms time delay in sending
**/

var xmlHttp;
var strErrMsg;

var dynamicObj;
var propertyType; //1 = .value, 2 = .innerHTML
var retObj;// value returned from server.

var bolReturnStrEmpty;///if return string is empty , set it to true.
var strPrevEntry;//stores previous entry. if prev result is empty and new entry starts with pre. entry, i must return right away.

var oldVal;
// to handle multiple label updates
var isMultipleObj = false;

var dynamicObj2;
var dynamicObj3;
var bolSetEIP = true; // EIP = error in processing
var dynamicLoadingImg = "Processing...";
function InitXmlHttpObjectMultiple(dynamicObj, dynamicObj2, dynamicObj3)
{
	//if(iStartTime == 0)
	//	iStartTime = new Date().getTime();//time in ms.

	xmlHttp     = null;
	this.retObj = null;
	
	this.dynamicObj   = dynamicObj;
	this.dynamicObj2   = dynamicObj2;
	this.dynamicObj3   = dynamicObj3;
	isMultipleObj = true;

	this.propertyType = '2';

	try {// Firefox, Opera 8.0+, Safari
	  xmlHttp=new XMLHttpRequest();
  	}
	catch (e){// Internet Explorer
		try {
			xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e) {
			xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
}

function InitXmlHttpObject(dynamicObj,propertyType){	
	//if(iStartTime == 0)
	//	iStartTime = new Date().getTime();//time in ms.
	isMultipleObj = false;
	xmlHttp     = null;
	this.retObj = null;

	this.dynamicObj   = dynamicObj;
	this.propertyType = propertyType;
	if(propertyType == 1)
		oldVal = this.dynamicObj.value;

	try {// Firefox, Opera 8.0+, Safari
	  xmlHttp=new XMLHttpRequest();
  	}
	catch (e){// Internet Explorer
		try {
			xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e) {
			xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
}

function InitXmlHttpObject2(dynamicObj, propertyType, dynamicLoadingImg) {
	InitXmlHttpObject(dynamicObj,propertyType);
	this.dynamicLoadingImg = dynamicLoadingImg;
}

/**
State Description
0 The request is not initialized
1 The request has been set up
2 The request has been sent
3 The request is in process
4 The request is complete
NOTE : Complete URL is ./ajaxmain.jsp?methodRef=1&otherparameter
//ajaxmain.jsp calls a method AjaxMain.java and does all operation there
//AjaxMain.java needs methodRef to call method needed for the operation of that page event.
//other params are search criteria.
*/

function processRequest(strCompleteURL) {
	//iCurTime  = new Date().getTime();//time in ms.
	//if( (iCurTime - iStartTime) < iTimeDelay) {
	////	iStartTime = iCurTime;
	//	return;
	//}
	//alert(iCurTime - iStartTime);

	xmlHttp.onreadystatechange=stateChanged;
	xmlHttp.open("GET",strCompleteURL,true);
	xmlHttp.send(null);

	//iStartTime = iCurTime;
}

function stateChanged() {
	if (xmlHttp.readyState==4) {
          if (!xmlHttp.status == 200) {//bad request.
            dynamicObj.innerHTML = "Connection to server is lost";
            return;
          }
		
		//alert(xmlHttp.responseText); -- uncomment this to view error/exception...
		this.retObj = xmlHttp.responseText;
		if(this.retObj.indexOf("Error Msg :") == 0) {
			alert(this.retObj);
			if(propertyType == 1)
				dynamicObj.value = oldVal;
			else if (bolSetEIP)
				dynamicObj.innerHTML = "Error in processing.";
			return;
		}

		if(isMultipleObj) {
			var iIndexOf = this.retObj.indexOf("##########");
			if(iIndexOf == -1){
				dynamicObj.innerHTML = this.retObj;
				dynamicObj.scrollTop = dynamicObj.scrollHeight;	
				return;
			}else{
				dynamicObj.innerHTML = this.retObj.substring(0, iIndexOf);		
				this.retObj = this.retObj.substring(iIndexOf+10);
			}
			
			iIndexOf = this.retObj.indexOf("##########");
			
			if(iIndexOf == -1){
				dynamicObj2.innerHTML = this.retObj;
				return;
			}else{
				dynamicObj2.innerHTML = this.retObj.substring(0, iIndexOf);		
				if(this.dynamicObj3){					
					this.dynamicObj3.innerHTML = this.retObj.substring(iIndexOf+10);					
				}
			}
			return;
		}
		
		if(propertyType == 1)
		 	dynamicObj.value     = this.retObj;
		else if(propertyType == 2)
		 	dynamicObj.innerHTML = this.retObj;
		///must set here if AJAX returned something at all.
		if(this.retObj == "\r\n")
			bolReturnStrEmpty = true;
		else
			bolReturnStrEmpty = false;
			//dynamicObj.innerHTML = bolReturnStrEmpty;
	}
	else {
		if(propertyType == 1)
		 	dynamicObj.value     = "Processing..";
		else if(propertyType == 2 && bolSetEIP)
		 	dynamicObj.innerHTML = dynamicLoadingImg;
			
	}
}

function setEIP(bolNewVal){
		bolSetEIP = bolNewVal;
}