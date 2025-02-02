<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,enrollment.EnrollmentRoomMonitor,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-ROOMS MONITORING-rooms listing print","room_listing_print.jsp");
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
EnrollmentRoomMonitor RM = new EnrollmentRoomMonitor();
int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = RM.viewRoomList(dbOP,request, true);//bolPrint = false, print = true, only in the print page.
iSearchResult = RM.iSearchResult;

String strRoomListCon = request.getParameter("disp_type");
if(strRoomListCon != null && strRoomListCon.compareTo("1") ==0)
	strRoomListCon = "All Rooms";
else if(strRoomListCon != null && strRoomListCon.compareTo("2") ==0)
	strRoomListCon = "Room Type : "+request.getParameter("room_type");
else if(strRoomListCon != null && strRoomListCon.compareTo("3") ==0)
	strRoomListCon = "Room Location : "+request.getParameter("room_location");




%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td><div align="center">
          <p><font size="1"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
            <br>
            LIST OF EXISTING ROOMS<br>
            </font></p>

        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%">&nbsp;</td>

    <td width="96%"><font size="1" ><strong>LIST
      OF ROOMS BY : <%=strRoomListCon%></strong></font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>

    <td><font size="1" ><strong>TOTAL
      ROOMS : </strong><%=iSearchResult%></font></td>
    </tr>
  </table>

<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr > 
    <td height="15" colspan="2" class="thinborder"><div align="center"><font size="1"><strong>LOCATION</strong></font></div>
      <div align="center"><font size="1"></font></div></td>
    <td width="6%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>ROOM 
        #</strong></font></div></td>
    <td width="6%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">LAST 
        INSPECTION</font></strong></div></td>
    <td width="17%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>DESCRIPTION</strong></font></div></td>
    <td width="11%" rowspan="2" class="thinborder"><div align="center"><font size="1"><strong>TYPE 
        OF ROOM</strong></font></div></td>
    <td width="15%" rowspan="2" class="thinborder"><strong><font size="1">STATUS/REMARKS</font></strong></td>
    <td width="15%" rowspan="2" align="center" class="thinborder"><strong><font size="1">FOR SUBJECT 
      ASSIGNMENT</font></strong></td>
    <td width="15%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">CHECK 
        ROOM CONFLICT DURING ROOM ASSIGNMENT</font></strong></div></td>
    <td height="15" colspan="3" class="thinborder"><div align="center"><font size="1"><strong>CAPACITY<br>
        (no. of students)</strong></font></div>
      <div align="center"><font size="1"></font></div></td>
  </tr>
  <tr > 
    <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>BUILDING</strong></font></div></td>
    <td width="5%" height="12" class="thinborder"><div align="center"><font size="1"><strong>FLOOR</strong></font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>REG.</strong></font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>IRREG.</strong></font></div></td>
    <td width="5%" align="center" class="thinborder"><font size="1"><strong>TOTAL</strong></font></td>
  </tr>
  <%
for(int i = 0 ; i< vRetResult.size(); ++i)
{%>
  <tr > 
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;")%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
    <td align="center" class="thinborder"> <% if(((String)vRetResult.elementAt(i+11)).compareTo("1") ==0)
	  {%> <img src="../../../images/x.gif" width="12" height="14"> <%}else{%> <img src="../../../images/tick.gif"> <%}%> </td>
    <td align="center" class="thinborder"> <% if(((String)vRetResult.elementAt(i+12)).compareTo("1") ==0)
	  {%> <img src="../../../images/x.gif" width="12" height="14"> <%}%>
      &nbsp; </td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3),"&nbsp")%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+4),"&nbsp")%></td>
    <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp")%></td>
  </tr>
  <%
i = i+13;
}//end of loop %>
</table>
<%}//end of displaying %>

<%dbOP.cleanUP();%>
<script language="JavaScript">
	window.print();
window.setInterval("javascript:window.close();",0);
</script>

</body>
</html>
