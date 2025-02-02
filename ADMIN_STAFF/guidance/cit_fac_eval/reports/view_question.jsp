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
<title>Faculty Evaluation - View Questions</title>
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
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Reports-View Comment","view_question.jsp");
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
														"view_question.jsp");
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

String strIsLAB = WI.fillTextValue("is_lab");
if(strIsLAB.equals("0"))
	strIsLAB = "LEC";
else	
	strIsLAB = "LAB";
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4"><div align="center"><strong>:::: FACULTY EVALUATION QUESTIONS ::::</strong></div></td>
    </tr>
  </table>
<%
String[] astrConvertTerm = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};
%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="19%" style="font-size:13px; font-weight:bold">SY/Term</td>
      <td width="77%" style="font-size:13px; font-weight:bold">
	  <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("semester"))]%>, <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-size:13px; font-weight:bold">Subject Type</td>
      <td style="font-size:13px; font-weight:bold"><%=strIsLAB%></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="4%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Count </td>
      <td width="96%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Question</td>
    </tr>
<%
String strSQLQuery ="select category, question from CIT_FAC_EVAL_QUESTION "+
					"join CIT_FAC_EVAL_CATG on (CIT_FAC_EVAL_CATG.catg_index = cit_fac_eval_question.catg_index) "+
					"where is_valid = 1 and is_lab = "+WI.fillTextValue("is_lab")+" order by CIT_FAC_EVAL_CATG.order_no, cit_fac_eval_question.ques_order ";
java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
strTemp = "";	int iCount = 0;					
while(rs.next()) {
strErrMsg = rs.getString(1);
if(strTemp.equals(strErrMsg))
	strErrMsg = null;
else
	strTemp = strErrMsg;
if(strErrMsg != null) {%>
    <tr>
      <td height="25" colspan="2" class="thinborder">&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
<%}%>	
    <tr> 
      <td height="25" class="thinborder"><%=++iCount%>.</td>
      <td height="25" class="thinborder"><%=rs.getString(2)%></td>
    </tr>
<%}//end of printing question%>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>