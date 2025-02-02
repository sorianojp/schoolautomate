<%@ page language="java" import="utility.*,java.util.Vector,chedReport.E5New"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

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
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-CHED REPORTS-CHED COURSE MAPPING","E5_print.jsp");
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
E5New e5New = new E5New();
vRetResult = e5New.operateOnE5Info(dbOP, request, 5);  //show already encoded.. 
if(strErrMsg == null && vRetResult == null)
	strErrMsg = e5New.getErrMsg();

chedReport.CHEDInstProfile cip = new chedReport.CHEDInstProfile();
Vector vInstProfile = cip.operateOnChedInstProfile(dbOP,request,3);
if(vInstProfile == null || vInstProfile.size() == 0) {
	strErrMsg = cip.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Institution profile not found.";
}	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
.body_font{
	font-size:11px;
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
    TD.thinborderALL {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD{
	font-family: Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style></head>
<body onLoad="window.print();">
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" style="font-weight:bold; font-size:14px; color:#FF0000">&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%dbOP.cleanUP();
 return;
 }//do not proceed if there is error.. 

 String[] astrConvertTerm = {"Summer", "1st semester","2nd Semester","3rd Semester"};
 if(vRetResult != null && vRetResult.size() > 0) {%>
 
 	<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="57%" style="font-weight:bold">
		Ched Form E.5 (revised June 2001)<br>
		FACULTY OR TEACHING STAFF IN HIGHER EDUCATION PROGRAMS<br>
		Name of Institution: <%=SchoolInformation.getSchoolName(dbOP,false,false)%><br>
		Region: <%=vInstProfile.elementAt(8)%>
	  </td>
		<td valign="top" width="26%" style="font-weight:bold">
		Unique Institutional Identifier<br>
		<%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>/Academic Year
		</td>
		<td width="17%" valign="top" style="font-weight:bold">
		<%=vInstProfile.elementAt(1)%><br>
		<%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>
		</td>
	</tr>
	</table>
<br>
<br>
    <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">&nbsp; </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">ID Number </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Name</td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Full Time/ Part Time </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Sex</td>
		  <td height="25" colspan="5" align="center" class="thinborder" style="font-weight:bold">EDUCATIONAL QUALIFICATION </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Professioanl Licensure Earned </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Tenure of Employement </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Faculty Rank </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Teaching Load </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Subjects Tought </td>
		  <td rowspan="2" class="thinborder" style="font-weight:bold">Annual Salary </td>
	  </tr>
		<tr>
		  <td height="25" class="thinborder" style="font-weight:bold">Bachelor</td>
		  <td style="font-weight:bold" class="thinborder">Masters</td>
		  <td style="font-weight:bold" class="thinborder">No of Units Towards Masters Degree </td>
		  <td style="font-weight:bold" class="thinborder">Doctoral</td>
		  <td style="font-weight:bold" class="thinborder">No of Units Towards Doctors Degree </td>
	    </tr>
		<%
		String[] astrConvertPTFT   = {"PT","FT"};
		String[] astrConvertGender = {"M","F"};
		
		int iRowsPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg")) - 5; int iPageNo = 1;
		int iRowsPrinted = 0;
		String strPageBreak = "</table><DIV style='page-break-after:always' ></DIV><table width='100%' cellpadding='0' cellspacing='0' class='thinborder'>";

		for(int i = 0; i < vRetResult.size(); i += 17) {
		if(iRowsPrinted >=iRowsPerPg){%>
			<%=strPageBreak%>
		<%iRowsPrinted = 0;
			if(iPageNo == 1)
				iRowsPerPg += 5;
			++iPageNo;
		}
		++iRowsPrinted;%>
		<tr>
		  <td width="2%" height="25" class="thinborder"><%=i/17 + 1%>.</td>
		  <td width="10%" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
		  <td width="10%" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
		  <td width="4%" class="thinborder" align="center"><%=astrConvertPTFT[Integer.parseInt((String)vRetResult.elementAt(i + 12))]%></td>
		  <td width="4%" class="thinborder" align="center"><%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 13))]%></td>
		  <td width="15%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
		  <td width="15%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
		  <td width="5%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
		  <td width="15%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
		  <td width="5%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
		  <td width="5%" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
		  <td width="5%" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
		  <td width="5%" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 10), "&nbsp;")%></td>
		  <td width="5%" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 16), "&nbsp;")%></td>
		  <td width="10%" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 15), "&nbsp;")%></td>
		  <td width="5%" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
	    </tr>
		<%}%>
  </table> 	
  <br>
  <br>
  <table width="100%" cellpadding="0" cellspacing="0">
  <tr>
  	<td width="17%" height="21">Accomplished By : </td>
	<td width="24%"><%=WI.fillTextValue("_accomplish")%></td>
    <td width="18%">Certified Correct:</td>
    <td width="41%"><%=WI.fillTextValue("_certified")%></td>
  </tr>
  <tr>
    <td height="21">Designation</td>
    <td><%=WI.fillTextValue("accomplish_desig")%></td>
    <td>Designation:</td>
    <td><%=WI.fillTextValue("certified_desig")%></td>
  </tr>
  <tr>
    <td height="21">Date:</td>
    <td><%=WI.fillTextValue("accomplish_date")%></td>
    <td>Date:</td>
    <td><%=WI.fillTextValue("certified_date")%></td>
  </tr>
  </table>
 <%}%>

</body>
</html>
<%
	dbOP.cleanUP();
%>
