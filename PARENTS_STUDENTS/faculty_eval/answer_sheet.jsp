<%@ page language="java" import="utility.*,enrollment.FacultyEvaluation, java.util.Vector" buffer="16kb"%>
<%
String strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	if(strUserIndex == null) {%>
	<p style="font-size:16px; color:#FF0000; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
		You are already logged out. Please login again.
	</p>
<%
	return;
}


	WebInterface WI = new WebInterface(request);

	String strSchedIndex   = WI.fillTextValue("schedule");
	String strSubIndex     = WI.fillTextValue("subject"); 
	String strIsLAB        = WI.fillTextValue("is_lab");
	String strFacLoadIndex = WI.fillTextValue("fac_load");
	String strFacIndex     = WI.fillTextValue("faculty");

	if(strSchedIndex.length() == 0 || strSubIndex.length() == 0 || strIsLAB.length() == 0 || strFacLoadIndex.length() == 0 || strFacIndex.length() == 0) {%>
	
	<p style="font-size:14px; color:#FF0000; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif">
		Some Information missing. Please try again.
	</p>
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
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function AjaxUpdateAns(strQuesIndex, strMainIndex) {
	//I have to get the ans value. .
	return;
	var objRadio;
	eval('objRadio = document.form_._'+strQuesIndex);
	var selVal;
	var iIncr = 0;
	while(objRadio[iIncr]) {
		if(objRadio[iIncr].checked) {
			selVal = objRadio[iIncr].value;
			break;
		}
		++iIncr;
	}
	var objCOAInput = document.getElementById(strQuesIndex);
			
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=213&q="+strQuesIndex+"&a="+selVal+"&m="+strMainIndex;

	this.processRequest(strURL);
}
</script>

<body bgcolor="#9FBFD0">
<%
	DBOperation dbOP = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	String strErrMsg = null;
	String strTemp   =  null;
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
boolean bolIsAnswered = false;

Vector vRetResult     = null; Vector vQuesCategory = null;
Vector vAnsweredList  = null; boolean bolHideFinalize = false;

enrollment.FacultyEvaluation facEval = new enrollment.FacultyEvaluation();
Vector vAnsMainInfo = facEval.createAnsMain(dbOP, request);	//System.out.println("I am here."+strErrMsg);

if(vAnsMainInfo == null) {
	strErrMsg = facEval.getErrMsg();
}
else { //System.out.println("finalize value : "+WI.fillTextValue("finalize"));
	if(WI.fillTextValue("finalize").equals("1")) {
		if(facEval.finalizeAnswer(dbOP, request, (String)vAnsMainInfo.elementAt(2)) == null)
			strErrMsg = facEval.getErrMsg();
		else {	
			strErrMsg = "Evaluation Answered successfully.";
			bolHideFinalize = true;
		}
		//System.out.println(strErrMsg);
	}
	strValidDateFr = (String)vAnsMainInfo.elementAt(0);
	strValidDateTo = (String)vAnsMainInfo.elementAt(1);
	
	vRetResult = facEval.getAnswerSheet(dbOP, (String)vAnsMainInfo.elementAt(2), strSchedIndex);
	if(vRetResult == null)
		strErrMsg = facEval.getErrMsg();
	else {
		bolIsAnswered = ((Boolean)vRetResult.remove(0)).booleanValue();
		vQuesCategory = (Vector)vRetResult.remove(0);
	}
	
	//I have to finlalize if clicked,, else get the questions already answered. 
}

String strSubjectInfo = null;
String strFacultyName = null;

String[] astrConvertLecLab = {"Lec","Lab"};
String strSQLQuery  = null;
java.sql.ResultSet rs = null;
if(strSubIndex != null) {
	strSQLQuery = "select sub_code, sub_name from subject where sub_index = "+strSubIndex;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) 
		strSubjectInfo = rs.getString(1)+" :::: "+rs.getString(2) + " ("+astrConvertLecLab[Integer.parseInt(strIsLAB)]+")";
	rs.close();
}
if(strFacIndex.length() > 0) {
	strSQLQuery = "select fname, mname, lname from user_table where user_index = "+strFacIndex;
	rs = dbOP.executeQuery(strSQLQuery);
	if(rs.next()) 
		strFacultyName = WebInterface.formatName(rs.getString(1), rs.getString(1), rs.getString(1), 4);
	rs.close();
}

String strQuesRef = null;
%>
<form  method="post" name="form_" action="./answer_sheet.jsp">

<input type="hidden" name="schedule" value="<%=strSchedIndex%>">
<input type="hidden" name="subject" value="<%=strSubIndex%>">
<input type="hidden" name="is_lab" value="<%=strIsLAB%>">
<input type="hidden" name="fac_load" value="<%=strFacLoadIndex%>">
<input type="hidden" name="faculty" value="<%=strFacIndex%>">
<!-- Printing information. -->
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#47768F"><div align="center"><font color="#FFFFFF"><strong>::::FACULTY EVALUATION ANSWER SHEET ::::</strong></font></div></td>

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
	  </u>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; font-size:14px; color:#0000FF">Subject : <%=WI.getStrValue(strSubjectInfo, "not found.")%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td style="font-weight:bold; font-size:14px; color:#0000FF">Faculty : <%=WI.getStrValue(strFacultyName, "not found.")%></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="55%" align="center">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="top">Note : </td>
      <td colspan="2">Your college would like you to participate in the on-going development of your teachers. By this form, you are given the opportunity to assess their strengths and weaknesses. Your objective, honest and sincere appraisal of your teachers will enable all of us in our school to pursue our goal of academic excellence. Be assured of the confidentiality of your evaluation.</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><!--Note : Answer to a question is saved upon clicking the radio button. After Finalize is clicked, answers can't be modified anymore-->
	  All the questions are mandatory except with category "Optional to fill up"	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#47768F" align="center"><strong><font color="#FFFFFF">::: Evaluation Questions ::: </font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<%
