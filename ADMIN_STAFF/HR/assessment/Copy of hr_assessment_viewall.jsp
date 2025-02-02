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

function ReloadPage(){
	document.staff_profile.page_action.value = "";
	document.staff_profile.submit();
}
function DeleteRecord(index){
	document.staff_profile.info_index.value = index;
	document.staff_profile.page_action.value="0";
	document.staff_profile.submit();
}

</script>
<body bgcolor="#663300">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	String strRootPath = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_assessment.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_assessment.jsp");
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

//end authorization
Vector vRetResult = null;
HREvaluationSheet hrES = new HREvaluationSheet();
boolean bolNoError = true;
String strPageAction = WI.fillTextValue("page_action");
	
	if (strPageAction.compareTo("0") == 0){
		vRetResult = hrES.operateOnEvalPersonnelDtls(dbOP,request,0);		
		
		if (vRetResult == null){
			strErrMsg = hrES.getErrMsg();
			bolNoError = false;
		}else{
			strErrMsg = "Personnel Assessment deleted successfully";
		}
	}	

	if (bolNoError){
		vRetResult = hrES.operateOnEvalPersonnelDtls(dbOP,request,4);
		if (vRetResult == null)	{
			strErrMsg = hrES.getErrMsg();
		}
	}

%>
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EMPLOYEES ASSESSMENT &amp; EVALUATION SUMMARY ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#FFFFFF">&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp")%></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr> 
            <td>Show : 
              <select name="criteria_index">
                <option value="" selected>Select Evaluation Criteria</option>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> </select></td>
            <td width="61%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border=0></a></td>
          </tr>
          <tr> 
            <td colspan="2">Order by : 
              <select name="select">
                <option value="1">Rank</option>
                <option value="1">Employee ID</option>
                <option value="2">Name</option>
                <option>Firstname</option>
                <option value="3">Date of Evaluation</option>
              </select> <select name="select4">
                <option>Ascending</option>
                <option>Descending</option>
              </select> <select name="select5">
                <option value="1">Rank</option>
                <option value="1">Employee ID</option>
                <option value="2">Lastname</option>
                <option>Firstname</option>
                <option value="3">Date of Evaluation</option>
              </select> <select name="select5">
                <option>Ascending</option>
                <option>Descending</option>
              </select> </td>
          </tr>
        </table></td>
    </tr>
  </table>
  <% if (vRetResult !=null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="50%"><img src="../../../images/print.gif" ><font size="1">click 
        to print summary </font></td>
      <td colspan="2"><div align="right"><font size="1">Jump to Page : 
          <select name="select2">
            <option>1 of 4</option>
            <option>2 of 4</option>
            <option>3 of 4</option>
            <option>4 of 4</option>
          </select>
          </font></div></td>
    </tr>
    <tr> 
      <td colspan="3"><table bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
          <tr> 
            <td height="25" colspan="7" bgcolor="#CCCCCC"><div align="center"><strong><font color="#FF0000">LIST 
                OF ALL EVALUATED EMPLOYEES</font></strong></div>
              <div align="center"></div></td>
          </tr>
          <tr> 
            <td width="12%" height="25"><div align="center"><font size="1"><strong>Employee 
                ID </strong></font></div></td>
            <td width="25%"> <div align="center"><font size="1"><strong>Name</strong></font></div></td>
            <td width="13%" align="center"><font size="1"><strong>Evaluator</strong></font></td>
            <td width="20%" align="center"><font size="1"><strong>Date of Evaluation</strong></font></td>
            <td width="15%" align="center"><font size="1"><strong>Grand Total 
              Rating</strong></font></td>
            <td colspan="2" align="center"><strong><font size="1">Operations</font></strong></td>
          </tr>
          <% for (int i = 0; i < vRetResult.size() ; i+=14) {%>
          <tr> 
            <td><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
            <td><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
            <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+9)%></font></td>
            <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+11)%></font></td>
            <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
            <td width="8%" align="center"><img src="../../../images/view.gif" ></td>
            <td width="7%"> <% if(iAccessLevel==2) { %> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+3)%>')"><img src="../../../images/delete.gif" width="55" height="28" border ="0"></a> 
              <%}else{ %> &nbsp; <%}%> </td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <tr> 
      <td colspan="3"><div align="center"><img src="../../../images/print.gif" ><font size="1">click 
          to print summary </font></div></td>
    </tr>
  </table>
<%}//end if (vRetResult != null) %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action"> 
<input type="hidden" name="info_index">
</form>
</body>
</html>

<%
	dbOP.cleanUP();
%>