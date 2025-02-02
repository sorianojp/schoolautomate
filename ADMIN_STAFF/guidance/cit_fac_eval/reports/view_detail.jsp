<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Evaluation - View Detail</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Reports-View Detail","view_detail.jsp");
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

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","FACULTY EVALUATION",request.getRemoteAddr(),
														"view_detail.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}


FacultyEvaluation facEval = new FacultyEvaluation();
Vector vRetResult = null; Vector vAnsDetail = null; int iMaxRow = 0;

vRetResult = facEval.getFacEvalDetail(dbOP, request);
if(vRetResult == null) 
	strErrMsg = facEval.getErrMsg();
else {	
	vAnsDetail = (Vector)vRetResult.remove(0);
	iMaxRow   = ((Integer)vAnsDetail.remove(0)).intValue();
}

String strIsLAB = WI.fillTextValue("is_lab");
if(strIsLAB.equals("0"))
	strIsLAB = "LEC";
else	
	strIsLAB = "LAB";
%>
<form action="./view_detail.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><strong>:::: FACULTY EVALUATION DETAIL ::::</strong></div></td>
    </tr>
  </table>
<%if(strErrMsg != null) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%}
String strSQLQuery = "select id_number, fname, mname, lname from user_table where user_index = "+WI.fillTextValue("fac_ref");
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
if(rs.next())
	strSQLQuery = WebInterface.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4)+" ( "+rs.getString(1)+")";
else	
	strSQLQuery = null;
rs.close();

String strDepartment = "select c_code from info_faculty_basic join college on (college.c_index = info_faculty_basic.c_index) where info_faculty_basic.is_valid = 1 and user_index = "+
						WI.fillTextValue("fac_ref");
rs = dbOP.executeQuery(strDepartment);
if(rs.next()) 
	strDepartment = rs.getString(1);
else	
	strDepartment = null;
rs.close();
					
String[] astrConvertTerm = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};

int iTotalSubj = vRetResult.size()/6;
double dTemp = 0d;
double dTempRowTotal = 0d;

double[] dTotal = new double[iTotalSubj + 1];

int iIndexOf = 0;
Integer iIntObj = null;
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="16%" style="font-size:13px; font-weight:bold">Faculty Name (ID) </td>
      <td width="38%" style="font-size:13px; font-weight:bold"><%=strSQLQuery%></td>
      <td width="16%" style="font-size:13px; font-weight:bold">SY/Term</td>
      <td width="29%" style="font-size:13px; font-weight:bold">
	  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>
	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:13px; font-weight:bold">Department</td>
      <td style="font-size:13px; font-weight:bold"><%=WI.getStrValue(strDepartment,"-")%></td>
      <td style="font-size:13px; font-weight:bold">Subject Type</td>
      <td style="font-size:13px; font-weight:bold"><%=strIsLAB%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="3%" height="25" class="thinborder" align="center">I<br>T<br>E<br>M</td>
      <%for(int i = 0; i < vRetResult.size(); i += 6) {%>
	  	<td class="thinborder">
			<b><%=vRetResult.elementAt(i)%> - <%=vRetResult.elementAt(i + 4)%></b><br>
			<%=vRetResult.elementAt(i + 4)%><br>
			Respondents: <%=vRetResult.elementAt(i + 3)%><br>		</td>
      <%}%>
	  <td width="5%" class="thinborder">A<br>V<br>G</td>
    </tr>
<%for(int i = 1; i <= iMaxRow; ++i) {%>
    <tr> 
      <td height="25" class="thinborder" align="center"><%=i%></td>
      <%for(int p = 0; p < vRetResult.size(); p += 6) {
		  iIntObj = (Integer)vRetResult.elementAt(p + 2);
		  iIndexOf = vAnsDetail.indexOf(iIntObj);
		  if(iIndexOf == -1)
			dTemp =0d;
		  else	{
			vAnsDetail.remove(iIndexOf);vAnsDetail.remove(iIndexOf);vAnsDetail.remove(iIndexOf);
			dTemp = Double.parseDouble((String)vAnsDetail.remove(iIndexOf));
		  }
		  dTempRowTotal += dTemp;
		  
		  dTotal[p/6] += dTemp;
	  %>
	  	<td class="thinborder"><%=CommonUtil.formatFloat(dTemp, true)%></td>
      <%}
	  dTempRowTotal = dTempRowTotal/(double)iTotalSubj;
	  dTotal[iTotalSubj] += dTempRowTotal;
	  %>
	  <td class="thinborder"><%=CommonUtil.formatFloat(dTempRowTotal, true)%></td>
    </tr>
<%dTempRowTotal = 0d;dTemp = 0d;}%>
    <tr style="font-weight:bold">
      <td height="25" class="thinborder" align="center">Avg</td>
      <%for(int i = 0; i < vRetResult.size(); i += 6) {%>
	  	<td class="thinborder"><%=CommonUtil.formatFloat(dTotal[i/6]/(double)iMaxRow, true)%></td>
      <%}%>
      <td class="thinborder"><%=CommonUtil.formatFloat(dTotal[iTotalSubj]/(double)iMaxRow, true)%></td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>