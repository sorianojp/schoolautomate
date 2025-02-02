<%@ page language="java" import="utility.*,java.util.Vector,eDTR.MultipleWorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(7);

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function CancelEntries() {
	location = "./set_emp_working_multiple.jsp?emp_id="+escape(document.form_.emp_id.value);
}

function AddRecord(){
	document.form_.page_action.value = "1";
	this.SubmitOnce('form_');
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.reloaded.value = "1";
	this.SubmitOnce('form_');
}
function DeleteRecord(index){
	var vProceed = confirm("Confirm delete for time in. Do you want to continue?");
	if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.info_index.value = index;
		this.SubmitOnce('form_');
	}else
		return;
}

function SearchEmployee(){	
	this.SubmitOnce("form_");
}


function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function viewHistory() {
	var pgLoc = "./set_working_history.jsp?emp_id=";
	
	if (document.form_.emp_id) 
		pgLoc +=  escape(document.form_.emp_id.value);
	
	pgLoc+="&my_home="+document.form_.my_home.value;

	var win=window.open(pgLoc,"view_history",'dependent=yes,width=600,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
-->
</script>
<body bgcolor="#D2AE72" 
<% if (WI.fillTextValue("viewonly").length() == 0){%>
	onLoad="document.form_.emp_id.focus();"
<%}%> class="bgDynamic">
<%
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;
  
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_emp_working_multiple.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"set_emp_working_multiple.jsp");	
														
// added for AUF
//strTemp = (String)request.getSession(false).getAttribute("userId");
//if (strTemp != null ){
//	if(bolMyHome){
//		iAccessLevel  = 1;
//		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
//	}
//}

//if (strTemp == null) 
//	strTemp = "";

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

//end of authenticaion code.
	MultipleWorkingHour whPersonal = new MultipleWorkingHour(); 
	Vector vPersonalInfo = null;
	Vector vRetResult = null;
	String[] astrConverAMPM = {"AM","PM"};
	int iSearchResult = 0;
	Vector vEditInfo  = null;
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
	String strPageAction = WI.fillTextValue("page_action");	
	boolean bolReloaded = WI.fillTextValue("reloaded").equals("1");
	int i = 0;
	String strReadOnly = "";
	
	strTemp = WI.fillTextValue("emp_id");
 	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	strTemp = WI.getStrValue(strTemp);
 
 	if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
		request.setAttribute("emp_id",strTemp);
	}
	
 	if(strPageAction.length() > 0){
		if(whPersonal.operateOnEmpMultipleLogs(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = whPersonal.getErrMsg();
		else{
			if(strPageAction.equals("1"))
				strErrMsg = "Saving Successful";
			strPreparedToEdit = "0";
		}
	}
	
	if(strPreparedToEdit.compareTo("1") == 0)  {
		vEditInfo = whPersonal.operateOnEmpMultipleLogs(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = whPersonal.getErrMsg();
	}

 	vRetResult = whPersonal.operateOnEmpMultipleLogs(dbOP, request, 4);
 	if(vRetResult == null)
		strErrMsg = whPersonal.getErrMsg();
	else
		iSearchResult = whPersonal.getSearchCount();
	
	
%>	
<form action="set_emp_working_multiple.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">
			<%if(WI.fillTextValue("viewonly").length() == 0){%>
			<a href="./working_hour_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>
			<%}%>
			<strong><font size=2>&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr valign="top"> 
      <td width="2%" height="30" valign="top">&nbsp;</td>
      <td width="14%" height="30">Employee ID</td>
			<%if(WI.fillTextValue("viewonly").length() > 0){
				strReadOnly = "readonly";	
			}%>	
      <td width="19%" height="30" valign="top"><input name="emp_id" type="text" class="textbox"  <%=strReadOnly%>
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=strTemp%>" size="16">      </td>
      <td width="5%" valign="top"><a href="javascript:OpenSearch();"></a></td>
      <td width="14%" valign="top"><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();"></td>
      <td width="46%" valign="top"><label id="coa_info"></label></td>
    </tr>
       <tr>
      <td colspan="6" height="18">&nbsp;</td>
    </tr>
  </table>
	<% 
	if (strTemp.length()  > 0){
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalInfo = authentication.operateOnBasicInfo(dbOP,request,"0");
			
		if (vPersonalInfo !=null){
	%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = WI.formatName((String)vPersonalInfo.elementAt(1), (String)vPersonalInfo.elementAt(2),
									(String)vPersonalInfo.elementAt(3),1); %>
      <td colspan="2" valign="top"><strong><%=strTemp%></strong></td>
      <td valign="top"><strong><%=WI.getStrValue((String)vPersonalInfo.elementAt(16))%></strong></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Position</font></td>
      <td height="15"><font size="1">College/Office</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = (String)vPersonalInfo.elementAt(15);%>
      <td colspan="2" valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
      <%
				if((String)vPersonalInfo.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vPersonalInfo.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vPersonalInfo.elementAt(13));
				if((String)vPersonalInfo.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vPersonalInfo.elementAt(14));
			}
%>
      <td valign="top"><strong><%=WI.getStrValue(strTemp)%></strong></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
 <%// if (!bolMyHome) {%> 
  <%if(WI.fillTextValue("viewonly").length() ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="19%"><u>Working Hour</u></td>
      <td width="23%">&nbsp;</td>
      <td width="56%">&nbsp;</td>
    </tr>
  
    <tr>
      <td height="25">&nbsp;</td>
      <td>Login Date : </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(2);
			else	
				strTemp = WI.fillTextValue("login_date");
			%>				
      <td colspan="2"><input name="login_date" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('form_','login_date','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('form_','login_date','/')"
	    value="<%=strTemp%>" size="10" maxlength="10">
        <a href="javascript:show_calendar('form_.login_date');"><img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Time In </td>
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(3);
			else	
				strTemp = WI.fillTextValue("hr_from");
			%>			
      <td colspan="2"><input name="hr_from" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" >
        : 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(4);
			else	
				strTemp = WI.fillTextValue("min_from");
			%>						
        <input name="min_from" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(5);
			else	
				strTemp = WI.fillTextValue("ampm_from");
			%>			
        <select name="ampm_from">
          <option value="0" >AM</option>
          <% if (strTemp.equals("1")) {%>
          <option value="1" selected>PM</option>
          <% }else {%>
          <option value="1">PM</option>
          <%}%>
        </select>
        to 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(6);
			else	
				strTemp = WI.fillTextValue("hr_to");
			%>					
        <input name="hr_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        : 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(7);
			else	
				strTemp = WI.fillTextValue("min_to");
			%>					
        <input name="min_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
			<%
			if(vEditInfo != null && vEditInfo.size() > 0 && !bolReloaded) 
				strTemp = (String)vEditInfo.elementAt(8);
			else	
				strTemp = WI.fillTextValue("ampm_to");
			%>	
        <select name="ampm_to" >
          <option value="0" >AM</option>
          <% if (strTemp.equals("1")){ %>
          <option value="1" selected>PM</option>
          <% }else{ %>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    
		
    <tr>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>		
		
    <tr> 
      <td height="10" colspan="4"><div align="center"><font size="1">
        <%
			if(iAccessLevel > 1) {
			if(strPreparedToEdit.compareTo("0") == 0){%>
        <a href='javascript:AddRecord();'><img src="../../../../images/save.gif" border="0"></a>click 
        to save entries
        <%}else{%>
        <a href='javascript:EditRecord();'><img src="../../../../images/edit.gif" border="0"></a>click 
        to modify entries
        <%}
		}%>
        <a href="javascript:CancelEntries();"><img src="../../../../images/cancel.gif" border="0"></a> click to remove entries </font></div></td>
    </tr>
		<%}%>
<%//} // do not show if my home%>
  </table>
  <%}%>

<%if(vRetResult != null && vRetResult.size() > 0){%>
    <% 
	int iPageCount = iSearchResult/whPersonal.defSearchSize;		
	if(iSearchResult % whPersonal.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="SearchEmployee();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select>
    </font></td>
  </tr>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
      CURRENT WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%></td>
    </tr>
    <tr> 
      <td width="15%" height="26" align="center" class="thinborder"><strong>LOGIN  
      DATE </strong></td>
      <td width="57%" align="center" class="thinborder"><strong>TIME</strong></td>
	    <td width="16%" align="center" class="thinborder"><strong>POSTED</strong></td>
	    <%//if(!bolMyHome){%> 
		<%if(WI.fillTextValue("viewonly").length() ==0){%>
      <td width="16%" align="center" class="thinborder"><strong>EDIT</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>DELETE</strong></td>
		<%}%>
	<%//}%> 
    </tr>
<%
 for(i = 0; i < vRetResult.size(); i += 25){%>
   <tr> 
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 2))%></td>
			<%
			strTemp = (String)vRetResult.elementAt(i + 3);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+5))];
			
			// time to here
			strTemp += " - " + (String)vRetResult.elementAt(i + 6);
			strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+7),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vRetResult.elementAt(i+8))];
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;</td>
      <% //if (!bolMyHome) {%> 
	<%if(WI.fillTextValue("viewonly").length() ==0){%>
      <td class="thinborder"> <div align="center">
	  <%if(iAccessLevel > 1) {%>
	  <a href='javascript:PreparedToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a>
	  <%}%>
	  </div></td>
      <td class="thinborder"> <div align="center">
	  <%if(iAccessLevel == 2) {%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a>
	  <%}%>
	  </div></td>
		<%}%>
<%//}%> 
    </tr>
<%}%>
  </table>
	<%}// if vRetResult != null %>
<%}//if (strTemp.length()  > 0)%>
<!-- here lies the great mysteries of and future-->
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
  <input type="hidden" name="page_action">
	<input type="hidden" name="reloaded">	
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
 	<input type="hidden" name="viewonly" value="<%=WI.fillTextValue("viewonly")%>">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
