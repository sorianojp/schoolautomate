////////////////This is same as ajax.js, only that this is a copy to handle more than one ajax at a time... 
/**
var iStartTime = 0;
var iCurTime   = 0;//to get the time delay.
var iTimeDelay = 300;//400ms time delay in sending
**/

var xmlHttp2;
var strErrMsg2;

var dynamicObj2;
var propertyType2; //1 = .value, 2 = .innerHTML
var retObj2;// value returned from server.

var bolReturnStrEmpty2;///if return string is empty , set it to true.
var strPrevEntry2;//stores previous entry. if prev result is empty and new entry starts with pre. entry, i must return right away.

var oldVal2;

var dynamicLoadingImg2 = "Processing...";
function InitXmlHttpObject3(dynamicObj,propertyType) {
	//if(iStartTime == 0)
	//	iStartTime = new Date().getTime();//time in ms.

	this.xmlHttp2 = null;
	this.retObj2  = null;

	this.dynamicObj2   = dynamicObj;
	this.propertyType2 = propertyType;
	if(propertyType == 1)
		oldVal2 = this.dynamicObj2.value;
	
	try {// Firefox, Opera 8.0+, Safari
	  xmlHttp2=new XMLHttpRequest();
  	}
	catch (e){// Internet Explorer
		try {
			xmlHttp2=new ActiveXObject("Msxml2.XMLHTTP");
		}
		catch (e) {
			xmlHttp2=new ActiveXObject("Microsoft.XMLHTTP");
		}
	}
}
function InitXmlHttpObject4(dynamicObj,propertyType, dynamicLoadingImg) {
	InitXmlHttpObject3(dynamicObj,propertyType);
	this.dynamicLoadingImg2 = dynamicLoadingImg;
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

function processRequest2(strCompleteURL) {
	//iCurTime  = new Date().getTime();//time in ms.
	//if( (iCurTime - iStartTime) < iTimeDelay) {
	////	iStartTime = iCurTime;
	//	return;
	//}
	//alert(iCurTime - iStartTime);

	xmlHttp2.onreadystatechange=stateChanged2;
	xmlHttp2.open("GET",strCompleteURL,true);
	xmlHttp2.send(null);

	//iStartTime = iCurTime;
}
function processRequestPOST(strURL, strParam) {
	xmlHttp2.onreadystatechange=stateChanged2;
	xmlHttp2.open("POST",strURL,true);
	
	xmlHttp2.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
	xmlHttp2.setRequestHeader("Content-length", strParam.length);
	xmlHttp2.setRequestHeader("Connection", "close");

	xmlHttp2.send(strParam);

	//iStartTime = iCurTime;
}

function stateChanged2() {
	if (xmlHttp2.readyState==4) {
          if (!xmlHttp2.status == 200) {//bad request.
            dynamicObj2.innerHTML = "Connection to server is lost";
            return;
          }

		//alert(xmlHttp.responseText); -- uncomment this to view error/exception...
		this.retObj2 = xmlHttp2.responseText;
		if(this.retObj2.indexOf("Error Msg :") == 0) {
			alert(this.retObj2);
			if(propertyType2 == 1)
				dynamicObj2.value = oldVal2;
			else
				dynamicObj2.innerHTML = "Error in processing.";
			return;
		}
		if(propertyType2 == 1)
		 	dynamicObj2.value     = this.retObj2;
		else if(propertyType2 == 2)
		 	dynamicObj2.innerHTML = this.retObj2;
		///must set here if AJAX returned something at all.
		if(this.retObj2 == "\r\n")
			bolReturnStrEmpty2 = true;
		else
			bolReturnStrEmpty2 = false;
			//dynamicObj.innerHTML = bolReturnStrEmpty;
	}
	else {
		if(propertyType2 == 1)
		 	dynamicObj2.value     = "Processing..";
		else if(propertyType2 == 2)
		 	dynamicObj2.innerHTML = dynamicLoadingImg2;
	}
}
