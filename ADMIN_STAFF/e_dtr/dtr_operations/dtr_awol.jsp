<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut" %>
<%
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.form_.page_action.value = 4;
		document.form_.prepareToEdit.value = 0;
		document.form_.show_list.value = 1;
	}

	function CancelRecord(){
		location = "./dtr_awol.jsp?emp_id=" + document.form_.emp_id.value + 
			"&date_from="+document.form_.date_from.value+
			"&date_to="+document.form_.date_to.value;
	}
	
	function PrepareToEdit(index,bTimeInTimeOut){
 		document.form_.prepareToEdit.value = 1;
 		document.form_.info_index.value = index;
	}

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
}

	function focusID() {
		document.form_.emp_id.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
 -->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","dtr_awol.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"dtr_awol.jsp");
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

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////



TimeInTimeOut TInTOut = new TimeInTimeOut();
Vector vEditInfo = null;
Vector vRetResult =  null;
Vector vPersonalDetails = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (TInTOut.operateOnAWOL(dbOP,request,0) != null){
				strErrMsg = " Record removed successfully ";
			}else{
				strErrMsg = TInTOut.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (TInTOut.operateOnAWOL(dbOP,request,1) != null){
				strErrMsg = " Record posted successfully ";
			}else{
				strErrMsg = TInTOut.getErrMsg();
			}
		}else if(strPageAction.compareTo("2") == 0){
			if (TInTOut.operateOnAWOL(dbOP,request,2) != null){
				strErrMsg = " Record updated successfully ";
				strPrepareToEdit = "";
			}else{
				strErrMsg = TInTOut.getErrMsg();
			}
		}
	}
	
	if (strPrepareToEdit.compareTo("1") == 0){
		vEditInfo = TInTOut.operateOnAWOL(dbOP,request,3);
	
		if (vEditInfo == null)
			strErrMsg = TInTOut.getErrMsg();	
	}
	
	vRetResult  = TInTOut.operateOnAWOL(dbOP,request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = TInTOut.getErrMsg();
%>

<form action="./dtr_awol.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - UPDATE AWOL PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Employee ID </td>
      <td width="18%" height="23">
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"
	   onKeyUp="AjaxMapName(1);">
        &nbsp; </td>
      <td width="65%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="3"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2">
<%
strTemp = WI.fillTextValue("date_from");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="date_from" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
 <%
strTemp = WI.fillTextValue("date_to");
%>
<input name="date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="4%" height="35">&nbsp;</td>
      <td width="13%" height="35">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ViewRecords()"  src="../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
  </table>
 <% if (WI.fillTextValue("emp_id").length() > 0){ 
 			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
 %>
	<%if(vPersonalDetails != null && vPersonalDetails.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : </td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : </td>
      <td><strong>&nbsp;<%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : </td>
      <%
		strTemp = (String)vPersonalDetails.elementAt(13);
		if (strTemp == null){
			strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}else{
			strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
		}
		%>
      <td><strong>&nbsp;<%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : </td>
      <td><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="25%">Employment Status<strong> : </strong></td>
      <td width="72%"><strong>&nbsp;<%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr>
      <td  height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>	
	<%}%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = WI.fillTextValue("date_log");
			%>
      <td>Date</td>
      <td><input name="date_log" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.date_log');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="7%" height="25">&nbsp;</td>
      <td width="21%">Hours </td>
		  <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);
				else			
					strTemp = WI.fillTextValue("hours_work"); 				
			%>			
      <td width="72%"><input name="hours_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','hours_work')" value="<%=strTemp%>" size="6" maxlength="2" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hours_work')">
(hrs)
		  <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(3);
				else			
					strTemp = WI.fillTextValue("minutes_work");
			%>
and
<input name="minutes_work" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','minutes_work')" value="<%=strTemp%>" size="6" maxlength="2" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','minutes_work')">
(minutes) </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(4);
				else						
					strTemp = WI.fillTextValue("login");
			%>
      <td><select name="login">
        <option value="0" >First Login</option>
        <%	if (strTemp.compareTo("1") == 0){ %>
        <option value="1" selected>Second Login</option>
        <%}else{%>
        <option value="1">Second Login</option>
        <%}%>
      </select></td>
    </tr>      
    <tr>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="3"> <div align="center">
         <% if(vEditInfo != null) {%> 
        <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=WI.fillTextValue("info_index")%>');">
        <font size="1">click to save changes</font>
        <%}else{%>
         <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        <font size="1">click to add</font>
        <%}%> 
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1">click to cancel</font></div></td>
    </tr>
    <tr>
      <td height="20" colspan="3" style="color:#0000FF"><strong>Note: This is just for recording purposes only and will not affect payroll computation and edtr reports.</strong> </td>
    </tr>
		<%if (vRetResult != null && vRetResult.size() > 0){%>
    <tr>
      <td height="20" colspan="3" align="center"><table width="75%" border="0" cellpadding="0" cellspacing="0"  
  			bgcolor="#FFFFFF" class="thinborder">
        <tr bgcolor="#B9B292">
          <td height="25" colspan="5" align="center" class="thinborder"><font color="#FFFFFF"> <strong>LIST OF AWOL RECORDED</strong></font></td>
        </tr>
        <tr >
          <td width="34%" height="25" align="center" class="thinborder"><strong>DATE</strong></td>
          <td width="38%" align="center" class="thinborder"><strong>HOURS AWOL </strong></td>
          <td width="14%" height="25" align="center" class="thinborder"><strong>EDIT </strong></td>
          <td width="14%" align="center" class="thinborder"><strong>DELETE</strong></td>
        </tr>
        <%  
 		for (int i=0; i < vRetResult.size() ; i+=5){ %>
        <tr >
          <td height="25"  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+2);
					strTemp2 = (String)vRetResult.elementAt(i+3);				
				%>					
          <td  class="thinborder"><%=WI.getStrValue(strTemp,"", " hr(s) and","")%>&nbsp;<%=WI.getStrValue(strTemp2,"", " min ","")%></td>
          <td align="center"  class="thinborder"><% if (iAccessLevel > 1){ %>
              <input name="image2" type="image"
					onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>","0")' src="../../../images/edit.gif" width="40" height="26">
              <%}%></td>
          <td align="center"  class="thinborder">&nbsp;
              <% if (iAccessLevel == 2){ %>
              <a href='javascript:PageAction(0,"<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
              <%}%></td>
        </tr>
        <%} //end for loop %>
      </table></td>
    </tr>
		<%}%>
  </table>
	<%}%>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>


<input type="hidden" name="prepareToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="bTimeIn" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<!--
<input type="hidden" name="noAdjustment" value="1">
-->
<input type="hidden" name="info_logged" value="<%=WI.fillTextValue("info_logged")%>">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
<input type="hidden" name="late_under_time_val" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
