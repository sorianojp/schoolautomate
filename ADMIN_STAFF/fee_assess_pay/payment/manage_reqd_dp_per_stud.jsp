<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Section Scheduling Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
/*** this ajax is called for required downpayment update **/
function ajaxUpdateReqDP(strLabel,  strNewReqDP, strStudIndex) {
	var strReqDP = strNewReqDP.value;
	if(strReqDP == '' || strReqDP == ' ' || strReqDP == '  ')  {
		return;
	}
	var strParam = "stud_ref="+strStudIndex+"&sy_from="+document.form_.sy_from.value+
					"&semester="+document.form_.semester.value+"&is_tempstud=0"+"&req_dp="+strReqDP;
	var objCOAInput = document.getElementById(strLabel);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=114&"+strParam;
	this.processRequest(strURL);
}


/*** this ajax is called for required downpayment update **/
function ajaxInsReqDP() {
	var strReqDP = document.form_.reqd_dp_per_stud.value;
	if(strReqDP == '')  {
		alert("Please enter an amount. 0 amount is a valid entry as well.");
		return;
	}
	if(document.form_.stud_index.value.length == 0) {
		document.form_.reqd_dp_per_stud.value = '';
		alert("please enter correct student ID.");
		document.form_.stud_id.focus();
		return;
	}
	var strParam = "stud_ref="+document.form_.stud_index.value+"&sy_from="+document.form_.sy_from.value+
					"&semester="+document.form_.semester.value+"&is_tempstud=0&req_dp="+strReqDP;
	var objCOAInput = document.getElementById("coa_info");
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=114&"+strParam;
	this.processRequest(strURL);
}
function ajaxChkStudID() {
	if(document.form_.stud_id.value.length == 0) {
		alert("Please encode permanent student ID.");
		document.form_.stud_id.focus();
		return;
	}
	//I have to now update the reqd d/p..
	var objAmount = document.form_.stud_index;

	this.InitXmlHttpObject(objAmount, 1);//I want to get value in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=114&stud_id="+document.form_.stud_id.value;
	this.processRequest(strURL);
}
</script>

<body bgcolor="#8C9AAA">
<%@ page language="java" import="utility.*,java.util.Vector" buffer="16kb"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	WebInterface WI  = new WebInterface(request);

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-PAYMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-Manage required d/p per student","manage_reqd_dp_per_stud.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		strTemp = "<form name=ssection><input type=hidden name=showsubject></form>";
		%><%=strTemp%><%
		return;
	}

java.sql.ResultSet rs = null;
String strSQLQuery = null;
if(WI.fillTextValue("page_action").length() > 0) {
	strTemp = WI.fillTextValue("info_index");
	if(strTemp.length() > 0) {
		strSQLQuery = "delete from FA_STUD_MIN_REQ_DP_PER_STUD where stud_index = "+strTemp+" and sy_from = "+WI.fillTextValue("sy_from_old")+
						" and semester = "+WI.fillTextValue("sem_old")+" and IS_TEMP_STUD=0";
		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
	}
}
	


%>

<form name="form_" action="./manage_reqd_dp_per_stud.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6" bgcolor="#697A8F"><div align="center"><font color="#FFFFFF"><strong>::::
          VIEW/MANAGE REQUIRED DOWNPAYMENT OF BASIC EDUCATION ::::</strong></font></div></td>
    </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td width="2%" height="4">&nbsp;</td>
      <td width="41%" height="25" valign="bottom" >Education Level</td>
      <td width="57%" valign="bottom">SY-Term</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td>
	  	<select name="year" onChange="document.form_.page_action.value='';document.form_.submit();">
          <option value="">Select education level</option>
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO order by G_LEVEL",WI.fillTextValue("year"),false)%> 
        </select></td>
      <td>
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(true).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("ssection","school_year_fr","school_year_to")'>
		-
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(true).getAttribute("cur_sch_yr_to");
%>
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	&nbsp; -
		<select name="semester">
		  <option value="0">Summer</option>
		  <%
		strTemp = WI.fillTextValue("semester");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(true).getAttribute("cur_sem");
		if(strTemp == null)
			strTemp = "";
			
		if(strTemp.compareTo("0") !=0){%>
		  <option value="1" selected>Regular</option>
		  <%}else{%>
		  <option value="1">Regular</option>
		  <%}%>
		</select>	
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" onClick="document.form_.page_action.value='';" value="Refresh Page">
		
	  </td>
    </tr>
    <tr> 
      <td width="2%" height="24">&nbsp;</td>
      <td height="24" valign="bottom">Student ID :
	  <input name="stud_id" type="text" size="20" value="" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="ajaxChkStudID();style.backgroundColor='white'">
	  <input type="text" name="stud_index" class="textbox_noborder" size="1px;" style="font-size:1px;" tabindex="-1">
	  </td>
      <td valign="bottom" style="font-weight:bold; color:#FF0000; font-size:14px;">
	  Required Downpayment : 
	  <input type="text" name="reqd_dp_per_stud" value="" class="textbox_bigfont" size="5" onKeyUp="AllowOnlyInteger('form_','reqd_dp_per_stud');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="ajaxInsReqDP();style.backgroundColor='white'"> 
	  <label id="coa_info" style="font-size:9px; font-weight:bold"></label>
	  
	  
	  </td>
    </tr>
  </table>
