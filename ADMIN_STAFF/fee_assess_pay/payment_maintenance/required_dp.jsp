<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_action.value="";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex)
{
	document.form_.page_action.value=strAction;
	if(strAction == "1")
		document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function CopyInfo() {
	var strCopyFr = document.form_.sy_from.value;
	if(strCopyFr.length == 0) {
		alert('Please enter SY From Information.');
		return;
	}
	var strCopyTo = prompt('Please enter new SY to copy the information to. Please Note, copy function copies all information of SY : to new SY.','');
	if(strCopyTo == null || strCopyTo.length == 0)
		return;
	if(strCopyTo.length != 4) {
		alert("Please enter 4 digit school year from information : for example : 2009 and click OK.");
		return ;
	}
	if(strCopyTo.charAt(0) != '2') {
		alert("Wrong SY From Information.");
		return;
	}
	if(strCopyTo.charAt(1) != '0') {
		alert("Wrong SY From Information.");
		return;
	}
	if(isNaN(strCopyTo)){
		alert("Wrong SY From Information. It must be a 4 digit year.");
		return;	
	}

	document.form_.copy_info_to.value = strCopyTo;
	document.form_.page_action.value = 6;
	document.form_.submit();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAStudMinReqDP,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Required downpayment",
								"required_dp.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"required_dp.jsp");
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

FAStudMinReqDP minReqdDP = new FAStudMinReqDP(dbOP);
strTemp = WI.fillTextValue("page_action");

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0)
	bolIsBasic = true;

if(strTemp.equals("6")) {
	minReqdDP.copyInfo(dbOP, request);
	strErrMsg = minReqdDP.getErrMsg();
	strTemp = "";
}

Vector vRetResult = null;
if(strTemp.length() > 0) {
	if(minReqdDP.operateOnReqDP(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = minReqdDP.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
//I have to get the list of subjet re-enrolled. 
//if(WI.fillTextValue("sy_to").length() > 0) {
	vRetResult = minReqdDP.operateOnReqDP(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = minReqdDP.getErrMsg();
//}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";


boolean bolIsSWU = strSchCode.startsWith("SWU");
%>

<form name="form_" action="./required_dp.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          REQUIRED DOWNPAYMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
<%if(strSchCode.startsWith("VMUF") || strSchCode.startsWith("CSA") || strSchCode.startsWith("SPC") || true){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-size:11px; font-weight:bold; color:#0000FF">
<%
if(bolIsBasic) 
	strTemp = "checked";
else	
	strTemp = "";
%>	  
	  <input type="checkbox" name="is_basic" value="1" <%=strTemp%> onClick="ReloadPage();"> Is Basic? (uncheck to go to college)	  </td>
    </tr>
<%}%>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">SY/TERM</td>
      <td width="81%" style="font-size:9px;"> <%
	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		
	if(strTemp == null) strTemp = "";
	%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		
	if(strTemp == null) strTemp = "";
	%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <%
	strTemp = WI.fillTextValue("semester");
	if(strTemp == null) strTemp = "";
%> <select name="semester">
          <option value="">ALL</option>
          <%
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
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
        <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
		
		-- Copy Information to new SY/Term 
		<input type="button" name="_1" value="Copy Info" onClick="CopyInfo();">
		<input type="hidden" name="copy_info_to"><!-- Page action = 6 -->		</td>
    </tr>
<%if(bolIsBasic) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Grade Level </td>
      <td>
	  <select name="year_level">
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year_level"),false)%> 
	  </select>	  </td>
    </tr>
<%}else{//college %>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>COURSE</td>
      <td><select name="course_index" onChange="ReloadPage();">
          <option value="">All Course</option>
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc", WI.fillTextValue("course_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>MAJOR</td>
      <td><select name="major_index">
          <option value="">All</option>
          <%
if(WI.fillTextValue("course_index").length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+WI.fillTextValue("course_index") ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, WI.fillTextValue("major_index"), false)%>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year Level</td>
      <td>
<%
strTemp = WI.fillTextValue("year_level");
%>	  <select name="year_level">
          <%if(strTemp.length() ==0){%>
          <option value="" selected>All</option>
          <%}else{%>
          <option value="">All</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}%>
        </select></td>
    </tr>
<%}//end of showing for college. 
if(bolIsSWU) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Applicable to </td>
      <td>
	  <select name="is_new_">
	  <option value=""></option>
<%
strTemp = WI.fillTextValue("is_new_");
if(strTemp.equals("1")) 
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="1"<%=strErrMsg%>>New Only</option>
<%
if(strTemp.equals("0")) 
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
	  <option value="0"<%=strErrMsg%>>Old Only</option>
	  </select>	  </td>
    </tr>
<%}%>	
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Min Required DP</td>
      <td> <input name="amount" type="text" size="16" value="<%=WI.fillTextValue("amount")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">      
	  <%if(strSchCode.startsWith("UC") || strSchCode.startsWith("MARINER") || strSchCode.startsWith("DLSHSI")) {%>
	  	<input type="checkbox" name="is_percent" value="checked" <%=WI.fillTextValue("is_percent")%>> Percentage
	  <%}%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td> <%
if(iAccessLevel > 1){%> <a href='javascript:PageAction("1","");'><img src="../../../images/add.gif" border="0" name="hide_save"></a>Click 
        to add fee 
        <%}%> </td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center"><strong>MINIMUM 
          REQUIRED AMOUNT PAYMENT DETAILS</strong></div></td>
    </tr>
  </table>
<%if(bolIsBasic){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  <td width="40%" height="25" align="center" class="thinborder"><strong><font size="1">Grade Level</font></strong></td>
		  <td width="20%" align="center" class="thinborder"><strong><font size="1">Required Amount </font></strong></td>
		  <td width="7%" align="center" class="thinborder"><font size="1"><strong>Delete</strong></font></td>
		</tr>
		<%for(int i = 0 ; i< vRetResult.size() ; i += 7) {%>
			<tr> 
			  <td height="25" class="thinborder"><%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vRetResult.elementAt(i + 4)), false)%></td>
			  <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
			  <td align="center" class="thinborder"> <%if(iAccessLevel == 2 ){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
				<img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
			</tr>
		<%}//end of for loop%>
  </table>

<%}else{//for college%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold" align="center"> 
      <td width="40%" height="25" class="thinborder">Course</td>
      <td width="25%" class="thinborder">Major</td>
      <td width="8%" class="thinborder">Yr Level</td>
<%if(bolIsSWU) {%>
	      <td width="10%" class="thinborder">Applicable to </td>
<%}%>
      <td width="15%" class="thinborder">Required Amt</td>
      <td width="7%" class="thinborder">Delete</td>
    </tr>
	<%for(int i = 0 ; i< vRetResult.size() ; i += 7) {%>
		<tr> 
		  <td height="25" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"ALL")%></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"ALL")%></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"ALL")%></td>
<%if(bolIsSWU) {%>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"ALL")%></td>
<%}%>
		  <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i + 3)%>
		  <%if(vRetResult.elementAt(i + 5) != null){%>
		  	Percent
		  <%}%>		  </td>
		  <td class="thinborder"> <%if(iAccessLevel == 2 ){%> <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'> 
			<img src="../../../images/delete.gif" border="0"></a> <%}%> </td>
		</tr>
	<%}//end of for loop%>
  </table>

<%}//end of college %>

<%}//show only if vRetResult is not null %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>