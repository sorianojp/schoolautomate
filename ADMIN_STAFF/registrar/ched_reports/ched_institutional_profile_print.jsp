<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDInstProfile"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>INSTITUTIONAL PROFILE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
.body_font{
	font-face:Arial;
	font-size:11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    }
	
	TD{
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderLRBottom {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;	
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }	
	TD.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
    border-left: solid 1px #000000;	
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }	

</style>
</head>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
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
								"Admin/staff-CHED REPORTS-CHED FORM B C","ched_form_b_c.jsp");
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

CHEDInstProfile cr = new CHEDInstProfile();
Vector vRetResult = cr.operateOnChedInstProfile(dbOP,request,3);
Vector vRetResultName = null;

%>
<body onLoad="window.print();">
<%
 if (vRetResult == null || vRetResult.size() ==0) {
	strErrMsg = cr.getErrMsg();
%>
&nbsp; <%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>", "")%>

<%}else{

vRetResultName = (Vector)vRetResult.elementAt(0);
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
    <td height="22" colspan="2"><font size="2" face="Arial, Helvetica, sans-serif">
	<strong>CHED Form A </strong><i>(revised June 2001)</i></font></td>
  </tr>
  <tr> 
    <td height="22" colspan="2"><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>INSTITUTIONAL 
        PROFILE </strong></font></div></td>
  </tr>
  <tr>
    <td height="22" colspan="2">&nbsp;</td>
  </tr>
</table>
  
<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr> 
    <td colspan="2" class="thinborder" ><div align="center"><strong>DATA ITEMS</strong><br>
      </div></td>
    <td height="22" class="thinborder" ><div align="center"><strong>DATA ENTRIES</strong></div></td>
  </tr>
  <tr> 
    <td colspan="2" class="thinborder" ><div align="right">&nbsp;Institution Name 
        (no abbreviation please) &nbsp;:&nbsp; </div></td>
    <td width="55%" height="22" class="thinborder" >&nbsp;<%=SchoolInformation.getSchoolName(dbOP,false,false)%></td>
  </tr>
  <tr> 
    <td colspan="2"  class="thinborder" ><div align="right">Unique Institutional 
        Identifier&nbsp;:&nbsp; </div></td>
    <td height="22" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(1),"NA")%></td>
  </tr>
  <tr> 
    <td colspan="2" class="thinborder"><div align="right">Institutional Form of 
        Ownership (pls. see below)&nbsp;:&nbsp; </div></td>
    <td height="22"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(4),"NA")%></td>
  </tr>
  <tr > 
    <td width="17%" align="right"  class="thinborder">Address: <br></td>
    <td width="28%" align="right" class="thinborderBottom" >Street&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(5),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Municipality&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(6),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Province/City&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(7),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Postal or Zip Code&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(9),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Institutional Telephone 
      (include Area Code)&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(10),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Institutional Fax No. (include 
      Area Code)&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(11),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Institutional Head's Telephone&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(12),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Institutional E-mail Address&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(14),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Institutional Web Site&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(13),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Year Established&nbsp;:&nbsp; 
    </td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(16),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Latest SEC Registration/Enabling 
      Law or Charter&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(15),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Date Granted or Approved&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(24),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Year Converted to College 
      Status&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(18),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Year Converted to University 
      Status&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(17),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right"  class="thinborder">Name of Institutional Head&nbsp;:&nbsp;</td>
    <td height="18"  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(19),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right" class="thinborder">Title of Head of Institution&nbsp;:&nbsp;</td>
    <td height="18" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(20),"NA")%></td>
  </tr>
  <tr > 
    <td colspan="2" align="right" class="thinborder">Highest Educational Attainment 
      of the Head&nbsp;:&nbsp;</td>
    <td height="18" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(21),"NA")%></td>
  </tr>
  <tr >
    <td colspan="2" class="thinborder">List of the former Name(s) of your Institution<br>
      and the corresponding years your <br>
      Institution used such name</td>
    <td valign="top" class="thinborder">
	<table width="100%" cellpadding="0" cellspacing="0">
<% if (vRetResultName != null && vRetResultName.size() > 0) {
	for (int i = 0; i <vRetResultName.size() ; i+=4) {%>
		<tr><td class="thinborderBottom">&nbsp;<%=(String)vRetResultName.elementAt(i+1)%></td></tr>
		<tr><td class="thinborderBottom">&nbsp;<%=(String)vRetResultName.elementAt(i+2) +" - " + (String)vRetResultName.elementAt(i+3)%></td></tr>
<%
  } // end for loop
} // end if vFormerName != null%>
	</table>
</td>
  </tr>
</table>
<table cellpadding="0" cellspacing="0" width="100%" border="0">
  <tr> 
    <td width="45%">&nbsp;</td>
    <td width="55%">&nbsp;</td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td align="right">Accomplished by&nbsp;:&nbsp;<br></td>
    <td class="thinborderALL">&nbsp;<%=WI.getStrValue(request.getParameter("accomplished"),"NA")%></td>
  </tr>
  <tr> 
    <td align="right">Designation&nbsp;:&nbsp;<br></td>
    <td class="thinborderLRBottom">&nbsp;<%=WI.getStrValue(request.getParameter("acc_design"),"NA")%></td>
  </tr>
  <tr> 
    <td align="right">Date&nbsp;:&nbsp;</td>
	<%
		if ( request.getParameter("acc_date")!= null && request.getParameter("acc_date").length() > 0)
			strTemp = WI.formatDate(request.getParameter("acc_date"),6);
		else
			strTemp = null;
	%>
	
    <td class="thinborderLRBottom">&nbsp;<%=WI.getStrValue(strTemp,"NA")%></td>
  </tr>
  <tr> 
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td align="right">Certified Correct&nbsp;:&nbsp;</td>
    <td class="thinborderALL">&nbsp;<%=WI.getStrValue(request.getParameter("certified"),"NA")%></td>
  </tr>
  <tr> 
    <td align="right">Designation&nbsp;:&nbsp;<br></td>
    <td class="thinborderLRBottom">&nbsp;<%=WI.getStrValue(request.getParameter("certify_design"),"NA")%></td>
  </tr>
  <tr> 
    <td align="right">Date&nbsp;:&nbsp;<br></td>
	<%
		if ( request.getParameter("certify_date")!= null && request.getParameter("certify_date").length() > 0)
			strTemp = WI.formatDate(request.getParameter("certify_date"),6);
		else
			strTemp = null;
	%>	
    <td class="thinborderLRBottom">&nbsp;<%=WI.getStrValue(strTemp,"NA")%></td>
  </tr>
  <tr> 
    <td align="right">&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr> 
    <td colspan="2"><strong>Entry for Institutional Form of Ownership:</strong><br>
      Chartered State College/University (Main)<br>
      Chartered State College/University (Satellite Campus)<br>
      CHED-Supervised Institution<br>
      Local Government College/University<br>
      Private Sectarian Stock<br>
      Private Sectarian Non-Stock<br>
      Private Non-Sectarian Stock<br>
      Private Non-Sectarian Non-Stock<br>
      Private Sectarian Foundation<br>
      Private Non-Sectarian Foundation</tr>
</table>

<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>
