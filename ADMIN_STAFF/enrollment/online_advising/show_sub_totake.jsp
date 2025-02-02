<%@ page language="java" import="utility.*,enrollment.AdvisingExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
AdvisingExtn onlineAdvise = new AdvisingExtn();
Vector vRetResult = onlineAdvise.showSubjectToTake(dbOP, WI.fillTextValue("stud_ref"),
					WI.fillTextValue("sy_from"),WI.fillTextValue("sem"));
if(vRetResult == null)
	strErrMsg = onlineAdvise.getErrMsg();

//System.out.println(vRetResult);

dbOP.cleanUP();
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strErrMsg != null){%>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=strErrMsg%></font></td>
    </tr>
<%return;}//System.out.println(vRetResult);%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Student ID  </td>
      <td width="80%"><%=vRetResult.remove(2)%> &nbsp;&nbsp; Name : <%=vRetResult.remove(2)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Curriculum Yr </td>
      <td><%=vRetResult.remove(0)%> - <%=vRetResult.remove(0)%> &nbsp;&nbsp;Year : <%=vRetResult.remove(1)%>&nbsp;&nbsp; Term : <%=vRetResult.remove(0)%></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
 <%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">

    <tr>
      <td height="25" colspan="2" bgcolor="#cccccc" align="center"><strong>::: Subjects To Take ::  </strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="16%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Section To Enroll </td>
      <td width="20%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Subject Code </td>
      <td width="40%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Subject Title </td>
      <td width="6%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lec Unit </td>
      <td width="6%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lab Unit </td>
      <td width="6%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lec Hour </td>
      <td width="6%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Lab Hour </td>
    </tr>
<%for(int i=0; i<vRetResult.size(); i+=9){%>
    <tr>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6),"Not Set")%></td>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
		<td align="center">&nbsp;</td>
	</tr>
  </table>
<%}//end of display. %>
</body>
</html>
<%
dbOP.cleanUP();
%>
