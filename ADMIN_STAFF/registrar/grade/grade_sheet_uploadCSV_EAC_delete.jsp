<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Teaser()
{
	var pgLoc = "./grade_sheet_previewCSV_EAC.jsp?CSV="+document.form_.csv_area.value;
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=600,height=600,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction)
{
	document.form_.page_action.value=strAction;
	document.form_.auto_format.value = '';
	//document.form_.submit();
}
function ReloadPage()
{
	document.form_.auto_format.value = '';
	document.form_.page_action.value="";
	document.form_.submit();
}
function ResetPage()
{
	document.form_.page_action.value="";
	document.form_.subject.selectedIndex = 0;
	document.form_.auto_format.value = '';
	document.form_.submit();
}
function AutoFormat() {
	if(!document.form_.add_comma.checked) {
		alert("Please select autoformat condition.");
		return;
	}
	document.form_.auto_format.value = '1';
	document.form_.submit();
}

</script>



<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	Vector vSecDetail = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_uploadCSV_EAC_delete.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//I have to check if grade sheet is locked.. 
if(new enrollment.SetParameter().isGsLocked(dbOP))
	iAccessLevel = 0;

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

//end of authenticaion code.
enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.GradeSystem  GS = new enrollment.GradeSystem();
GradeSystemExtn gsExtn     = new GradeSystemExtn();

String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
String strSubSecIndex   = null;

Vector vRetResult = null;

String strFormattedGrade = "";

if(WI.fillTextValue("auto_format").length() > 0) {
	boolean bolAddComma = WI.fillTextValue("add_comma").length() > 0;
	
	String strGradeInput = WI.fillTextValue("csv_area");
	if(strGradeInput.length() > 0) {
		int iIndexOf = 0;
		String strID = null;String strGrade = null; String strRemark = null;
		while(strGradeInput.length() > 0) {
			iIndexOf = strGradeInput.indexOf(",");
			strID = strGradeInput.substring(0, iIndexOf);
			strGradeInput = strGradeInput.substring(iIndexOf + 1);
			
			iIndexOf = strGradeInput.indexOf(",");
			strGrade = strGradeInput.substring(0, iIndexOf);
			strGradeInput = strGradeInput.substring(iIndexOf + 1);
		
			iIndexOf = strGradeInput.indexOf("\r\n");
			if(iIndexOf > -1) {
				strRemark = strGradeInput.substring(0, iIndexOf);
				if(strRemark.endsWith(","))
					strRemark = strRemark.substring(0,strRemark.length() - 1);
				strGradeInput = strGradeInput.substring(iIndexOf + 2);
			}
			else {
				strRemark = strGradeInput;
				strGradeInput = "";
			}
			if(strID.startsWith("'"))
				strID = strID.substring(1);

			strFormattedGrade+= strID+","+strGrade+","+strRemark;
			if(strGradeInput.length() > 0) 
				strFormattedGrade += ",\r\n";
		}
		///System.out.println(vGradeInput);		
	}
	
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0) //save grade sheet.
{
	vRetResult = gsExtn.uploadCSVtoGradeSheetEAC(dbOP, request);
	if (vRetResult == null)
		strErrMsg = gsExtn.getErrMsg();
	else
		strErrMsg = (String)vRetResult.elementAt(0);
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./grade_sheet_uploadCSV_EAC_delete.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

<input type="hidden" name="show_delete">
<input type="hidden" name="show_save">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="7"><div align="center"><font color="#FFFFFF"><strong>::::
          GRADE SHEETS PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;<strong><font size="3" color="#FF0000">
	  <%=WI.getStrValue(strErrMsg,"MESSAGE: <br>","","")%></strong></td>
    </tr>
    
    <tr>
      <td width="1%" height="25" rowspan="4" >&nbsp;</td>
      <td width="25%" height="25" valign="bottom" >Grades for</td>
      <td width="22%" valign="bottom" >Term</td>
      <td width="27%" valign="bottom" >School Year</td>
      <td colspan="2" >&nbsp; </td>
      <td width="8%" >&nbsp;</td>
    </tr>
    <tr>
      <td height="25" valign="bottom" >
        <select name="grade_for">
          <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc", request.getParameter("grade_for"), false)%>
        </select></td>
      <td valign="bottom" >
	  <select name="offering_sem" onChange="ReloadPage();">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("offering_sem");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td valign="bottom" > 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">      </td>
      <td colspan="2" >
	  <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>      </td>
      <td width="8%" >&nbsp;</td>
    </tr>
</table>
<%
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("offering_sem").length() >0){
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="5%">&nbsp;</td>
		<td width="90%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
	</tr>
	
	<tr>
		
      <td colspan="3">&nbsp;<font size="1"><strong>CSV values must be in format shown below </strong></font></td>
	</tr>
	<tr>
	  <td colspan="3">&nbsp;Example : 06-0001-456,Sub Code, 90,Passed,</td>
    </tr>
	<tr>
	  <td colspan="3" height="35" style="font-size:11px; color:#0000FF; font-weight:bold"><input type="checkbox" name="add_comma" value="checked" <%=WI.fillTextValue("add_comma")%>> Add comma at end of each line (end of each set)
	  &nbsp;&nbsp;&nbsp;
	  <a href="javascript:AutoFormat();"><font color="#FF0000">Click here to auto format</font></a>	  </td>
    </tr>
	<tr>
		<td>&nbsp;</td>
		<td>
		<%
		if (vRetResult!= null && vRetResult.size()>0)
			strTemp = WI.getStrValue((String)vRetResult.elementAt(1),"");
		else
			strTemp = WI.fillTextValue("csv_area");
		//if(vFormattedGrade != null && vFormattedGrade.size() > 0) 
			//strTemp = CommonUtil.convertVectorToCSV(vFormattedGrade);
		if(strFormattedGrade != null && strFormattedGrade.length() > 0) 
			strTemp = strFormattedGrade;%>
		<textarea rows="60" cols="100" name="csv_area" class="textbox" style="font-size:11px"><%=strTemp%></textarea></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" align="center">
		<input type="submit" name="1" value="<<< Delete Grade >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1');">
		&nbsp;
		&nbsp;<a href="javascript:Teaser();"><img src="../../../images/view.gif" border="0"></a><font size="1">click to preview CSV entries</font>		</td>
	</tr>
</table>
<%}//only if SY from infromation is filled in%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="auto_format">
<input type="hidden" name="del_grade" value="1">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
