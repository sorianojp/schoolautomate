/**
//to make a checkbox readonly.. 
onClick="return false" -- it is not working i am nto sure why.. use this instead ,, use disabled parameter.. 
<%
 if(strTemp.equals("1")) {
 	strErrMsg = " selected"; 
	strDisabled = "";
}else {
	strErrMsg = "";
	if(strSchCode.startsWith("UB"))
		strDisabled = "disabled='disabled'";
}%>
        <option value="1"<%=strErrMsg%><%=strDisabled%>>1st</option>

or apply this.
<select id="countries" onfocus="this.defaultIndex=this.selectedIndex;" onchange="this.selectedIndex=this.defaultIndex;">



**/
//TO CLOSE WINDOW.
var closeWnd ="";
function CloseWnd() {
	if(closeWnd == 1)
		window.setTimeout("javascript:window.close();", 2000);
}
/**
* Call this to print to default printer without printer dialog.. NOTE : it works only in IE
*/
function autoPrint() {
	document.body.insertAdjacentHTML("beforeEnd", "<object id='idWBPrint' width=0 height=0 classid='clsid:8856F961-340A-11D0-A96B-00C04FD705A2'></object>");
	idWBPrint.ExecWB(6, -1);
	idWBPrint.outerHTML = ""; 
}


