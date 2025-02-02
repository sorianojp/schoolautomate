<%@ page language="java" import="utility.*,java.util.Vector,eDTR.RestDays" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String[] strColorScheme = CommonUtil.getColorScheme(7);
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	if(bolMyHome)
		strColorScheme = CommonUtil.getColorScheme(9);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Rest Days Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function viewInfo(){
	this.SubmitOnce('form_');
}
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce('form_');
}
function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CancelEntries() {
	location = "./rest_days.jsp?emp_id="+escape(document.form_.emp_id.value);
}
function FocusID() {
<% if (WI.fillTextValue("my_home").compareTo("1") != 0) {%>
	document.form_.emp_id.focus();
<%}%>
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<body bgcolor="#D2AE72" onLoad="FocusID()" class="bgDynamic">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;String strTemp3 = null;
	String strImgFileExt = null;
	String strRootPath = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT-Rest Days(per Employee)","rest_days.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
boolean bolAllowSave = true;
boolean bolIsRestricted = false;//if restricted, can only use the emplyee from same college/dept only.
if(request.getSession(false).getAttribute("wh_restricted") != null)
	bolIsRestricted = true;

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
if(!bolIsRestricted) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"rest_days.jsp");
}														
														
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
			iAccessLevel  = 2;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//

														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//if id is same as logged in user, do not save.
String strEmpID = WI.fillTextValue("emp_id");
if(strEmpID.length() == 0)
	strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
strEmpID = WI.getStrValue(strEmpID);

if (WI.fillTextValue("emp_id").length() == 0 && strEmpID.length() > 0){
	request.setAttribute("emp_id",strEmpID);
}

if(strEmpID.equalsIgnoreCase((String)request.getSession(false).getAttribute("userId"))) {
	bolAllowSave = false;
	request.getSession(false).setAttribute("encoding_in_progress_id",null);
	//System.out.println("I am here.");
}


//if employee ID is entered and if restrcited , i have to check if user is allowed to view the employees Information.
if(bolIsRestricted && strEmpID.length() > 0) {
	if(!comUtil.isLoggedInUserBelongToCollegeOfEmployee(dbOP, request, null,strEmpID, null, null)) {
		dbOP.cleanUP();
		request.getSession(false).setAttribute("encoding_in_progress_id",null);
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=comUtil.getErrMsg()%></font></p>
		<%
		return;
	}	
}

//end of authenticaion code.
	RestDays rD = new RestDays();
	Vector vRetResult = null;
	Vector vEditInfo  = null;
	Vector vEmpRec    = null;
	
if(strEmpID.length() > 0) {
	//get Employee information here. 
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() ==0) {
		strErrMsg = authentication.getErrMsg();
	}
}

	if(WI.fillTextValue("page_action").length() > 0) {
		if(rD.operateOnRestDays(dbOP, request, Integer.parseInt(WI.fillTextValue("page_action"))) != null) {
			strErrMsg = "Operation successful.";
			strPreparedToEdit = "0";
		}
		else
			strErrMsg = rD.getErrMsg();
	}
	if(strPreparedToEdit.compareTo("1") == 0)  {
		vEditInfo = rD.operateOnRestDays(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = rD.getErrMsg();
	}
	
	//view all. 
	
	if(vEmpRec != null) {
		vRetResult = rD.operateOnRestDays(dbOP, request, 4);
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = rD.getErrMsg();
	}
%>	
<form action="./rest_days.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      EMPLOYEE REST DAYS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr>
      <td width="34%" height="25">&nbsp;Employee ID : 
      <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"  onKeyUp="AjaxMapName(1);"
		onBlur="style.backgroundColor='white'" value="<%=strEmpID%>" size="16" ></td>
      <td width="5%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a>	  </td>
      <td width="15%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>      </td>
      <td width="46%" valign="top"> <label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="4" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strEmpID%></font></strong>
      <input name="emp_id" type="hidden" value="<%=strEmpID%>" ></td>
    </tr>
<%}%>
  </table>
  <%
  if(vEmpRec != null){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="25%" height="25"></td>
      <td width="34%" valign="top" align="left"><br><font size="1">
	  <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}%> <strong><%=WI.getStrValue(strTemp)%></strong><br> <%=WI.getStrValue(strTemp2)%><br> <%=WI.getStrValue(strTemp3)%>
		</font></td>
      <td width="41%">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <img src="../../../upload_img/<%=strEmpID.toUpperCase()%>.<%=strImgFileExt%>" width=125 height=125 border=1>
	  </td>
    </tr>
  </table>
