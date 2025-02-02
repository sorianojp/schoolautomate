<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function DeleteInfo(strInfoIndex) {
	var bolProceed = confirm("Are you sure you want to remove Exam permit?");
	if(!bolProceed)
		return;
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "0";
	document.form_.submit();
}
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0); 
	
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}

//// - all about ajax.. 
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = strName;
}
</script>
<body>
<%@ page language="java" import="utility.*, enrollment.ReportFeeAssessment ,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Allow Exam permit printing.",
								"exam_permit_exemption.jsp");
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


//end of authenticaion code.
Vector vRetResult = null;
ReportFeeAssessment RFA = new ReportFeeAssessment();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(RFA.operateOnExamPermit(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = RFA.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = RFA.operateOnExamPermit(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = RFA.getErrMsg();
%>
<form action="./exam_permit_exemption.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EXAM PERMIT - EXEMPTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2">
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY/TERM</td>
      <td colspan="2"> 
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" valign="bottom">Exam Period</td>
      <td colspan="2" valign="bottom">  <select name="pmt_schedule">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME",
		" from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",
		request.getParameter("pmt_schedule"), false)%> </select>      </td>
    </tr>
   	<tr>
   		<td colspan="4" height="10">&nbsp;</td>
   	</tr>
    <tr valign="top"> 
      <td height="25">&nbsp;</td>
      <td>Student ID</td>
      <td width="19%"> 
	  <input name="stud_id" type="text" size="16" maxlength="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"></td>
      <td width="63%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Reason</td>
      <td colspan="2"><input name="reason" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("reason")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><input type="submit" name="1" value="&nbsp;&nbsp;Allow Permit&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';"></td>
      <td><input type="submit" name="12" value="&nbsp;&nbsp;Refresh Page&nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3" align="right" style="font-size:9px"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>Print Page &nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="23" class="thinborderBOTTOM"><div align="center"><font color="#0000FF"><strong>EXAM PERMIT EXEMPTIONS FOR ::: <label id="permit_name"></label></strong></font></div></td>
    </tr>
    <tr> 
      <td height="23" style="font-size:11px;">Total Students permitted : <%=vRetResult.size()/6%></td>
    </tr>
  </table>
   
   <table width="100%" border="0" cellpadding="0" cellspacing="0">
   	<tr>
		<td width="49%" valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			    <tr> 
      			<td width="18%" height="23" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Student ID </td>
      			<td width="35%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Student Name </td>
      			<td width="15%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Created By </td>
      			<td width="24%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Reason</td>
      			<td width="8%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Remove</td>
				</tr>
			    <%boolean bolDelAllowed = false;
				for(int i = 0; i < vRetResult.size(); i += 7 *2){
				if(vRetResult.elementAt(i + 3).equals("0"))
					bolDelAllowed = true;
				else	
					bolDelAllowed = false;%>
					<tr> 
					<td height="23" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
					<td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 2)%></td>
	      			<td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
	      			<td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 6)%></td>
	      			<td class="thinborder" style="font-size:9px;" align="center">
					<%if(bolDelAllowed){%>
						<a href="javascript:DeleteInfo('<%=vRetResult.elementAt(i)%>')"><img src="../../../images/x.gif" border="0"></a>
					<%}else{%>&nbsp;<%}%>
					</td>
					</tr>
				<%}%>
			</table>
		</td>
		<td width="2%"></td>
		<td width="49%" valign="top"><%if(vRetResult.size() > 8){%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			    <tr> 
      			<td width="18%" height="23" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Student ID </td>
      			<td width="35%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Student Name </td>
      			<td width="15%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Created By </td>
      			<td width="24%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Reason</td>
      			<td width="8%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">Remove</td>
				</tr>
			    <%bolDelAllowed = false;
				for(int i = 7; i < vRetResult.size(); i += 7 *2){
				if(vRetResult.elementAt(i + 3).equals("0"))
					bolDelAllowed = true;
				else	
					bolDelAllowed = false;%>
					<tr> 
					<td height="23" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 1)%></td>
					<td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 2)%></td>
	      			<td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 4)%></td>
	      			<td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(i + 6)%></td>
	      			<td class="thinborder" style="font-size:9px;" align="center">
					<%if(bolDelAllowed){%>
						<a href="javascript:DeleteInfo('<%=vRetResult.elementAt(i)%>')"><img src="../../../images/x.gif" border="0"></a>
					<%}else{%>Printed<%}%>
					</td>
					</tr>
				<%}%>
			</table><%}//show only if vRetResult.size() > 6%>
		</td>
	</tr>
   </table>	
	
  </table>
<%}//end of if vRetResult is not null.%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable3">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<script language="javascript">
	document.getElementById('permit_name').innerHTML = document.form_.pmt_schedule[document.form_.pmt_schedule.selectedIndex].text;
</script>
<input type = "hidden" name = "info_index">
<input type = "hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>