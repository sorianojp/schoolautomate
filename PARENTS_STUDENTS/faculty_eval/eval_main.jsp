<%
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	if(strUserIndex == null) {%>
	<p style="font-size:16px; color:#FF0000; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
		You are already logged out. Please login again.
	</p>
<%
	return;
}

String strTemp = (String)request.getParameter("evaluate");
if(strTemp != null && strTemp.equals("1")){%>
<jsp:forward page="./answer_sheet.jsp" />

<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Evaluate(strIsLAB, strSubIndex, strLoadIndex, strFacIndex) {
	document.form_.evaluate.value = 1;
	
	document.form_.subject.value  = strSubIndex;
	document.form_.is_lab.value   = strIsLAB;
    document.form_.fac_load.value = strLoadIndex;
    document.form_.faculty.value  = strFacIndex;
	
	document.form_.submit();
}
</script>

<body bgcolor="#9FBFD0">
<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	String strErrMsg = null;
	try {
		dbOP = new DBOperation();
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

String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
String strTerm   = (String)request.getSession(false).getAttribute("cur_sem");
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};


String strValidDateFr = null;
String strValidDateTo = null;
boolean bolEvalIsOpen = true;
String strSchedIndex = null;

//get evaluation date.. 
/**
	java.sql.ResultSet rs = null;
	String strSQLQuery = null;
    long lDateValidFr = 0l; 
    long lTimeNow = new java.util.Date().getTime();
    strSQLQuery = "select SCHED_INDEX,VALID_FR, valid_to from CIT_FAC_EVAL_SCHED where is_valid = 1 and sy_from ="+strSYFrom+
      " and semester = "+strTerm;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) {
    	strSchedIndex = rs.getString(1);
      	lDateValidFr = rs.getDate(2).getTime();//time at 12am..
      	strValidDateFr = ConversionTable.convertMMDDYYYY(rs.getDate(2));
      	strValidDateTo = ConversionTable.convertMMDDYYYY(rs.getDate(3));
     }
      rs.close();

      if(lTimeNow < lDateValidFr)
        strErrMsg = "Encoding of Evaluation is not open yet.. Please wait until :"+strValidDateFr;
**/
enrollment.FacultyEvaluation facEval = new enrollment.FacultyEvaluation();
Vector vRetResult = facEval.getStudentFacEvalMainPage(dbOP, request);
if(vRetResult == null) 
	strErrMsg = facEval.getErrMsg();
else {
	bolEvalIsOpen  = ((Boolean)vRetResult.remove(0)).booleanValue();
	strSchedIndex  = (String)vRetResult.remove(0);
	strValidDateFr = (String)vRetResult.remove(0);
	strValidDateTo = (String)vRetResult.remove(0);
	
	if(!bolEvalIsOpen) {
		strErrMsg = "Encoding of Evaluation is not open yet. Please wait until :"+strValidDateFr;
	}
}
%>
<form  method="post" name="form_" action="./eval_main.jsp">
<input type="hidden" name="schedule" value="<%=strSchedIndex%>">
<!-- Printing information. -->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::FACULTY EVALUATION SUBJECT LISTING ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td style="font-weight:bold; font-size:14px; color:#0000FF">Current SY-Term : <u> 
	  	<%=strSYFrom%> - <%=astrConvertTerm[Integer.parseInt(strTerm)]%></u></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="97%" style="font-weight:bold; font-size:14px; color:#0000FF">Evaluation completion date range: 
	  <u>
	  <%if(strValidDateFr ==null){%>
	  	Not Set
	  <%}else{%>
	  	<%=strValidDateFr%> - <%=strValidDateTo%>
	  <%}%>
	  </u>
	  </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="55%" colspan="2" align="center">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#47768F" align="center"><strong><font color="#FFFFFF">SUBJECTS/FACULTIES TO EVALUATE </font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
Vector vFacultyLoad = null;

String strIsLAB     = null;
String strLoadIndex = null;
String strFacIndex  = null;

String[] astrConvertLecLab = {"Lec","Lab"};

for(int i = 0; i< vRetResult.size(); i += 7) {
vFacultyLoad = (Vector)vRetResult.elementAt(i + 6);%>
    <tr> 
      <td height="25" style="font-size:11px; font-weight:bold"><u>
	  	<%=vRetResult.elementAt(i + 1)%> : <%=vRetResult.elementAt(i + 2)%> (Section : <%=vRetResult.elementAt(i + 3)%>)
		</u>
	  </td>
    </tr>
    <tr> 
      <td height="25" align="right">
	  	<table width="90%" class="thinborder" cellpadding="0" cellspacing="0">
			<tr>
				<td class="thinborder" colspan="3" height="18" bgcolor="#FFFF99" align="center"><strong>Faculty Load Detail</strong></td>
			</tr>
			<tr bgcolor="#CCCCCC" align="center" style="font-weight:bold">
				<td width="57%" class="thinborder">Faculty name</td>
				<td width="25%" class="thinborder">Lec/Lab </td>
				<td width="18%" class="thinborder">Evaluate</td>
			</tr>
			<%if(vFacultyLoad == null || vFacultyLoad.size() == 0) {%>
			<tr>
				<td colspan="3" class="thinborder" style="color:#FF0000">Faculty Load not found.</td>
			</tr>
			<%}else{
			while(vFacultyLoad.size() > 0) {
				strIsLAB     = (String)vFacultyLoad.remove(0);
				strLoadIndex = (String)vFacultyLoad.remove(0);
				strFacIndex  = (String)vFacultyLoad.remove(0);
				vFacultyLoad.remove(0);//remove id number of faculty.. 
			%>
			<tr>
				<td width="57%" class="thinborder" height="18"><%=vFacultyLoad.remove(0)%></td>
				<td width="25%" class="thinborder" align="center"><%=astrConvertLecLab[Integer.parseInt(strIsLAB)]%></td>
				<td width="18%" class="thinborder"><!-- is lab, sub_index, load_index, faculty_index -->
				<%if(bolEvalIsOpen){%>
					<a href="javascript:Evaluate('<%=strIsLAB%>','<%=vRetResult.elementAt(i)%>','<%=strLoadIndex%>','<%=strFacIndex%>');">Evaluate</a>
				<%}else{%>
					Eval not open.
				<%}%>
				</td>
			</tr>
			<%}//end of while for faculty.. 
			}%>
		</table>
	  </td>
    </tr>
<%}//end of for loop.. %>
  </table>
<%}//end of if condition.%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#47768F">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="semester" value="<%=strTerm%>">

<input type="hidden" name="subject" value="">
<input type="hidden" name="is_lab" value="">
<input type="hidden" name="fac_load" value="">
<input type="hidden" name="faculty" value="">

<input type="hidden" name="evaluate">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>