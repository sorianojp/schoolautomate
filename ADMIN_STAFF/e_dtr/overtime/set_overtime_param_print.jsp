<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime,eDTR.eDTRUtil"%>
<%
///added code for HR/companies.
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
	font-size: 12px;
}
table{
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
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
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
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Staff-eDaily Time Record-OVERTIME MANAGEMENT-Set Overtime Parameters","set_overtime_param.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(),
														"set_overtime_param.jsp");
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

OverTime ot = new OverTime ();
Vector vRetResult = null;

vRetResult = ot.operateOnOTParameter(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = ot.getErrMsg();
}
%>
<body onLoad="javascript:window.print();">
<form name="form_" method="post" action="./set_overtime_param.jsp">
  <%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'><strong>","</strong></font>","")%>
<% if (vRetResult != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
          <%=SchoolInformation.getInfo1(dbOP,false,false)%> </font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="5" class="thinborder"><div align="center"><strong>LIST 
          OF EMPLOYEES WITH OVERTIME PARAMETERS</strong></div></td>
    </tr>
    <tr> 
      <td width="12%" height="26" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE 
          ID </strong></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE NAME</font></strong></div></td>
      <td class="thinborder"><div align="center"><strong><font size="1"><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/OFFICE</font></strong></div></td>
      <td class="thinborder"><div align="center"><strong><font size="1">TIME</font></strong></div></td>
      <td class="thinborder"><div align="center"><strong><font size="1">EFFECTIVITY DATE</font></strong></div></td>
    </tr>
    <% for (int i = 0; i < vRetResult.size() ; i+=13) {%>
    <tr> 
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+12)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+10)%></font></td>
      <td width="25%" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+11)%></font></td>
      <td width="16%" class="thinborder"><font size="1"><%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+4),
	  					(String)vRetResult.elementAt(i+5),
	  					(String)vRetResult.elementAt(i+6)) + " - " + 
						eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
	  					(String)vRetResult.elementAt(i+8),
	  					(String)vRetResult.elementAt(i+9))%></font></td>
      <td width="24%" class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+2)) + " - " + ((String)vRetResult.elementAt(i+3))%></font></td>
    </tr>
    <%} // end for loop%>
  </table>
 <%} // vRetResult != null%>
  <input type="hidden" name="print_page">
<input type="hidden" name="show_all" value="<%=WI.fillTextValue("show_all")%>"> 
</form>
</body>
</html>