<%
strSQLQuery = "select STUD_INDEX, id_number, fname, mname, lname, REQ_DP from FA_STUD_MIN_REQ_DP_PER_STUD "+
"join stud_curriculum_hist on (stud_curriculum_hist.user_index = stud_index) "+
"join user_table on (user_Table.user_index = stud_index) "+
" where stud_curriculum_hist.sy_from = FA_STUD_MIN_REQ_DP_PER_STUD.sy_from and stud_curriculum_hist.semester = FA_STUD_MIN_REQ_DP_PER_STUD.semester "+
" and is_temp_stud = 0 and course_index = 0 and year_level = "+WI.fillTextValue("year")+" and stud_curriculum_hist.is_valid = 1 and "+
"FA_STUD_MIN_REQ_DP_PER_STUD.sy_from = "+WI.fillTextValue("sy_from")+ " and FA_STUD_MIN_REQ_DP_PER_STUD.semester = "+
WI.fillTextValue("semester")+" order by lname, fname";

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("year").length() > 0) 
	rs = dbOP.executeQuery(strSQLQuery);

int iCount = 1;	
if(rs != null && rs.next()){
strTemp = rs.getString(1);%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="5" style="font-weight:bold" align="center" bgcolor="#FFFFCC" class="thinborder">- Student D/P Information - </td>
    </tr>
    <tr style="font-weight:bold" align="center">
      <td height="25" class="thinborder" width="5%">Count </td>
      <td class="thinborder" width="20%">ID Number </td>
      <td class="thinborder" width="40%">Student Name </td>
      <td class="thinborder" width="10%">D/P Set </td>
      <td class="thinborder" width="10%">New D/P </td>
    </tr>
    <tr>
      <td height="25" class="thinborder">1. </td>
      <td class="thinborder"><%=rs.getString(2)%></td>
      <td class="thinborder"><%=WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(6), true)%></td>
      <td class="thinborder"><input type="text" name="reqd_dp_1" class="textbox_bigfont" size="5" onKeyUp="AllowOnlyInteger('form_','reqd_dp_1');"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="ajaxUpdateReqDP('coa_info_1',document.form_.reqd_dp_1,'<%=strTemp%>');style.backgroundColor='white'">
	  <label id="coa_info_1" style="font-size:9px; font-weight:bold"></label>
	  </td>
    </tr>
    <%while(rs.next()){strTemp = rs.getString(1);%>
		<tr>
		  <td height="25" class="thinborder"><%=++iCount%>. </td>
		  <td class="thinborder"><%=rs.getString(2)%></td>
		  <td class="thinborder"><%=WebInterface.formatName(rs.getString(3),rs.getString(4),rs.getString(5),4)%></td>
		  <td class="thinborder"><%=CommonUtil.formatFloat(rs.getDouble(6), true)%></td>
		  <td class="thinborder"><input type="text" name="reqd_dp_<%=iCount%>" class="textbox_bigfont" size="5" onKeyUp="AllowOnlyInteger('form_','reqd_dp_<%=iCount%>');"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="ajaxUpdateReqDP('coa_info_<%=iCount%>',document.form_.reqd_dp_<%=iCount%>,'<%=strTemp%>');style.backgroundColor='white'">
		  <label id="coa_info_<%=iCount%>" style="font-size:9px; font-weight:bold"></label>
		  </td>
		</tr>
	<%}%>
</table>
<%}
if(rs != null)
	rs.close();
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="6" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="6" bgcolor="#697A8F">&nbsp;</td>
    </tr>
</table>
  
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="sy_from_old" value="<%=WI.fillTextValue("sy_from")%>">
  <input type="hidden" name="sem_old" value="<%=WI.fillTextValue("semester")%>">
</form>
</body>
</html>
<%dbOP.cleanUP();%>