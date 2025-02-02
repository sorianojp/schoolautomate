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
								"Admin/Hostel Management-HOSTEL MAINTENANCE- Print","hm_view_print.jsp");
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


HostelManagement HM = new HostelManagement();
Vector vRetResult = null;
vRetResult = HM.searchRoom(dbOP, request,true);
if(vRetResult == null)
	strErrMsg = HM.getErrMsg();

//dbOP.cleanUP();

if( strErrMsg == null && (vRetResult == null || vRetResult.size() == 0) )
	strErrMsg = "No room list found.";

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
        List of Rooms - Total rooms<strong> (<%=HM.iSearchResult%>)</strong><br>
        <%=WI.getTodaysDateTime()%><br>
        <br>
        </strong></div></td>
    </tr>
   </table>

<table width="100%" border="1" cellspacing="0" cellpadding="0">
  <tr>
    <td width="25%" height="24" ><div align="center"><strong>LOCATION/NAME</strong></div></td>
    <td width="10%" ><div align="center"><strong>ROOM
        #/HOUSE #</strong></div></td>
    <td width="8%" ><div align="center"><strong>RENTAL</strong></div></td>
    <td width="8%" ><div align="center"><strong>STATUS</strong></div></td>
    <td width="8%" ><div align="center"><strong>NO OF OCCUPANT(S)</strong></div></td>
    <td width="9%" ><div align="center"><strong>CAPACITY</strong></div></td>
    <td width="9%" ><div align="center"><strong>NO.
        OF ROOMS</strong></div></td>
    <td width="23%" ><div align="center"><strong>DESCRIPTION</strong></div></td>
  </tr>
<%
for(int i=0 ; i< vRetResult.size();++i){%>
    <tr>
      <td height="25" ><%=WI.getStrValue(vRetResult.elementAt(i))%>&nbsp;</td>
      <td ><%=(String)vRetResult.elementAt(i+1)%></td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+2))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+3))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+7))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+4))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+5))%>&nbsp;</td>
      <td ><%=WI.getStrValue(vRetResult.elementAt(i+6))%>&nbsp;</td>
    </tr>
<%
i = i+9;
}%>
</table>
<script language="JavaScript">
window.print();
window.setInterval("javascript:window.close();",0);
</script>
<%} // only if there is no error
%>



</body>
</html>
