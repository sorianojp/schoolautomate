<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">

function ChangeMainEval(){
	document.staff_profile.labelname.value = document.staff_profile.eval_main[document.staff_profile.eval_main.selectedIndex].text;
	ReloadPage();
}

function ChangeCriteria(){
	ReloadPage();
}

function ChangeSubEval(){
	ReloadPage();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
}


function DeleteRecord(index)
{
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	document.staff_profile.submit();
}

function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}


</script>
<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;



//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ASSESSMENT AND EVALUATION-Evaluation Sheet","hr_assessment_sheet_mgm_listing.jsp");
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
														"hr_assessment_sheet_mgm_listing.jsp");
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
Vector vRetResult = null;
HREvaluationSheet hrEvalSheet = new HREvaluationSheet();


vRetResult = hrEvalSheet.operateOnEvaluationPoints(dbOP,request,3);
%>
<body bgcolor="#663300">
<form action="./hr_assessment_sheet_mgm_listing.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          EVALUATION SHEET MANAGEMENT -LISTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><strong><a href="./hr_assessment_sheet_mgmt_main.jsp"><img src="../../../images/go_back.gif" border="0"></a> <%=WI.getStrValue("")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
        <br>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr>
            <td width="17%" height="25"><div align="center"><strong>Criteria for</strong></div></td>
            <td colspan="3"> <select name="cIndex" id="cIndex" onChange='ChangeCriteria();'>
                <option value="">Select Evaluation Criteria</option>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> 
				</select></td>
            <td width="12%"><strong> </strong></td>
          </tr>
<% if (vRetResult != null  && vRetResult.size() > 0){ %>
          <tr bgcolor="#CCCCCC">
            <td height="25" colspan="5"><div align="center"><strong>LIST OF EVALUATION
                SHEETS </strong></div></td>
          </tr>
          <tr>
            <td height="25"><div align="center"><font size="1"><strong>SHEET YEAR</strong></font></div></td>
            <td colspan="4"><font size="1"><strong>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;GRAND TOTAL POINTS</strong></font></td>
          </tr>
<% for (int i = 0; i < vRetResult.size() ; i+=4) {%>
		  <tr>
            <td height="25"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%> -
			<%=WI.getStrValue((String)vRetResult.elementAt(i+2))%>
				</td>
            <td width="55%"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
            <td width="8%"><strong><img src="../../../images/view.gif" border="0"></strong></td>
            <td width="8%"><strong><img src="../../../images/edit.gif" border="0"></strong></td>
            <td><strong><img src="../../../images/delete.gif" border="0"></strong></td>
			</tr>
<%} // end for loop
} // end listing
%>
        </table>

      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action">
</form>
</body>
</html>

