<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<body onLoad="window.print()">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil,eDTR.OverTime" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	Vector vRetResult = null;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Edit Overtime","view_all_ot_request.jsp");
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
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(), 
														"schedule_overtime.jsp");	
if (iAccessLevel == 0 && bolMyHome){
	iAccessLevel = 1;
}
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

OverTime OT = new OverTime();
vRetResult = OT.getOTList(dbOP,request,null);
	if (vRetResult == null) 
		strErrMsg = OT.getErrMsg();

 if (vRetResult != null && vRetResult.size()>3) { %>
        <table width="100%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td height="30" align="center"><font size="2"><strong>LIST OF 
                OVERTIME SCHEDULE REQUEST<br>
            </strong></font></td>
          </tr>
</table> 
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" 
  				bgcolor="#FFFFFF" class="thinborder">

    <tr>
      <td width="21%" class="thinborder">
	  		<strong>&nbsp;Requested by </strong></td>
      <td width="21%" class="thinborder">
	  		<strong>&nbsp;Requested For</strong></td>
      <td width="10%" height="25" class="thinborder">
	  		 <strong>&nbsp;Date of &nbsp;<br>
&nbsp;Request</strong></td>
      <td width="22%" class="thinborder"><strong>&nbsp;Date/Days</strong></td>
      <td width="9%" class="thinborder"><strong>&nbsp;Inclusive<br>
&nbsp;Time</strong></td>
      <td width="6%" class="thinborder"><strong>&nbsp;No. of<br>
&nbsp;Hours</strong></td>
      <td width="11%" class="thinborder"><strong>&nbsp;Status</strong></td>
    </tr>
    <%for(int i = 3 ; i < vRetResult.size() ; i+=17){ %>
    <tr>
      <% strTemp =(String)vRetResult.elementAt(i+15); %>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue(strTemp, "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"> &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+16),"&nbsp;")%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></font></td>
      <% 
		   		strTemp = (String)vRetResult.elementAt(i+7);
		   		if (strTemp  == null || strTemp.length() == 0){
		   			strTemp = (String)vRetResult.elementAt(i+5);
		   		}else{
					strTemp = "every " + strTemp + 
								"<br>&nbsp;(" +  (String)vRetResult.elementAt(i+5) + " - " +
								       (String)vRetResult.elementAt(i+6) + ")";
				}
		   %>
      <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+8)%> - <br>
            &nbsp;<%=(String)vRetResult.elementAt(i+9)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;</font><font size="1"><%=(String)vRetResult.elementAt(i+4)%></font></td>
      <%
				strTemp = (String)vRetResult.elementAt(i+10);
				if(strTemp.equals("APPROVE")){ 
					strTemp = "<strong><font color=#0000FF>" + strTemp + "</font></strong>";
				}else if (strTemp.equals("DISAPPROVE")){
					strTemp = "<strong><font color=#FF0000>" + strTemp + "</font></strong>";
				}
			%>
      <td class="thinborder"><font size="1"><%=strTemp%></font></td>
    </tr>
    <% } // end for loop %>
  </table>
<% }%>
</body>
</html>
<%
dbOP.cleanUP();
%>