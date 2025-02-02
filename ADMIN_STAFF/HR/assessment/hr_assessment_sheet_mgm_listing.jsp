<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
<%

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
if(strSchCode.startsWith("VMA")){%>
	<jsp:forward page="./hr_assessment_sheet_mgm_listing_vma.jsp"></jsp:forward>
<%return;}

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function AddRecord(){
	document.staff_profile.page_action.value="5";
	this.ReloadPage();
}
function ReloadPage() {
	this.SubmitOnce('staff_profile');
}
function ShowHideTDLayer(bolShowStat) {
	if(bolShowStat) 
		this.showLayer('row_1');
	else
		this.hideLayer('row_1');		
}


</script>
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

if(WI.fillTextValue("page_action").length() > 0) {
	if(hrEvalSheet.operateOnEvaluationPoints(dbOP, request, 5) == null)
		strErrMsg = hrEvalSheet.getErrMsg();
	else	
		strErrMsg = "Active status changed successfully.";
}

if (WI.fillTextValue("cIndex").length() > 0){
	vRetResult = hrEvalSheet.operateOnEvaluationPoints(dbOP,request,3);
	
	if (vRetResult == null){
		strErrMsg = hrEvalSheet.getErrMsg();
	}
}
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_assessment_sheet_mgm_listing.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          EVALUATION SHEET MANAGEMENT -LISTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#FFFFFF"><strong><a href="./hr_assessment_sheet_mgmt_main.jsp"><img src="../../../images/go_back.gif" border="0"></a>
	   <%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td>
<%
	strTemp = WI.fillTextValue("cIndex");
	if (strTemp.length() > 0){
%>	  
	   <img src="../../../images/sidebar.gif" width="11" height="270" align="right">
<%}%>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td width="20%" height="25"><div align="center"><strong>Criteria for</strong></div></td>
            <td> <select name="cIndex" id="cIndex" onChange='ReloadPage();'>
                <option value="" selected>Select Evaluation Criteria</option>
                <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> </select></td>
            <td>&nbsp;</td>
          </tr>
          <% if ((strTemp.length() > 0) && vRetResult != null  && vRetResult.size() > 0){ %>
          <tr bgcolor="#CCCCCC"> 
            <td height="25" colspan="3"><div align="center"><strong>LIST OF EVALUATION 
                SHEETS </strong></div></td>
          </tr>
          <tr> 
            <td height="25"><div align="center"><strong>SHEET YEAR</strong></div></td>
            <td><div align="center"><strong>GRAND TOTAL POINTS</strong></div></td>
            <td><div align="center"><strong>IS ACTIVE</strong></div></td>
          </tr>
          <%for (int i = 0; i < vRetResult.size() ; i+=5) {%>
          <tr> 
            <td height="25"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%> - <%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></div></td>
            <td width="67%"><div align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></div></td>
            <td width="13%"><div align="center"> 
			<%
			strTemp = (String)vRetResult.elementAt(i + 4);
			if(strTemp != null && strTemp.compareTo("1") == 0) 
				strTemp = " checked";
			else	
				strTemp = "";
			%>
                <input type="radio" name="is_active" value="<%=(String)vRetResult.elementAt(i)%>" onClick="ShowHideTDLayer(true);"<%=strTemp%>>
              </div></td>
          </tr>
          <%} // end for loop%>
          <tr> 
            <td height="10"><div align="center"></div></td>
            <td width="67%">&nbsp;</td>
            <td width="13%">&nbsp;</td>
          </tr>
<%
if(iAccessLevel > 1) {%>
          <tr id="row_1"> 
            <td height="25">&nbsp;</td>
            <td colspan="2"><a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a>Click 
                to change active state.<font size="1"><br>
                <strong>NOTE: By default highest year is active unless active 
                state is set to other year level.</strong></font>
              </td>
          </tr>
<script language="JavaScript">
this.ShowHideTDLayer(false);
</script>		  
   <%}
} // end listing
%>
        </table>

      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>

<%
	dbOP.cleanUP();
%>