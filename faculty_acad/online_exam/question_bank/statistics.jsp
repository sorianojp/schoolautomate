<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,OLExam.OLEQuestionBank,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","ONLINE EXAMINATION MGMT",request.getRemoteAddr(), 
														"statistics.jsp");	
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
OLEQuestionBank oleQBank = new OLEQuestionBank();
Vector vRetResult = null;

if(WI.fillTextValue("show_result").length() > 0) 
	vRetResult = oleQBank.getStatistics(dbOP, request, 1);
else	
	vRetResult = oleQBank.getStatistics(dbOP, request, -1);//just to get statistics.. 
if(vRetResult == null)
	strErrMsg = oleQBank.getErrMsg();

%>
<form name="form_" method="post" action="./statistics.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td height="25"><div align="center"><strong><font color="#FFFFFF">:::: QUESTION BANK STATISTICS PAGE ::::</font></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="17%" style="font-size:10px">Subject list </td>
      <td width="80%" style="font-size:10px">
	  <select name="subject" style="font-size:10px">
	  <option value="">Show all sujbect</option>
        <%=dbOP.loadCombo("sub_index","sub_code"," from subject where IS_DEL=0 "+
WI.getStrValue(WI.fillTextValue("sub_starts_with")," and sub_code like '","%'","")+ " order by sub_code asc", WI.fillTextValue("subject"), false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td style="font-size:10px">Sub code starts with </td>
      <td><input name="sub_starts_with" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("sub_starts_with")%>" class="textbox"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td style="font-size:10px">Question Prepared  by(emp.ID) </td>
      <td style="font-size:10px;">
	  <input name="emp_id_starts" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("emp_id_starts")%>" class="textbox">
        (starts with) 
        <input type="submit" name="Submit" value=" Show Result " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.show_result.value='1'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2" align="center">
      <%if(vRetResult != null && vRetResult.size() > 0) {%>	
		<table width="60%" cellpadding="0" cellspacing="0" class="thinborderALL">
			<tr bgcolor="#FFFF99">
				<td style="font-size:9px; font-weight:bold" class="thinborderBOTTOM">T/F</td>
				<td style="font-size:9px; font-weight:bold" class="thinborderBOTTOM">M/C</td>
				<td style="font-size:9px; font-weight:bold" class="thinborderBOTTOM">M/T</td>
				<td style="font-size:9px; font-weight:bold" class="thinborderBOTTOM">Objective</td>
				<td style="font-size:9px; font-weight:bold" class="thinborderBOTTOM">Essay</td>
			</tr>
			<tr>
			  <td style="font-size:9px; font-weight:bold"><%=vRetResult.remove(0)%></td>
			  <td style="font-size:9px; font-weight:bold"><%=vRetResult.remove(0)%></td>
			  <td style="font-size:9px; font-weight:bold"><%=vRetResult.remove(0)%></td>
			  <td style="font-size:9px; font-weight:bold"><%=vRetResult.remove(0)%></td>
			  <td style="font-size:9px; font-weight:bold"><%=vRetResult.remove(0)%></td>
		  </tr>
		</table>
	   <%}%>
	  
	  </td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>	
  <table width="100%" border="0" bgcolor="#FFFFFF" class="thinborder" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="22" colspan="7" bgcolor="#CCCCCC" style="font-size:11px; font-weight:bold" align="center" class="thinborder">::: QUESTION LIST ::: </td>
    </tr>
    <tr> 
      <td height="22" width="15%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Subject Code</td>
      <td width="35%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Subject Name</td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">T/F</td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">M/C</td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">M/T</td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Objective</td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Essay</td>
    </tr>
<%
String strTF  = null;
String strMC  = null;
String strMT  = null;
String strObj = null;
String strEss = null;
String strSubIndex = null; String strSubCode = null;String strSubName = null;
boolean bolRemove = false; 
for(int i = 0; i < vRetResult.size(); i += 5){
	strSubIndex = (String)vRetResult.elementAt(i);
	strSubCode = (String)vRetResult.elementAt(i + 1);strSubName = (String)vRetResult.elementAt(i + 2);
	strTF  = null;strMC  = null;strMT  = null;strObj = null;strEss = null;
while(vRetResult.size() > 0 && strSubIndex.equals(vRetResult.elementAt(i))) {
	bolRemove = false;
	if(vRetResult.elementAt(i + 4).equals("1")) {
		strTF = (String)vRetResult.elementAt(i + 3);
		bolRemove = true;
	}
	if(vRetResult.elementAt(i + 4).equals("2")) {
		strMC = (String)vRetResult.elementAt(i + 3);
		bolRemove = true;
	}
	if(vRetResult.elementAt(i + 4).equals("3")) {
		strMT = (String)vRetResult.elementAt(i + 3);
		bolRemove = true;
	}
	if(vRetResult.elementAt(i + 4).equals("4")) {
		strObj = (String)vRetResult.elementAt(i + 3);
		bolRemove = true;
	}
	if(vRetResult.elementAt(i + 4).equals("5")) {
		strEss = (String)vRetResult.elementAt(i + 3);
		bolRemove = true;
	}
	if(bolRemove) {
		vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
		vRetResult.removeElementAt(i);vRetResult.removeElementAt(i);
	}	
}
if(strTF  == null || strMC  == null || strMT  == null || strObj == null || strEss == null)
	i -= 5;
%>
    <tr> 
      <td height="22" style="font-size:9px;" class="thinborder"><%=strSubCode%></td>
      <td style="font-size:9px;" class="thinborder"><%=strSubName%></td>
      <td style="font-size:9px;" align="center" class="thinborder"><%=WI.getStrValue(strTF)%>&nbsp;</td>
      <td style="font-size:9px;" align="center" class="thinborder"><%=WI.getStrValue(strMC)%>&nbsp;</td>
      <td style="font-size:9px;" align="center" class="thinborder"><%=WI.getStrValue(strMT)%>&nbsp;</td>
      <td style="font-size:9px;" align="center" class="thinborder"><%=WI.getStrValue(strObj)%>&nbsp;</td>
      <td style="font-size:9px;" align="center" class="thinborder"><%=WI.getStrValue(strEss)%>&nbsp;</td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr> 
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  <tr>
    <td bgcolor="#B5AB73">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="show_result">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>