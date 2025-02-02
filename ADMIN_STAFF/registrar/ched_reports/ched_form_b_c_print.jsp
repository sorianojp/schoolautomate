<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDFormBC"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
.body_font{
	font-size:11px;
	font-family: Arial, Helvetica, sans-serif;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD{
	font-family: Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
</style>
</head>

<%
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CHED REPORTS-Education","ched_form_b_c.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}


Vector vRetResult = null;
CHEDFormBC cr = new CHEDFormBC();
boolean bolSUC = false;
String[] astrInstType={"SUC", "Private"};

if (WI.fillTextValue("type_institution").equals("0")){
	bolSUC = true;
}

if (WI.fillTextValue("sy_from").length() == 4){ 
	vRetResult = cr.operateOnChedFormBC(dbOP,request,4);

	if (vRetResult == null) {
		strErrMsg = cr.getErrMsg();
	}
}
%>
<body onLoad="window.print()">
<%=WI.getStrValue(strErrMsg)%>

  <% if (vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td colspan="2"><font size="2"><strong>CHED E-FORM B/C 2004</strong></font></td>
    <td width="3%">&nbsp;</td>
    <td width="40%">&nbsp;</td>
    <td width="4%">&nbsp;</td>
    <td width="31%">&nbsp;</td>
    <td width="0%">&nbsp;</td>
  </tr>
  <tr> 
    <td width="14%"><font color="#FF0000" size="1">DO NOT FILL THIS PORTION</font></td>
    <td width="8%"><div align="right">Region:&nbsp; </div></td>
    <td>&nbsp;</td>
    <td><font size="2">&nbsp;<%=WI.fillTextValue("region")%></font></td>
    <td><div align="right"><font size="2">Type&nbsp;:&nbsp;</font></div></td>
    <td><font size="2">&nbsp;<%=astrInstType[Integer.parseInt(WI.getStrValue(request.getParameter("type_institution"),"1"))]%></font> </td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><div align="right">Unique Institutional Identifier&nbsp;</div></td>
    <td>&nbsp;</td>
    <td><font size="2">&nbsp;<%=WI.fillTextValue("unique_id")%></font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><div align="right">Institution Name&nbsp;</div></td>
    <td>&nbsp;</td>
    <td><font size="2">&nbsp;<%=SchoolInformation.getSchoolName(dbOP,false,false)%></font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><div align="right">Address</div></td>
    <td>&nbsp;</td>
    <td><font size="2">&nbsp;<%=WI.fillTextValue("address")%></font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><font size="1">&nbsp;&nbsp;&nbsp;CURRICULAR PROGRAM PROFILE/</font></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td colspan="2" align="center" valign="middle" class="thinborder"> <p><font size="1">PROGRAM/COURSE</font></p></td>
    <td width="4%" rowspan="2" class="thinborder"><font size="1">With Thesis / 
      Disser -tation</font></td>
    <td width="5%" rowspan="2"  class="thinborder"><div align="center"><font size="1">Program 
        Status</font></div></td>
    <td width="5%" rowspan="2"  class="thinborder"><div align="center"><font size="1">Remarks</font></div></td>
    <td colspan="6" class="thinborder"><div align="center"><font size="1">Government 
        Authority</font></div></td>
    <td width="5%" rowspan="2" class="thinborder"><div align="center"><font size="1">Program 
        Mode </font></div></td>
    <td width="4%" rowspan="2" class="thinborder"><div align="center"><font size="1">Normal 
        Length <br>
        (in years)</font></div></td>

<% if (bolSUC){%>
    <td colspan="2" class="thinborder"><div align="center"><font size="1">Program 
        Credit (In Units)<br>
        (for SUCs only)</font></div></td>
<%}%>
    <td width="5%" rowspan="2" class="thinborder"><div align="center"><font size="1">Program 
        Credit (In Units)</font></div></td>
    <td width="6%" rowspan="2" class="thinborder"><div align="center"><font size="1">Tuition 
        per Unit <br>
        (In Peso)</font></div></td>
    <td width="6%" rowspan="2" valign="middle" class="thinborder"><div align="center"><font size="1">Program 
        Fee <br>
        (In Peso)</font></div></td>
<% if (bolSUC){%>	  
    <td width="5%" rowspan="2" valign="middle" class="thinborder"><div align="center"><font size="1">Enrolled 
        Units (for SUCs only)</font></div></td>
<%}%>	  
  </tr>
  <tr> 
    <td width="14%" class="thinborder"><font size="1">Main Program/Course</font></td>
    <td width="11%" class="thinborder"><div align="center"><font size="1">Major</font></div></td>
    <td width="5%" class="thinborder"><div align="center"><font size="1">GP No.</font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1">Year 
        Granted</font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1">Issued 
        by </font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1">GR No.</font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1">Year 
        Granted</font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1">Issued 
        by</font></div></td>
<% if (bolSUC) {%>
    <td width="4%" class="thinborder"><div align="center"><font size="1">Lab</font></div></td>
    <td width="4%" class="thinborder"><div align="center"><font size="1">Lec</font></div></td>
<%}%>
  </tr>
  <% 
//	String strCCIndex = null;
	for (int i =0; i < vRetResult.size() ; i+=27) {
	
	if ((String)vRetResult.elementAt(i+3) != null) {
	
	if (bolSUC)
		strTemp = "19";
	else
		strTemp = "16";
%>
  <tr bgcolor="#E5E5E5"> 
    <td height="25" colspan="<%=strTemp%>" class="thinborder">&nbsp;<strong><%=(String)vRetResult.elementAt(i+3)%></strong></td>
  </tr>
  <%} // end if classification index not null %>
  <tr> 
    <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></font></td>
    <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></font></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+21)%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+22))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+13))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+16))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+17))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+19))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+11))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+23))%></td>
<% if (bolSUC){%>	  
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
<%}%>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+25))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+24))%></td>
    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+26))%></td>
<% if (bolSUC){%>	  
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
  <%  } // end for loop %>
</table>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>
