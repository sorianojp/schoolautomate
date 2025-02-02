<%
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
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
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
-->
</style>
</head>
<body onLoad="javascript:window.print();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.Holidays" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-DTR OPERATIONS","set_holidays_print.jsp");
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
int iAccessLevel = 2;

//end of authenticaion code.

Holidays hol = new Holidays();
Vector vRetResult = hol.operateOnCompanyHolidays(dbOP,request,4);

 if (vRetResult !=null && vRetResult.size() > 0){ %>
<div align="center">
  <strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong> <font size="2"><br>
  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font><br>
  <br>
  <br>
</div>
<table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr bgcolor="#B9B292"> 
    <td height="25" colspan="4" align="center" class="thinborder"><strong>LIST 
    OF HOLIDAYS</strong></td>
  </tr>
  <tr>
	<%if(!bolIsSchool || strSchCode.startsWith("VMUF")){%>
    <td width="29%" class="thinborder"><%if(bolIsSchool){%>
      College
        <%}else{%>
        Division
    <%}%></td> 
		<%}%>
    <td width="28%" height="25" class="thinborder"><strong> &nbsp;NAME </strong></td>
    <td width="18%" class="thinborder"><strong>&nbsp;DATE</strong></td>
    <td width="25%" class="thinborder"><strong>&nbsp;TYPE OF HOLIDAY</strong></td>
  </tr>
  <% for (int i = 0; i < vRetResult.size(); i+=15) { %>
  <tr>
    <%if(!bolIsSchool || strSchCode.startsWith("VMUF")){%>
		<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6), "ALL")%></td> 
		<%}%>
    <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
  </tr>
  <%} // end for loop%>
</table>
<%} // end if vRetResult==null %>

</body>
</html>
<%
	dbOP.cleanUP();
%>

