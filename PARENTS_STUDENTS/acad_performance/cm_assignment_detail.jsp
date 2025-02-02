<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",-1);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%></head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<%@ page language="java" import="utility.*,ClassMgmt.CMAssignment,java.util.Vector" %>
<%
	DBOperation dbOP   = null;
	WebInterface WI    = new WebInterface(request);
	String strErrMsg   = null;
	Vector vRetResult  = null;
	
	if(request.getSession(false).getAttribute("userIndex") == null) {%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			You are already logged out. Please login again.</font></p>
		<%
		return;
	}
//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//end of authenticaion code.
CMAssignment cma = new CMAssignment();

vRetResult = cma.getStudentAssignment(dbOP, request, 3, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"),false);
if(vRetResult == null)
	strErrMsg = cma.getErrMsg();
	
%>	
<body <%if(vRetResult != null && vRetResult.size() > 0 && false) {%>onLoad="window.print()"<%}%>>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="3%" height="25" class="thinborderBOTTOM">
		<div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div>
	  </td>
    </tr>
  </table>
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td><%=strErrMsg%></td>
    </tr>
  </table>
<%}if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="22" colspan="5" style="font-weight:bold" align="center"><u><%=vRetResult.elementAt(2)%></u></td>
    </tr>
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="13%" style="font-size:11px;">Subject Code: </td>
      <td width="46%" style="font-size:11px;"><%=vRetResult.elementAt(0)%></td>
      <td width="12%" style="font-size:11px;">Given By:</td>
      <td width="27%" style="font-size:11px;"><%=vRetResult.elementAt(9)%></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td style="font-size:11px;">Subject Desc. </td>
      <td style="font-size:11px;"><%=vRetResult.elementAt(1)%></td>
      <td style="font-size:11px;">Section:</td>
      <td style="font-size:11px;"><%=vRetResult.elementAt(12)%></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td style="font-size:11px;">Date Given: </td>
      <td style="font-size:11px;"><%=vRetResult.elementAt(3)%></td>
      <td style="font-size:11px;">Due Date: </td>
      <td style="font-size:11px;"><%=vRetResult.elementAt(4)%></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td style="font-size:11px;">Instr. Note:</td>
      <td colspan="3" style="font-size:11px;"><%=vRetResult.elementAt(6)%></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td style="font-size:11px;">Stud. Notes:</td>
      <td colspan="3" style="font-size:11px;"><%=vRetResult.elementAt(7)%></td>
    </tr>
    <tr>
      <td height="22">&nbsp;</td>
      <td style="font-size:11px;">References:</td>
      <td colspan="3" style="font-size:11px;"><%=vRetResult.elementAt(5)%></td>
    </tr>
    <tr>
      <td height="22" class="thinborderBOTTOM">&nbsp;</td>
      <td style="font-size:11px;" class="thinborderBOTTOM">Max Score: </td>
      <td style="font-size:11px;" class="thinborderBOTTOM"><%=vRetResult.elementAt(10)%></td>
      <td style="font-size:11px;" class="thinborderBOTTOM">Student Score </td>
      <td style="font-size:11px;" class="thinborderBOTTOM"><%=WI.getStrValue(vRetResult.elementAt(11),"Not set")%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="22" colspan="2" bgcolor="#BECED3" class="thinborder" style="font-weight:bold" align="center">- Assignment List - </td>
    </tr>
    <tr> 
      <td width="4%" class="thinborder" align="center" style="font-weight:bold" height="22">SL. No. </td>
      <td width="96%" class="thinborder" align="center" style="font-weight:bold">Assignment </td>
    </tr>
<%
for(int i = 13,j=0; i < vRetResult.size(); i += 1){%>
    <tr> 
      <td height="25" align="center" class="thinborder"><%=++j%>.</td>
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
    </tr>
<%}%>
  </table>
 <%}//only if vAssignmentWithoutScore is not null and size > 0%>
 
</body>
</html>
<%
dbOP.cleanUP();
%>