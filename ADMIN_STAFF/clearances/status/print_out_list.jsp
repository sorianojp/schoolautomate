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
	font-size: 9px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<%@ page language="java" import="utility.*,clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = new Vector();
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTRCol = "";
	String [] astrConvMode = {"AMOUNT", "QUANTITY"};	
	int iSearchResult =0;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Status-Print List","print_out_list.jsp");
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
														"Clearances","Clearance Status",request.getRemoteAddr(),
														"print_out_list.jsp");
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
	ClearanceMain clrMain = new ClearanceMain();
		
		vRetResult = clrMain.searchClearance(dbOP, request);
		if(vRetResult == null)
			strErrMsg = clrMain.getErrMsg();
		else	
			iSearchResult = clrMain.getSearchCount();
			
%>
<body bgcolor="#FFFFFF">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%> <br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
      </p></div></td>
       </tr>
       <tr>
       <td>&nbsp;</td>
       </tr>
</table>
  <%if (vRetResult !=null && vRetResult.size()>0){ %>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td height="25" colspan="5" class="thinborder">
			<div align="center"><strong>LIST OF
				STUDENTS WITH CLEARANCE ACCOUNTS</strong></div>
		</td>

	</tr>
	<tr>
		<td width="19%" height="25" colspan="5" class="thinborder"><font size="1"><strong>Total Students: <%=iSearchResult%></strong></font></td>
	</tr>
	<tr>
	<td colspan="4" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
	<td colspan="4" class="thinborder" height="25"><div align="center"><strong>CLEARED STUDENTS</strong></div></td>
	</tr>
	<tr>
		<td width="19%" height="25" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT
				ID </strong></font></div>
		</td>
		<td width="33%" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div>
		</td>
		<td width="30%" class="thinborder">
			<div align="center"><strong><font size="1">COURSE-MAJOR</font></strong></div>
		</td>
		<td width="5%" class="thinborder">
			<div align="center"><strong><font size="1">YEAR</font></strong></div>
		</td>
		
	</tr>
	<%
	int i = 0;
	for(; i<vRetResult.size();i+=8){%>
	<tr>
		<%if (((String)vRetResult.elementAt(i)).compareTo("1")==0){%>
		<td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		<td class="thinborder"><font size="1" ><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></font></td>
		<td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),((String)vRetResult.elementAt(i+5)) + "/","",
	  (String)vRetResult.elementAt(i+5))%></font></td>
		<td class="thinborder"><font size="1"><%if (vRetResult.elementAt(i+7)!=null){%><%=(String)vRetResult.elementAt(i+7)%><%}else{%>N/A<%}%></font></td>
		<%}else break;%>
	</tr>
	<%}%>
	<tr>
	<td colspan="4" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
	<td colspan="4" class="thinborder" height="25"><div align="center"><strong>NOT CLEARED STUDENTS</strong></div></td>
	</tr>
	<tr>
	<td colspan="4" class="thinborder">&nbsp;</td>
	</tr>
	<tr>
		<td width="19%" height="25" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT
				ID </strong></font></div>
		</td>
		<td width="33%" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div>
		</td>
		<td width="30%" class="thinborder">
			<div align="center"><strong><font size="1">COURSE-MAJOR</font></strong></div>
		</td>
		<td width="5%" class="thinborder">
			<div align="center"><strong><font size="1">YEAR</font></strong></div>
		</td>
		
	</tr>
	<%for(;i<vRetResult.size();i+=8){%>
	<tr>
		<td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		<td class="thinborder"><font size="1" ><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></font></td>
		<td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),((String)vRetResult.elementAt(i+5)) + "/","",
	  (String)vRetResult.elementAt(i+5))%></font></td>
		<td class="thinborder"><font size="1"><%if (vRetResult.elementAt(i+7)!=null){%><%=(String)vRetResult.elementAt(i+7)%><%}else{%>N/A<%}%></font></td>
	</tr>
	<%}%>
</table>
<script language="JavaScript">
	window.print();
</script>  
  <%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