int iIndexOf = 0;

Vector vEvalPoint = new Vector();
strSQLQuery = "select POINT_NAME, POINT_ORDER_NO from CIT_FAC_EVAL_POINT order by POINT_ORDER_NO";
rs = dbOP.executeQuery(strSQLQuery);
while(rs.next()) {
	vEvalPoint.addElement(rs.getString(1));
	vEvalPoint.addElement(rs.getString(2));
}
rs.close();

String strAnsweredVal = null;
String[] astrBGColor = {"","#FF0000"};

for(int i = 0; i< vRetResult.size(); i += 6) {
strTemp = (String)vRetResult.elementAt(i);

if(strQuesRef == null)
	strQuesRef = (String)vRetResult.elementAt(i + 1);
else	
	strQuesRef += ","+(String)vRetResult.elementAt(i + 1);

		//get here answer if answered..
		strAnsweredVal = (String)vRetResult.elementAt(i + 5);
		
			
		
		

if(strTemp != null) {//print category.. 
iIndexOf = vQuesCategory.indexOf(strTemp);
%>
    <tr> 
      <td style="font-size:11px; font-weight:bold; color:#FF0000"><u><%=vQuesCategory.elementAt(iIndexOf + 1)%></u></td>
    </tr>
<%}%>
    <tr> 
      <td height="25" valign="bottom">
	  <font color="<%if(strAnsweredVal == null && bolIsAnswered){%><%=astrBGColor[1]%><%}else{%><%=astrBGColor[0]%><%}%>">
	  <%=vRetResult.elementAt(i + 3)%>. <%=vRetResult.elementAt(i + 2)%>
	  </font>
	  <input type="hidden" name="ans_<%=(String)vRetResult.elementAt(i + 1)%>" value="<%=(String)vRetResult.elementAt(i + 4)%>"></td>
    </tr>
    <tr> 
      <td height="25" valign="top" style="font-size:11px;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Answer : 
	  	<%
		for(int p = 0; p < vEvalPoint.size(); p += 2) {
		if(strAnsweredVal != null && strAnsweredVal.equals(vEvalPoint.elementAt(p + 1)) )
			strErrMsg = " checked";
		else
			strErrMsg = "";
		%>
			<input type="radio" <%=strErrMsg%> name="_<%=(String)vRetResult.elementAt(i + 1)%>" value="<%=vEvalPoint.elementAt(p + 1)%>" onClick="AjaxUpdateAns('<%=(String)vRetResult.elementAt(i + 1)%>', '<%=vAnsMainInfo.elementAt(2)%>');"><%=vEvalPoint.elementAt(p)%> &nbsp;
		<%}%>
		&nbsp;&nbsp; <font style="font-size:9px; color:#0000FF; font-weight:bold"><label id="<%=(String)vRetResult.elementAt(i + 1)%>"></label></font>
	  </td>
    </tr>
<%}//end of for loop.. %>
  </table>
<%}//end of if condition.

if(vAnsMainInfo != null && vAnsMainInfo.size() > 0) {
	strTemp = WI.fillTextValue("pos_rem");
	if(strTemp.length() == 0) 
		strTemp = (String)vAnsMainInfo.elementAt(5);%>
		  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		  <tr>
			<td height="25" style="font-size:11px; font-weight:bold; color:#FF0000">Optional to fill up: </td>
		  </tr>
		  <tr>
			<td height="25">Positive Remark<br>
				<textarea name="pos_rem" class="textbox" style="font-size:11px;" cols="100" rows="5" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
			</td>
		  </tr>
		  <tr>
			<td height="25">Negative Remark<br>
		<%
		strTemp = WI.fillTextValue("neg_rem");
		if(strTemp.length() == 0) 
			strTemp = (String)vAnsMainInfo.elementAt(6);%>
					<textarea name="neg_rem" class="textbox" style="font-size:11px;" cols="100" rows="5" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
			</td>
		  </tr>
		  <tr>
			<td height="25">Recommendation<br>
		<%
		strTemp = WI.fillTextValue("recommendation");
		if(strTemp.length() == 0) 
			strTemp = (String)vAnsMainInfo.elementAt(4);%>
				<textarea name="recommendation" class="textbox" style="font-size:11px;" cols="100" rows="5" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea>
			</td>
		  </tr>
		
		  <tr>
			<td height="35" align="center" style="font-size:11px;">
			<%if(vAnsMainInfo.elementAt(3) != null || bolHideFinalize){%>
				Answer sheet already finalized.
			<%}else{%>
				<input type="submit" name="Finalize" value="Finalize Answer" onClick="document.form_.finalize.value='1';document.form_.save_all.value='1'"> Click to save all the answers
			<%}%>
			</td>
		  </tr>
		</table>
<%}%>

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

<input type="hidden" name="finalize">
<input type="hidden" name="ques_ref" value="<%=strQuesRef%>">
<input type="hidden" name="save_all" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>