/**
*	Call this to display help file.
*/
function Help(URL)
{
    var win=window.open(URL,"HelpFile",
    'dependent=yes,width=300,height=300,screenX=200,screenY=300,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
    win.focus();
}
function expandingWindow(URL) 
{
    var heightspeed = 20; // vertical scrolling speed (increase speed for faster expansion)
    var widthspeed = 40;  // horizontal scrolling speed (increase speed for faster expansion)
    var leftdist = 0;    // distance to left edge of window
    var topdist = 0;     // distance to top edge of window
   if (document.all) 
   {
	var winwidth = window.screen.availWidth - leftdist;
	var winheight = window.screen.availHeight - topdist;
	var sizer = window.open("","","left=" + leftdist + ",top=" + topdist + ",width=1,height=1,scrollbars=auto");
	for (sizeheight = 1; sizeheight < winheight; sizeheight += heightspeed) 
	{
	    sizer.resizeTo("1", sizeheight);
   	}
	for (sizewidth = 1; sizewidth < winwidth; sizewidth += widthspeed) 
	{
	    sizer.resizeTo(sizewidth, sizeheight);
	}
	sizer.resizeTo(winwidth,winheight);
	
	sizer.location = URL;
   }
   else
	window.location = URL;
}

function fullScreen(URL) 
{
     window.open(URL, '', 'fullscreen=yes, scrollbars=auto');
}
	
/**
* This is called for every school year entry. Set the school year to to READONLY, and call this 
* script on OnKeyUp in Schoolyear from Example keep it in sy_from text box.: 
* onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'  and make sy_to readonly="yes" 
* <script language="JavaScript" src="../../jscript/common.js"></script>
*/	
function DisplaySYTo(strFormName,strSYFromFieldName,strSYToFieldName) {
	strSYFromVal = eval('document.'+strFormName+'.'+strSYFromFieldName+'.value');
	if(strSYFromVal.length == 0)
		return;
		
	var newSYFromVal = "";
	var lastChar;
	for(i = 0; i < strSYFromVal.length; ++i) {
		lastChar = 	strSYFromVal.charAt(i);
		if(lastChar == '0' || lastChar == '1' || lastChar == '2' || lastChar == '3' || 
			lastChar == '4' || lastChar == '5' || lastChar == '6' || lastChar == '7' || 
			lastChar == '8' || lastChar == '9') 
				newSYFromVal += lastChar;
	}
	strSYFromVal = newSYFromVal;
	eval('document.'+strFormName+'.'+strSYFromFieldName+'.value="'+strSYFromVal+'"');
	
	if(strSYFromVal.length == 4)
		eval('document.'+strFormName+'.'+strSYToFieldName+'.value = '+(eval(strSYFromVal) + 1) );
	if(strSYFromVal.length < 4)
		eval('document.'+strFormName+'.'+strSYToFieldName+'.value =""');
}
//call for the fileds having only integer. write this in on key up and on blurr.
//example onblur="AllowOnlyInteger('cmaintenance','sy_from');style.backgroundColor='white'"  onKeyUP="AllowOnlyInteger('cmaintenance','sy_from')">
function AllowOnlyInteger(strFormName,strFieldNameToValidate) {
	strIntVal = eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value');
	if(strIntVal.length == 0)
		return;
		
	var newIntVal = "";
	var lastChar;
	for(i = 0; i < strIntVal.length; ++i) {
		lastChar = 	strIntVal.charAt(i);
		if(lastChar == '0' || lastChar == '1' || lastChar == '2' || lastChar == '3' || 
			lastChar == '4' || lastChar == '5' || lastChar == '6' || lastChar == '7' || 
			lastChar == '8' || lastChar == '9' ) 
				newIntVal += lastChar;
	}
	strIntVal = newIntVal;
	eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value="'+strIntVal+'"');
}

//call for the fileds having only integer. write this in on key up and on blurr.
//example onblur="AllowOnlyInteger('cmaintenance','sy_from','/');style.backgroundColor='white'"  onKeyUP="AllowOnlyInteger('cmaintenance','sy_from')">
function AllowOnlyIntegerExtn(strFormName,strFieldNameToValidate, strAllowedChar) {
	strIntVal = eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value');
	if(strIntVal.length == 0)
		return;
		
	var newIntVal = "";
	var lastChar;
	var lastOccurance = 0;	
	for(i = 0; i < strIntVal.length; ++i) {
		if(lastChar == 	strIntVal.charAt(i)) {
			lastChar = 	strIntVal.charAt(i);
			//Allowed Char should occur only once.
			if(strAllowedChar.indexOf(lastChar) != -1) {
				if(lastOccurance == 0)
					lastOccurance = 1;
				else	
					++lastOccurance;
			}
			else	
				lastOccurance = 0;
		}
		else {
			lastChar = 	strIntVal.charAt(i);	
			if(strAllowedChar.indexOf(lastChar) != -1)
				lastOccurance = 1;	
			else	
				lastOccurance = 0;
		}	
		if(lastChar == '0' || lastChar == '1' || lastChar == '2' || lastChar == '3' || 
			lastChar == '4' || lastChar == '5' || lastChar == '6' || lastChar == '7' || 
			lastChar == '8' || lastChar == '9' || lastOccurance == 1) 
				newIntVal += lastChar;
	}
	strIntVal = newIntVal;
	eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value="'+strIntVal+'"');
}


//call for currency.
function AllowOnlyFloat(strFormName,strFieldNameToValidate) {
	strIntVal = eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value');
	if(strIntVal.length == 0)
		return;
		
	var newIntVal = "";
	var lastChar;
	
	var strDOTUsed = "0";
	var strNegUsed = "0";
	
	for(i = 0; i < strIntVal.length; ++i) {
		lastChar = 	strIntVal.charAt(i);
		if(lastChar == '.') {
			if(strDOTUsed == "1")
				continue;
			strDOTUsed = "1";
		}
		if(lastChar == '-') {
			if(i > 0) 
				continue;
			if(strNegUsed == "1")
				continue;
			strNegUsed = "1";
		}
		if(lastChar == '0' || lastChar == '1' || lastChar == '2' || lastChar == '3' || 
			lastChar == '4' || lastChar == '5' || lastChar == '6' || lastChar == '7' || 
			lastChar == '8' || lastChar == '9' || lastChar == '.' || lastChar == '-') 
				newIntVal += lastChar;
	}
	strIntVal = newIntVal;
	eval('document.'+strFormName+'.'+strFieldNameToValidate+'.value="'+strIntVal+'"');
}
//objInput = document.form_.inputbox; strAllowedChar = "123456789";
function AllowOnlyChar(objInput, strAllowedChar) {
	strIntVal = objInput.value;
	if(strIntVal.length == 0)
		return;
		
	var newIntVal = "";
	var lastChar;
	var lastOccurance = 0;	
	for(i = 0; i < strIntVal.length; ++i) {
		lastChar = strIntVal.charAt(i);
		if(strAllowedChar.indexOf(lastChar) == -1)
			continue;
		newIntVal += lastChar;
	}
	strIntVal = newIntVal;
	objInput.value= strIntVal;
}

/*************** call to auto scroll list box. *****************************
example. onKeyUp = "AutoScrollList('form_.filter_sub','form_.sub_index',true);"
draw back -- too slow. Use this for list not exceeding 500 entries.
**/
var iLastPos = 0; 
var lastStr = "";
function AutoScrollList(strFilter,strDropList,bolIgnoreCase){
	strName = eval("document."+strFilter+".value");
	var selectedValue; 
	if (strName.length == 0 || eval("document."+strDropList+".length== 1") ){
		eval("document."+strDropList+".selectedIndex = 0");
		return;
	}
	if(lastStr.length < strName.length) {
		lastStr += strName.charAt(strName.length - 1); 
		if(lastStr != strName)
			iLastPos = 0;
	}
	else if(lastStr.length = strName.length) {
		iLastPos = 0;
	}
	
	lastStr = strName;
	//alert(iLastPos);alert(lastStr);alert(strName);
	var i = iLastPos;
	var dropListLen = eval("document."+strDropList+".length");
	var dropListLenOrig = dropListLen;
	var istrCompare = 0;
	for (; i < dropListLen; i = i + 1){
		selectedValue = eval("document."+strDropList+"["+i+"].text");
		istrCompare = this.startsWith(strName, selectedValue,bolIgnoreCase);
		
		if(istrCompare == 0)
			break;
		if(iLastPos != 0 && istrCompare == -1)
			break; 					
	}
	if (i< eval("document."+strDropList+".length")){
		eval("document."+strDropList+".selectedIndex =" + i);
		iLastPos = i;
	}
}
///use this to scroll bigger lists -> call <%=dbOP.constructAutoScrollHiddenField()%> to construct indexes.
//strFilter = 'filter_sub', strDropList = dropList, formName = form_
function AutoScrollListSubject(strFilterFieldName,strDropListFieldName,bolIgnoreCase,strFormName){
	//alert("I am here");
	strFilterVal = eval("document."+strFormName+"."+strFilterFieldName+".value");
	var selectedValue; 
	var dropListLen = eval("document."+strFormName+"."+strDropListFieldName+".length"); 
	var iStartPos   = 0;//pointer
	var iEndPos     = 0;//pointer
	var searchChar  = "";
	var strAllowedIndexList = eval("document."+strFormName+".hidden_fields_val.value"); 
	if(strAllowedIndexList.length ==0) 
		return;
	
	if (strFilterVal.length == 0 || eval(dropListLen)== 1 ){
		eval("document."+strFormName+"."+strDropListFieldName+".selectedIndex = 0");
		return;
	}
	
	searchChar = strFilterVal.charAt(0).toLowerCase();
	if(strAllowedIndexList.indexOf(searchChar) == -1)
		return;
		
	iStartPos = eval("document."+strFormName+".hidden_start_"+searchChar+".value");
	iEndPos = eval("document."+strFormName+".hidden_end_"+searchChar+".value");
	//sometimes, subject list has first char as "Select a subject"
	selectedValue = eval("document."+strFormName+"."+strDropListFieldName+"["+iStartPos+"].text");
	
	if(selectedValue.toLowerCase().charAt(0) != strFilterVal.toLowerCase().charAt(0))
		++iStartPos;
	//alert(iStartPos);alert(iEndPos);
	for (i = iStartPos; i <= iEndPos; i = eval(i) + 1){
		selectedValue = eval("document."+strFormName+"."+strDropListFieldName+"["+i+"].text");
		//alert(strFilterVal);alert(selectedValue);
		istrCompare = this.startsWith(strFilterVal, selectedValue,bolIgnoreCase);
		if(istrCompare == 0)
			break;
	}
	if (i< eval(dropListLen)) {
		eval("document."+strFormName+"."+strDropListFieldName+".selectedIndex =" + i);
	}
}





/***************** end of list box scroll *******************************/
//returns 0 = same, 1 = greater, -1 = smaller.
//startsWith("Iam","IamChecking",true) returns 0.
function startsWith(strSource, strDestination, bolIgnoreCase){
	if (strSource.length > strDestination.length) 
		return 1;
	if (bolIgnoreCase){
		strSource = strSource.toLowerCase();
		strDestination = strDestination.toLowerCase();
	}
	if (strSource == strDestination) 
		return 0;
	for(var i = 0; i <strSource.length; i++){
		if (strSource.charAt(i) > strDestination.charAt(i))
			return 1;
		else if (strSource.charAt(i) < strDestination.charAt(i))
			return -1;
	}
	return 0;
}

//both date should be in mm/dd/yyyy format., if bolShowOnlyAge is true, it shows years only.
//to Print : calculateAge(document.form_.dob.value,'<%=WI.getTodaysDate(1)%>')
function calculateAge(strInputDate,strTodaysDate, bolShowOnlyAge) {
	var mmInput = ""; var ddInput = ""; var yyyyInput = "";
	var mmToday = ""; var ddToday = ""; var yyyyToday = "";
	
	var yyyyDif; var mmDif; var ddDif;
	
	var retVal;//28 years 2 months 3 days.
	var iTokenCount = 0;
	if(strInputDate.length == 0 || strTodaysDate.length == 0) 
		return "";
	for(var i =0; i < strInputDate.length; ++i) {
		if(strInputDate.charAt(i) == '/') {
			++iTokenCount;
			continue;
		}
		if(iTokenCount ==0) 
			mmInput += strInputDate.charAt(i);
		else if(iTokenCount ==1) 
			ddInput += strInputDate.charAt(i);
		else if(iTokenCount ==2) 
			yyyyInput += strInputDate.charAt(i);
	}
	if(mmInput.length ==0 || ddInput.length ==0 || yyyyInput.length ==0 || eval(mmInput) > 12 || eval(yyyyInput) < 1600 || eval(ddInput) > 31)
		return "";
	iTokenCount = 0;
	for(var i =0; i < strTodaysDate.length; ++i) {
		if(strTodaysDate.charAt(i) == '/') {
			++iTokenCount;
			continue;
		}
		if(iTokenCount ==0) 
			mmToday += strTodaysDate.charAt(i);
		else if(iTokenCount ==1) 
			ddToday += strTodaysDate.charAt(i);
		else if(iTokenCount ==2) 
			yyyyToday += strTodaysDate.charAt(i);
	}
	if(mmToday.length == 0 || yyyyToday.length == 0 || ddToday.length == 0 || eval(mmToday) > 12 || eval(yyyyToday) < 1600 || eval(ddToday) > 31)
		return "";
//	alert(mmInput);	alert(ddInput); alert(yyyyInput);
//	alert(mmToday); alert(ddToday); alert(yyyyToday);
		
	yyyyDif = eval(yyyyToday) - eval(yyyyInput); 
	mmDif   = eval(mmToday)   - eval(mmInput); 
	ddDif   = eval(ddToday)   - eval(ddInput);
	
	if (mmDif == 0) {
      if (ddDif < 0)
        --yyyyDif;
    }

    if (mmDif < 0)
      --yyyyDif;
	return (yyyyDif + " Yr(s)");
}



/**
* Call this for text area only : 
<textarea name="myTextArea" onkeyup='return isMaxLen("document.form_.myTextArea","128")'></textarea>

function isMaxLen(strFieldName,strMaxLen){
	alert(strFieldName);alert(strMaxLen);
	var lenEntered = eval(strFieldName+'.value.length');
	var valEntered = eval(strFieldName+'.value');
	alert(lenEntered);
	alert(valEntered);
	
//	if (eval(lenEntered) > eval(strMaxLen) )
//	eval(strFieldName+'.value='+valEntered.substring(0,strMaxLen));

}*/
/**
* Call this for text area only : <textarea maxlength="40" onkeyup="return isMaxLen(this)"></textarea>
*/
function isMaxLen(obj){
	var mlength=obj.getAttribute? parseInt(obj.getAttribute("maxlength")) : ""
	if (obj.getAttribute && obj.value.length>mlength)
	obj.value=obj.value.substring(0,mlength)
}
/**
* To user insert/ delete row - use table ID as myADTable
* <table id="myADTable" border="1">
* to delete pass the row ID as -> 
*   <td><input type="button" value="Delete" onclick="deleteRow(this.parentNode.parentNode.rowIndex)"></td>
* Example to remove row
* 	document.bgColor = "#FFFFFF";
*   document.getElementById('myADTable1').deleteRow(0);
*   alert("Click OK to print this page");
*	window.print();//called to remove rows, make bk white and call print.
*
* to insert row - Call method as insRow(iRowID, iNOOfColoumns, "val","val","val"), "val" = value sof column for example call like this
* insRow(2, 3, "Testing", "this","value");
*
*	To know number of rows in a table.. 
var oRows = document.getElementById('MyTable').getElementsByTagName('tr');
var iRowCount = oRows.length;
*
* To insert school name 
* 	var strInfo = "<div align=\"center\"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>"+"<br>";
*	strInfo +="<font size =\"1\"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font>"+"<br>";
*	strInfo +="<font size =\"1\"><%=SchoolInformation.getInfo1(dbOP,false,false)%></font> </div>";
*	document.bgColor = "#FFFFFF";
*	document.getElementById('myTable1').deleteRow(0);
*	document.getElementById('myTable1').deleteRow(0);
*		
*	document.getElementById("myADTable").getElementsByTagName("tr")[0].style.backgroundColor ="#FFFFFF";
*	this.insRow(0, 1, strInfo);

//////// valuable code.. how to determine what row number is clicked.. 
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" id="myADTable1" onClick="findRowNumber(event.target||event. srcElement);">
above line the table must have to have row number set.. 
then, make a java script method.. 
function findRowNumber(element) { // element is a descendent of a tr element
	while(element.tagName.toLowerCase() != "tr") {
		element = element.parentNode; // breaks if no "tr" in path to root
	}
	//alert(element.rowIndex);
	rowID = element.rowIndex;
	return;
}

*/

function deleteTableRow(iRowID){
    document.getElementById('myADTable').deleteRow(iRowID);
}
function insRow(){	
	var argv = insRow.arguments;
	var iNoOfRow = argv[1];
    var x=document.getElementById('myADTable').insertRow(argv[0]);
    for(var i = 0; i < iNoOfRow; i++) {
    	x.insertCell(i).innerHTML = argv[i + 2];
    }
}
function insRowVarTableID(strTableID){
	var argv = insRowVarTableID.arguments;
	var iNoOfRow = argv[2];
    var x=document.getElementById(strTableID).insertRow(argv[1]);
    for(var i = 0; i < iNoOfRow; i++) {
    	x.insertCell(i).innerHTML = argv[i + 3];
    }
}
/**
* This is added to avoid blank page due to change in drop down list - while page is submit
* for example in registration page/ grade sheet page/ class program page.
* Call this to submit the page ONCE.
*/
var isSubmitOnceCalled = 0;
function SubmitOnce(formName) {
	if(isSubmitOnceCalled == 1)
		return;
	isSubmitOnceCalled = 1;
	eval('document.'+formName+'.submit()');
}
/// use this if button is used.. this method disables the submit button.
/// Example :
/// <form name="" action="" method="" onSubmit="SubmitOnceButton(this);">

function SubmitOnceButton(theform) {
//if IE 4+ or NS 6+
	//form is submitted here.
	if (document.all||document.getElementById)
	{
	//screen thru every element in the form, and hunt down "submit" and "reset"
		for (i=0;i<theform.length;i++) {
			var tempobj=theform.elements[i]
			if(tempobj.type.toLowerCase()=="submit"||tempobj.type.toLowerCase()=="reset")
			//disable em
			tempobj.disabled=true
		}
	}
}
/**
*	Example to use.
	<textarea name="notes" cols="35" rows="2" class="textbox"
	  onfocus="CharTicker('form_','256','notes','ticker2');style.backgroundColor='#D3EBFF'" onBlur="CharTicker('form_','256','notes','ticker2');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','256','notes','ticker2');"><%=strTemp%></textarea><font size="1">
	  <input type="text" name="ticker2" size="3" class="textbox_noborder" readonly="readonly"
	  style="font-size:9px">
	  
**/
function CharTicker(strFormName, strMaxLen, strTickerField, strTickerValue)
{
	var objVal = eval('document.'+strFormName+'.'+strTickerField);
	var remLen = eval(strMaxLen) - objVal.value.length;
	if(remLen < 0)
		remLen = 0;
	if(remLen == 0) 
		objVal.value = objVal.value.substring(0,eval(strMaxLen));
	
	var objDisp = eval('document.'+strFormName+'.'+strTickerValue);
	objDisp.value = "("+remLen+")";
}

/**
*	Added for opacity of image.. Example :: 
*	add style 
	<style type="text/css">
		#im {
			FILTER: alpha(opacity=40)
		}
	</style>
	
	Image tag must have  id="im" onMouseOver="high(this);" onMouseOut="low(this);"
			<img src="../../images/update.gif" border="0" id="im" onMouseOver="high(this);" onMouseOut="low(this);">
*/
function high(which2) {
	if (navigator.appName == "Microsoft Internet Explorer") {
		theobject=which2;
		highlighting=setInterval("highlightit(theobject)",40);
	}
}
function low(which2) {
	if (navigator.appName == "Microsoft Internet Explorer") {
		clearInterval(highlighting);
		which2.filters.alpha.opacity=40;
	}
}
function highlightit(cur2) {
	if (navigator.appName == "Microsoft Internet Explorer") {
		if(cur2.filters.alpha.opacity<100)
			cur2.filters.alpha.opacity+=5
		else if(window.highlighting)
			clearInterval(highlighting)
	}
}
/************ end of opacity *****************/


// Verify Date in mm/dd/yyyy format
function VerifyMMDDYYYY(textObj) {//alert(textObj.value);
	var strDate = textObj.value;
	var iLen = strDate.length;
	
	if(iLen == 0) {
		alert("Pelase enter date in mm/dd/yyyy format.");
		textObj.focus();
		return false;
	}
	var strMM   = "";
	var strDD   = "";
	var strYYYY = "";
	
	var charPt = "";
	for(var i = 0; i < iLen; ++i) {
		charPt = strDate.charAt(i);
		if(charPt == "/")
			break;
		strMM = strMM + charPt;
	}
	for(var i = strMM.length + 1; i < iLen; ++i) {
		charPt = strDate.charAt(i);
		if(charPt == "/")
			break;
		strDD = strDD + charPt;
	}
	for(var i = iLen; i > 0; --i) {
		charPt = strDate.charAt(i);
		if(charPt == "/")
			break;
		strYYYY = charPt + strYYYY;
	}
	//alert("MM : "+strMM+", DD : "+strDD+", YYYY :"+strYYYY);
	if(eval(strMM) > 12 || eval(strMM) <= 0 || eval(strDD) > 30 || eval(strDD) <=0 || eval(strYYYY) <=1900 || eval(strYYYY) > 3000) {
		alert("Wrong date format.");
		return false;
	}
	return true;
}



//onKeyUp="mask(this.value,this,'2,5','/', event.keyCode);"
function mask(strValue, textbox, loc, delim, strKeyCode){	

	//if(strValue.length >= 10)
	//	return;
	
	if(strKeyCode =='191'){// 191 == character '/'
		//if the user input / check the length	
		//if(strValue.length != 3 && strValue.length != 6)			
		if(strValue.charAt(strValue.length - 1) == delim)
			textbox.value = strValue.substring(0, strValue.length -1);		
		return;		
	}
	
	var iCount = 0;
	for (var k = 0; k <= strValue.length; k++){	
		if(strValue.charAt(k) == delim)
			iCount++;
	}
	var locs = loc.split(','); 
	for (var i = 0; i <= locs.length; i++){
		for (var k = 0; k <= strValue.length; k++){
			if (k == locs[i] && iCount < 2){				
				if(strValue.length > locs[i]){
					if (strValue.substring(k, k+1) != delim)
						strValue = strValue.substring(0,k) + delim + strValue.substring(k,strValue.length);						
				//}else if(strValue.length > 5){
				//	if (strValue.substring(k, k+1) != delim)
				//		strValue = strValue.substring(0,k) + delim + strValue.substring(k,strValue.length);						
				}				
			}
		}
	}	
	textbox.value = strValue;
}

//format is mm/dd/yyyyy
//onBlur="maskValidation(this.value, this);"
function maskValidation(strValue, strField){
	if(strValue.length == 0 )
		return;
		
	var strErrMsg = "";
	if(strValue.length < 10)
		strErrMsg = "Date Format : mm/dd/yyyy";
	else{
		var strMM = strValue.substring(0, strValue.indexOf("/"));
		strValue  = strValue.substring(strValue.indexOf("/") + 1);
		var strDD = strValue.substring(0, strValue.indexOf("/"));
		strValue  = strValue.substring(strValue.indexOf("/") + 1);		
		var strYYYY = strValue;
		
		if(  isNaN(strMM) || isNaN(strDD) || isNaN(strYYYY) || 
			eval(strMM) > 12 || eval(strMM) <= 0 || eval(strDD) > 31 || eval(strDD) <=0 || eval(strYYYY) <=1900 || eval(strYYYY) > 3000) 
			strErrMsg = "Date Format : mm/dd/yyyy";
	}

	if(strErrMsg.length > 0){		
		alert(strErrMsg);
		setTimeout(function(){strField.focus();},1);			
	}
	
	
}






/**
* Use this when I need to have only the numbers in the text box - Allowed digits are -> 0123456789.
*	EXAMPLE : 
*	<input type="text" name=specialTB 
*		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
*
* for only digits > 0123456789
*	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
*
* for characters without digits > 0123456789.
*	onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;"
*
* for uppper case in text box.
*	 OnKeyUP="javascript:this.value=this.value.toUpperCase();"
* -> to block single quote in E_SUBJECT_SECTION, key code is 39, double quote = 34
* -> event.keyCode == 115 = "s" event.keyCode ==83 -> S
* -> event.keyCode == 47 -> / (this is used in grade like 80/50 -> pass/fail)
*
* STYLY FOR COMBO BOX
* <select name="loc_index" 
* style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;">
*/


/**** ********************************************************************
*******how to set stop the the page from scrolling up and down.***********************
*************************************************************************
 <input type="input" name="set_focus" size="1" maxlength="1" readonly
 	style="background-color: #D2AE72;border-style: inset;border-color: #D2AE72; border-width: 0px">

<%
if(WI.fillTextValue("fake_focus").compareTo("1") ==0){%>
<script language="JavaScript">
document.advising.set_focus.focus();
</script>
<%}%>
<input type="hidden" name="fake_focus" value="<%=WI.fillTextValue("fake_focus")%>">

---To make check box readonly., add this property
 checked="checked" onclick="return false" onkeydown="return false"


Example -- Advising -> Subject(s) from other courses -> add subjects.
*************************************************************************/
/**************************** TO PLAY SOUND ***************************
<head>
	<EMBED SRC="../jscript/error_attendance.wav" 
       NAME="error" 
       AUTOSTART="FALSE" 
       MASTERSOUND 
	   LOOP="TRUE"
      HIDDEN=true>
</head>
    document.error.play(); //PLAYS SOUND.

//in below -- it pays sound automatically -- use the code below. 
<EMBED SRC="../../jscript/error_attendance.wav" 
       NAME="error" 
<%
if(strErrMsg != null){%>
       AUTOSTART="TRUE" 
<%}else{%>
       AUTOSTART="FALSE" 
<%}%>
       MASTERSOUND 
	   LOOP="TRUE"
	   HIDDEN="true">
**********************************************************************/

/***************************************** INSERT PAGE BREAK - WORKS >IE5.0 AND >NS6.0 **
<!-- introduce page break here -->
<DIV style="page-break-after:always">&nbsp;</DIV>
--> Disadvantage is one empty page will be printed at the end of printing... well it is acceptable.
*****************************************************************************************/