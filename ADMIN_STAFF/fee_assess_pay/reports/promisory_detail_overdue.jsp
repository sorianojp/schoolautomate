<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.post_fine.value = '';
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, enrollment.FAPromisoryNote ,java.util.Vector, java.util.Date" buffer="16kb" %>
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
		//may be called from registrar.
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));		
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
								"Admin/staff-Fee Assess & Payment - Reports - Promisory Note.",
								"promisory_detail_overdue.jsp");
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
FAPromisoryNote FAPromi = new FAPromisoryNote();
Vector vRetResult = null;
String[] astrSemester =  {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

if(WI.fillTextValue("post_fine").length() > 0) {
	FAPromi.postPromisoryFineBatch(dbOP, request);
	strErrMsg = FAPromi.getErrMsg();
}

if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("semester").length()>0) {	
	vRetResult = FAPromi.getPromisoryNotPaid(dbOP, request);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = FAPromi.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
%>
<form action="./promisory_detail_overdue.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: PROCESS PROMISORY NOTE OVERDUE FINE  PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="tHeader2">
<%
	if(bolIsBasic) 
		strTemp = " checked";
	else	
		strTemp = "";
	%>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="ReloadPage();"> 
	  Process Promisory Note overdue fine for Grade School </td>
      <td width="30%" style="font-size:11px; font-weight:bold; color:#0000FF"><!--Click to post One Student --></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="16%">SY/TERM</td>
      <td colspan="3"> <%
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
	  readonly="yes"> 
<%if(bolIsBasic){%>
<input type="hidden" name="semester" value="1">
<%}else{%>
	  <select name="semester">
          <%strTemp = WI.fillTextValue("semester");
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
        </select>
		&nbsp;&nbsp;&nbsp;
		<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
<%}%>		</td>
    </tr>
  </table>
  <%if (vRetResult != null && vRetResult.size()>0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tDataHead">
		
		<tr>
			<td align="center" bgcolor="#EEEEEE" height="25"><strong>PROMISORY NOTE PAYMENT DETAIL <%if(bolIsBasic) {%> (For Grade School)<%}%></strong></td>
		</tr>
	</table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" >
    <tr>
      <td colspan="2"><div align="center"> <font size="2"> <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font></div></td>
    </tr>
    <tr>
      <td height="20" colspan="2" valign="top"><div align="center"><strong>
        <%if(!bolIsBasic){%><%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%>&nbsp;&nbsp; <%}%>AY :
		  <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>
      </strong></div></td>
    </tr>
    <tr valign="bottom">
      <td width="50%" height="24" style="font-size:11px; font-weight:bold; color:#0000FF"> &nbsp; Transaction(Fine posting) Date: 
        <%
strTemp = WI.fillTextValue("transaction_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>	  
	  <input name="transaction_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>
    <a href="javascript:show_calendar('form_.inv_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
	<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
	  
	  </td>
      <td width="50%" height="24" align="right">&nbsp;&nbsp;</td>
      </tr>
  </table>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr style="font-weight:bold;" align="center" bgcolor="#CCCCCC">
			<td height="25" width="3%" style="font-size:9px;" class="thinborder">Count</td>
		    <td width="10%" style="font-size:9px;" class="thinborder">Student ID </td>
		    <td width="20%" style="font-size:9px;" class="thinborder">Student Name </td>
		    <td width="7%" style="font-size:9px;" class="thinborder">Exam Period</td>
		    <td width="7%" style="font-size:9px;" class="thinborder">PN Amount </td>
		    <td width="8%" style="font-size:9px;" class="thinborder">Approved Date </td>
		    <td width="8%" style="font-size:9px;" class="thinborder">Due Date </td>
		    <td width="8%" style="font-size:9px;" class="thinborder">Fined Until </td>
		    <td width="7%" style="font-size:9px;" class="thinborder">Balance To Fine </td>
		    <td width="7%" style="font-size:9px;" class="thinborder">Fine Amount </td>
		    <td width="10%" style="font-size:9px;" class="thinborder">Fine Until <br>mm/dd/yyyy</td>
		    <td width="5%" style="font-size:9px;" class="thinborder">Select</td>
		</tr>
<%
int iMaxDisp = 0;
for(int i = 1; i < vRetResult.size(); i += 15, ++iMaxDisp) {%>
		<tr>
		  <td height="25" style="font-size:9px;" class="thinborder"><%=iMaxDisp + 1%>.</td>
		  <td style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 14)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=ConversionTable.convertMMDDYYYY((Date)vRetResult.elementAt(i + 6), true)%></td>
		  <td style="font-size:9px;" class="thinborder"><%=CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 10)).doubleValue(), true)%></td>
		  <td style="font-size:9px;" class="thinborder"><input name="fine_<%=iMaxDisp%>" type="text" class="textbox" size="8" value="<%=vRetResult.elementAt(i + 11)%>"></td>
		  <td style="font-size:9px;" class="thinborder"><input name="fine_until_<%=iMaxDisp%>" type="text" class="textbox" size="12" value="<%=vRetResult.elementAt(i + 12)%>"></td>
		  <td style="font-size:9px;" class="thinborder" align="center"><input type="checkbox" name="pn_<%=iMaxDisp%>" value="<%=vRetResult.elementAt(i + 13)%>"> </td>
		  <input type="hidden" name="user_<%=iMaxDisp%>" value="<%=vRetResult.elementAt(i)%>">
	  </tr>
<%}%>
	<input type="hidden" name="max_disp" value="<%=iMaxDisp + 1%>">
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td style="font-size:9px;" align="center">
		<input type="submit" name="12" value=" Post Fine " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="document.form_.post_fine.value='1'">
		</td>
	</tr>
	</table>
	
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tFooter">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="post_fine">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>