<% if (!bolMyHome && bolAllowSave) {%> 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">Effectivity Date From</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("valid_fr");
%>
	  <input name="valid_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.valid_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
else	
	strTemp = WI.fillTextValue("valid_to");
%>
        <input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(for valid rest days, leave &quot;effective date to&quot; 
        value empty)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Rest Days(in week day)</td>
      <td><select name="week_day">
	  <option value="">N/A</option>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
else	
	strTemp = WI.fillTextValue("week_day");
if(strTemp.compareTo("0") == 0) {%>
	  <option value="0" selected>Sunday</option>
<%}else{%>
	  <option value="0">Sunday</option>
<%}if(strTemp.compareTo("1") == 0) {%>
	  <option value="1" selected>Monday</option>
<%}else{%>
	  <option value="1">Monday</option>
<%}if(strTemp.compareTo("2") == 0) {%>
	  <option value="2" selected>Tuesday</option>
<%}else{%>
	  <option value="2">Tuesday</option>
<%}if(strTemp.compareTo("3") == 0) {%>
	  <option value="3" selected>Wednesday</option>
<%}else{%>
	  <option value="3">Wednesday</option>
<%}if(strTemp.compareTo("4") == 0) {%>
	  <option value="4" selected>Thursday</option>
<%}else{%>
	  <option value="4">Thursday</option>
<%}if(strTemp.compareTo("5") == 0) {%>
	  <option value="5" selected>Friday</option>
<%}else{%>
	  <option value="5">Friday</option>
<%}if(strTemp.compareTo("6") == 0) {%>
	  <option value="6" selected>Saturday</option>
<%}else{%>
	  <option value="6">Saturday</option>
<%}%>
	  </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Rest Days(specific date)</td>
      <td width="78%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
else	
	strTemp = WI.fillTextValue("rest_date");
%>
	  <input name="rest_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.rest_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="bottom">&nbsp;</td>
      <td height="18" valign="bottom"><font size="1">
        <%
			if(iAccessLevel > 1) {
			if(strPreparedToEdit.compareTo("0") == 0){%>
        <a href='javascript:PageAction("1","");'><img src="../../../images/save.gif" border="0"></a>click 
        to save entries 
        <%}else{%>
        <a href='javascript:PageAction("2","");'><img src="../../../images/edit.gif" border="0"></a>click 
        to modify entries 
        <%}
		}%>
        <a href="javascript:CancelEntries();"><img src="../../../images/cancel.gif" border="0"></a> 
        click to remove entries 
        </font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
<%}//if vEmpRec is not null.
 }
 

 
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF 
        EMPLOYEES REST DAYS</strong></td>
    </tr>
    <tr> 
      <td width="38%" height="26" align="center" class="thinborder"><strong>EFFECTIVITY 
        DATE </strong></td>
      <td width="34%" align="center" class="thinborder"><strong>REST DAY(S)</strong></td>
      <% if(!bolMyHome) {%> 
      <td width="16%" align="center" class="thinborder"><strong>EDIT</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>DELETE</strong></td>
      <%}%> 
    </tr>
<%
String[] astrConvertWeekDays = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday",""};
for(int i = 0; i < vRetResult.size(); i += 5){%>
   <tr> 
	 	<%
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 2));
			if(strTemp.length() == 0){
				strTemp = (String)vRetResult.elementAt(i + 3);
				strTemp += WI.getStrValue((String)vRetResult.elementAt(i + 4), " ::: ",""," - Present");
			}	
				
		%>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;
	  <%=astrConvertWeekDays[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 1),"7"))]%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2))%></td>
<% if (!bolMyHome) {%> 
      <td class="thinborder"> <div align="center">
	  <%if(iAccessLevel > 1) {%>
	  <a href='javascript:PreparedToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
	  <%}else{%>
		&nbsp;
		<%}%>
	  </div></td>
      <td class="thinborder"> <div align="center">
	  <%if(iAccessLevel == 2) {%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
	  <%}else{%>
		&nbsp;
		<%}%>
	  </div></td>
<%}%> 
    </tr>
<%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">  
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>