<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function AddRecord()
{
	
}

</script>
<body bgcolor="#663300">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRAssesRank"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ASSESSMENT AND EVALUATION-Ranking system",
								"hr_assessment_ranking.jsp");

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_assessment_ranking.jsp");
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
Vector vRetResult = new Vector();
HRAssesRank hrAR  = new HRAssesRank();
strTemp = WI.fillTextValue("page


%>

<form action="./hr_assessment_ranking.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          RANKING SYSTEM PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><strong></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="90%" border="0" align="center">
          <tr> 
            <td width="24%" height="25"><div align="center"><strong>Effectivity Year </strong></div></td>
            <td width="53%">From <input name="yr_from" type="text" id="yr_from" size="4" maxlength="4">
              to 
              <input name="yr_to" type="text" id="yr_to" size="4" maxlength="4">
              (leave year to empty if ranking is valid)</td>
            <td width="23%"><strong><img src="../../../images/form_proceed.gif" border="0"> 
              </strong></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="15" colspan="3"><hr size="1"></td>
          </tr>
        </table>
        <table width="90%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr bgcolor="#FFFFFF"> 
            <td width="2%" height="25"><div align="center"></div></td>
            <td width="16%"><strong>Rank</strong></td>
            <td width="82%" height="25"><input name="rank" type="text" id="rank" size="48"></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><div align="center"></div></td>
            <td height="25"><strong>Total Score Range</strong></td>
            <td height="25"><input name="score_from" type="text" id="score_from" size="4">
              to 
              <input name="score_to" type="text" id="score_to" size="4"></td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><div align="center"></div></td>
            <td height="25"><strong>Salary Grade</strong></td>
            <td height="25"><select name="sal_grade_index">
                <option value="">Select A Salary Grade</option>
                <%=dbOP.loadCombo("SAL_GRADE_INDEX","GRADE_NAME"," FROM HR_PRELOAD_SAL_GRADE",strTemp,false)%> 
              </select>
              $salary - range.</td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td height="25"><div align="center"></div></td>
            <td height="25">&nbsp;</td>
            <td height="25"><strong><img src="../../../images/add.gif" border="0"></strong><font size="1">click 
              to add entries <strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="../../../images/edit.gif" width="40" height="26" border="0"></strong>click 
              to save changes<strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="../../../images/cancel.gif" border="0"></strong>click 
              to cancel/clear entries/changes</font></td>
          </tr>
        </table>
		          
        <table width="90%" border="1" align="center" cellpadding="0" cellspacing="0">
          <tr bgcolor="#CCCCCC"> 
            <td height="25" colspan="7"><div align="center"><strong>RANKING SYSTEM 
                LIST</strong></div></td>
          </tr>
          <tr> 
            <td width="15%" height="25"><div align="center"><font size="1"><strong>EFFECTIVITY 
                YEAR </strong></font></div></td>
            <td><div align="center"><font size="1"><strong>RANK</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>TOTAL SCORE RANGE</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>SALARY GRADE</strong></font></div></td>
            <td><div align="center"><font size="1"><strong>SALARY RANGE</strong></font></div></td>
            <td>&nbsp;</td>
            <td width="5%">&nbsp;</td>
          </tr>
          <tr> 
            <td height="25"><div align="center"><font size="1">2004-2005</font></div></td>
            <td width="30%"><div align="center"><font size="1">Assistant Professor 
                1</font></div></td>
            <td width="15%"><div align="center"><font size="1">130 - 139 </font></div></td>
            <td width="14%"><div align="center"><font size="1">&nbsp;</font></div></td>
            <td width="16%">&nbsp;</td>
            <td width="5%"><strong><img src="../../../images/edit.gif" border="0"></strong></td>
            <td><strong><img src="../../../images/delete.gif" border="0"></strong></td>
          </tr>
        </table>
        
</tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
</form>
</body>
</html>

