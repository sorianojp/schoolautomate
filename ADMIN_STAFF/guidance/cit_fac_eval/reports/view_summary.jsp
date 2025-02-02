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
<title>Faculty Evaluation - View Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();" topmargin="0" bottommargin="0">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Reports-View Summary","view_summary.jsp");
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
														"view_summary.jsp");
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
Vector vRetResult = null; Vector vCatgIndex = null; int iMaxRow = 0;

vRetResult = facEval.getFacultyEvalSummary(dbOP, request);
if(vRetResult == null) 
	strErrMsg = facEval.getErrMsg();
else {	
	vCatgIndex = (Vector)vRetResult.remove(0);
	iMaxRow   = vCatgIndex.size()/4;
}

String[] astrConvertLecLab = {"LEC", "LAB"};
%>
<form action="./view_summary.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><strong>:::: FACULTY EVALUATION DETAIL ::::</strong></div></td>
    </tr>
  </table>
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%}else{
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

int iTotalSubj = vRetResult.size()/7;
double dTemp = 0d;
double dTempRowTotal = 0d;

double[] dTotal = new double[iTotalSubj + 1];
Vector vCatgPointRef = null;
//System.out.println(vRetResult);
int iIndexOf = 0;
Integer iIntObj = null;
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="19%" style="font-size:13px; font-weight:bold">Faculty Name (ID) </td>
      <td width="49%" style="font-size:13px; font-weight:bold"><%=strSQLQuery%></td>
      <td width="8%" style="font-size:13px; font-weight:bold">SY/Term</td>
      <td width="23%" style="font-size:13px; font-weight:bold">
	  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:13px; font-weight:bold">Department</td>
      <td style="font-size:13px; font-weight:bold"><%=WI.getStrValue(strDepartment,"-")%></td>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="7%" height="25" class="thinborder" align="center">&nbsp;</td>
      <td width="5%" class="thinborder" align="center" style="font-size:6px;">%<br>D<br>I<br>S<br>T<br>R<br>I<br>B<br>U<br>T<br>I<br>O<br>N</td>
      <%for(int i = 0; i < vRetResult.size(); i += 8) {%>
	  	<td class="thinborder">
			<b><%=vRetResult.elementAt(i)%> - <%=vRetResult.elementAt(i + 4)%> (<%=astrConvertLecLab[Integer.parseInt((String)vRetResult.elementAt(i + 6))]%>)</b><br>
			<%=vRetResult.elementAt(i + 4)%><br>
			Respondents: <%=vRetResult.elementAt(i + 3)%><br>		</td>
      <%}%>
      <td width="5%" class="thinborder">A<br>V<br>G</td>
	  <td width="5%" class="thinborder">R<br>E<br>M<br>A<br>R<br>K</td>
    </tr>
<%for(int i = 0; i < vCatgIndex.size(); i += 4) {%>
    <tr> 
      <td width="7%" height="25" class="thinborder" align="center"><%=vCatgIndex.elementAt(i + 1)%><br>(<%=vCatgIndex.elementAt(i + 2)%>)</td>
      <td width="5%" class="thinborder" align="center"><%=vCatgIndex.elementAt(i + 3)%>%</td>
      <%for(int p = 0; p < vRetResult.size(); p += 8) {
	  vCatgPointRef = (Vector)((Vector) vRetResult.elementAt(p + 7)).clone();
	  //System.out.println("New : "+vCatgPointRef);
	  vCatgPointRef.remove(0);// System.out.println(vCatgPointRef);
	  for(int a = 0 ; a < vCatgIndex.size(); a += 2) {
	  	if(vCatgPointRef.size () > a && vCatgIndex.elementAt(i).equals(vCatgPointRef.elementAt(a))) {
			dTemp = Double.parseDouble((String)vCatgPointRef.elementAt(a + 1));
			
			vCatgPointRef.remove(a);vCatgPointRef.remove(a);
			break;
		}
		
	  }
	  %>
	  	<td class="thinborder"><%=dTemp%></td>
      <%dTempRowTotal += dTemp;}
	  dTempRowTotal = dTempRowTotal/(double)iTotalSubj;%>
      <td width="5%" class="thinborder"><%=CommonUtil.formatFloat(dTempRowTotal, true)%></td>
	  <td width="5%" class="thinborder"><%=facEval.convertPontToRemark(dTempRowTotal)%></td>
    </tr>
<%dTempRowTotal = 0d;}%>
    <tr style="font-weight:bold"> 
      <td width="7%" height="25" class="thinborder" align="center">Over all Rating </td>
      <td width="5%" class="thinborder" align="center">100 %</td>
      <%dTempRowTotal = 0d;
	  for(int p = 0; p < vRetResult.size(); p += 8) {
	  vCatgPointRef = (Vector) vRetResult.elementAt(p + 7);
	  
	  dTempRowTotal += Double.parseDouble((String)vCatgPointRef.elementAt(0));
	  %>
	  	<td class="thinborder"><%=vCatgPointRef.elementAt(0)%></td>
      <%}
	  dTempRowTotal = dTempRowTotal/(double)iTotalSubj;
	  %>
      <td width="5%" class="thinborder"><%=CommonUtil.formatFloat(dTempRowTotal, true)%></td>
	  <td width="5%" class="thinborder"><%=facEval.convertPontToRemark(dTempRowTotal)%></td>
    </tr>
  </table>
<%
vRetResult = facEval.getFacultyEvalSummaryGetTop3(dbOP, request);
if(vRetResult == null) {%>
	<%=facEval.getErrMsg()%>
<%}else{
    Vector vTop3Lec    = (Vector)vRetResult.remove(0);
    Vector vBottom3Lec = (Vector)vRetResult.remove(0);
    Vector vTop3Lab    = (Vector)vRetResult.remove(0);
    Vector vBottom3Lab = (Vector)vRetResult.remove(0);
%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td>&nbsp;</td>
	</tr>
  	<tr>
		<td style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:13px"> &nbsp;&nbsp;&nbsp;&nbsp;<u>Lecture</u></td>
	</tr>
  	<tr>
  	  <td><strong>Top 3 </strong></td>
    </tr>
  	<tr>
  	  <td>
	  <%if(vTop3Lec.size() > 0) {%>
	  	<%=vTop3Lec.remove(3)%> - (<%=vTop3Lec.remove(1)%>) <%=vTop3Lec.remove(1)%>
	  <%vTop3Lec.remove(0);}%>	  </td>
    </tr>
  	<tr>
  	  <td>
	  <%if(vTop3Lec.size() > 0) {%>
	  	<%=vTop3Lec.remove(3)%> - (<%=vTop3Lec.remove(1)%>) <%=vTop3Lec.remove(1)%>
	  <%vTop3Lec.remove(0);}%>	  </td>
    </tr>
  	<tr>
  	  <td>
	  <%if(vTop3Lec.size() > 0) {%>
	  	<%=vTop3Lec.remove(3)%> - (<%=vTop3Lec.remove(1)%>) <%=vTop3Lec.remove(1)%>
	  <%vTop3Lec.remove(0);}%>	  </td>
    </tr>
  	<tr>
  	  <td>&nbsp;</td>
    </tr>
  	<tr>
  	  <td><strong>Lowest 3 </strong></td>
    </tr>
  	<tr>
  	  <td>
	  <%if(vBottom3Lec.size() > 0) {%>
	  	<%=vBottom3Lec.remove(3)%> - (<%=vBottom3Lec.remove(1)%>) <%=vBottom3Lec.remove(1)%>
	  <%vBottom3Lec.remove(0);}%>	  </td>
    </tr>
  	<tr>
  	  <td>
	  <%if(vBottom3Lec.size() > 0) {%>
	  	<%=vBottom3Lec.remove(3)%> - (<%=vBottom3Lec.remove(1)%>) <%=vBottom3Lec.remove(1)%>
	  <%vBottom3Lec.remove(0);}%>	  </td>
    </tr>
  	<tr>
  	  <td>
	  <%if(vBottom3Lec.size() > 0) {%>
	  	<%=vBottom3Lec.remove(3)%> - (<%=vBottom3Lec.remove(1)%>) <%=vBottom3Lec.remove(1)%>
	  <%vBottom3Lec.remove(0);}%>	  </td>
    </tr>
  	<tr>
  	  <td>&nbsp;</td>
    </tr>
  	
  	<tr>
      <td style="font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; font-size:13px">&nbsp;&nbsp;&nbsp;&nbsp;<u>Laboratory</u></td>
    </tr>
  	<tr>
      <td><strong>Top 3 </strong></td>
    </tr>
  	<tr>
      <td>
	  <%if(vTop3Lab.size() > 0) {%>
	  	<%=vTop3Lab.remove(3)%> - (<%=vTop3Lab.remove(1)%>) <%=vTop3Lab.remove(1)%>
	  <%vTop3Lab.remove(0);}%>	  </td>
    </tr>
  	<tr>
      <td>
	  <%if(vTop3Lab.size() > 0) {%>
	  	<%=vTop3Lab.remove(3)%> - (<%=vTop3Lab.remove(1)%>) <%=vTop3Lab.remove(1)%>
	  <%vTop3Lab.remove(0);}%>	  </td>
    </tr>
  	<tr>
      <td>
	  <%if(vTop3Lab.size() > 0) {%>
	  	<%=vTop3Lab.remove(3)%> - (<%=vTop3Lab.remove(1)%>) <%=vTop3Lab.remove(1)%>
	  <%vTop3Lab.remove(0);}%>	  </td>
    </tr>
  	<tr>
      <td>&nbsp;</td>
    </tr>
  	<tr>
      <td><strong>Lowest 3 </strong></td>
    </tr>
  	<tr>
      <td>
	  <%if(vBottom3Lab.size() > 0) {%>
	  	<%=vBottom3Lab.remove(3)%> - (<%=vBottom3Lab.remove(1)%>) <%=vBottom3Lab.remove(1)%>
	  <%vBottom3Lab.remove(0);}%>	  </td>
    </tr>
  	<tr>
      <td>
	  <%if(vBottom3Lab.size() > 0) {%>
	  	<%=vBottom3Lab.remove(3)%> - (<%=vBottom3Lab.remove(1)%>) <%=vBottom3Lab.remove(1)%>
	  <%vBottom3Lab.remove(0);}%>	  </td>
    </tr>
  	<tr>
      <td>
	  <%if(vBottom3Lab.size() > 0) {%>
	  	<%=vBottom3Lab.remove(3)%> - (<%=vBottom3Lab.remove(1)%>) <%=vBottom3Lab.remove(1)%>
	  <%vBottom3Lab.remove(0);}%>	  </td>
    </tr>
  </table>
  
  <br><br>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td width="60%">
 			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td><i>Comments and suggestions: See attached sheet(s)</i></td>
					<td></td>
				</tr>
				<tr>
				  <td>&nbsp;</td>
				  <td></td>
			  </tr>
				<tr>
				  <td><i>Received by :</i> </td>
				  <td></td>
			  </tr>
				<tr>
				  <td>&nbsp;</td>
				  <td></td>
			  </tr>
				<tr>
				  <td>_________________________<br>
				  Signature over Printed Name 
			      </td>
				  <td></td>
			  </tr>
			</table>
		</td>
		<td>Certified True and Correct :<br>
	    
	    ______________________________________<br>
		
		
 			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				
				<tr>
					<td width="36%"><font size="1"><strong>4.60 - 5.00</strong></font></td>
					<td width="64%"><font size="1"><em>SO = Superior/Outstanding </em></font></td>
				</tr>
				<tr>
				  <td><font size="1"><strong>4.10 - 4.59 </strong></font></td>
				  <td><font size="1"><em>VG = Very Good </em></font></td>
			  </tr>
				<tr>
				  <td><font size="1"><strong>3.60 - 4.09 </strong></font></td>
				  <td><font size="1"><em>G = Good </em></font></td>
			  </tr>
				<tr>
				  <td><font size="1"><strong>3.00 - 3.59 </strong></font></td>
				  <td><font size="1"><em>F = Fair</em></font></td>
			  </tr>
				<tr>
				  <td><font size="1"><strong>2.00 - 2.99 </strong></font></td>
				  <td><font size="1"><em>NI = Needs Improvement </em></font></td>
			  </tr>
				<tr>
				  <td><font size="1"><strong>1.00 - 1.99 </strong></font></td>
				  <td><font size="1"><em>P = Poor </em></font></td>
			  </tr>
			</table>
			
		</td>
	</tr>
  </table>

<%}//show only if fac eval summary is ok..

}//if no err msg.. %>  
</body>
</html>
<%
dbOP.cleanUP();
%>