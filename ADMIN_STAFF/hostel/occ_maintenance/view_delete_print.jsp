<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.HostelManagement,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-OCCUPANCY MAINTENANCE- Print occupant","view_delete_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


//end of security code.
HostelManagement HM = new HostelManagement();
Vector vRetResult = null;
int iSearchResult = 0;
vRetResult = HM.searchOccupant(dbOP, request,true);
//dbOP.cleanUP();
if(vRetResult == null)
	strErrMsg = HM.getErrMsg();
else
	iSearchResult = HM.iSearchResult;

if( strErrMsg == null && (vRetResult == null || vRetResult.size() == 0) )
	strErrMsg = "No Occupant list found.";

if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%}else{%>
    <table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
        </div></td>
    </tr>
    <tr>
      <td height="30"><div align="center"><br>
        HOSTEL MAINTENANCE<br>
        List of Occupant - Total Occupant/s<strong> (<%=HM.iSearchResult%>)</strong><br>
        <%=WI.getTodaysDateTime()%><br>
        <br>
        </strong></div></td>
    </tr>
   </table>

<table  width="100%" border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td width="10%" ><div align="center"><strong>ID NUMBER</strong></div></td>
    <td width="25%" height="24" ><div align="center"><strong>ACCOUNT
        NAME </strong></div></td>
    <td width="6%" ><div align="center"><strong>ACCOUNT TYPE </strong></div></td>
    <td width="8%" ><div align="center"><strong>DATE OF OCCUPANCY</strong></div></td>
    <td width="10%" ><div align="center"><strong>LOCATION/NAME</strong></div></td>
    <td width="8%" ><div align="center"><strong>ROOM#/HOUSE#</strong></div></td>
    <td width="8%" ><div align="center"><strong>RENTAL </strong></div></td>
    <td width="10%" ><div align="center"><strong>OUTSTANDING BALANCE
        </strong></div></td>
  </tr>
  <%
for(int i=0 ; i< vRetResult.size();++i){%>
  <tr>
    <td ><%=WI.getStrValue(vRetResult.elementAt(i))%></td>
    <td height="25" >&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    <td ><%=(String)vRetResult.elementAt(i+2)%></td>
    <td ><%=WI.getStrValue(vRetResult.elementAt(i+3))%>&nbsp;</td>
    <td ><%=WI.getStrValue(vRetResult.elementAt(i+4))%>&nbsp;</td>
    <td ><%=WI.getStrValue(vRetResult.elementAt(i+5))%>&nbsp;</td>
    <td ><%=WI.getStrValue(vRetResult.elementAt(i+6))%></td>
    <td >&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
  </tr>
  <%
i = i+8;
}%>
</table>
<script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%} // only if there is no error
%>
</form>
</body>
</html>
