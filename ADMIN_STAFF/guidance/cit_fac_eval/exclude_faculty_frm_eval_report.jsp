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
<title>Faculty Evaluation - Exclude Faculty Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strIndex, strPageAction) {
	document.form_.info_index.value = strIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
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

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","FACULTY EVALUATION",request.getRemoteAddr(),
														"exclude_faculty_frm_eval_report.jsp");
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

FacultyEvaluation facEval = new FacultyEvaluation();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(facEval.opeateOnExcludeEvalInReport(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = facEval.getErrMsg();
	else {	
		strErrMsg = "Operation Successful.";
	}
}

boolean bolShowExcluded = WI.fillTextValue("show_con").equals("1");
if(WI.fillTextValue("sy_from").length() > 0) {
	if(bolShowExcluded)
		vRetResult = facEval.opeateOnExcludeEvalInReport(dbOP, request, 4);
	else
		vRetResult = facEval.opeateOnExcludeEvalInReport(dbOP, request, 3);
	
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = facEval.getErrMsg();
}
%>
<form action="./exclude_faculty_frm_eval_report.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::EXCLUDE FACULTY FROM EVALUATION ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%">SY-Term</td>
      <td width="26%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
	<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="DisplaySYTo();">
        to
<%
if(strTemp.length() > 0) 
	strTemp = Integer.toString(Integer.parseInt(strTemp) + 1);
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp; <select name="semester">
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

if(strTemp == null)
	strTemp = "";

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") ==0){%>
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
        </select>	  </td>
      <td width="62%"><input type="submit" name="1" value="&nbsp;&nbsp;Proceed >>&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF">&nbsp;
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="radio" value="0" name="show_con" <%=strTemp%> onClick="document.form_.page_action.value='';document.form_.submit();"> Show Faculties having Evaluation (but not excluded) &nbsp;&nbsp;
<%
if(strTemp.length() == 0) 
	strTemp = " checked";
else	
	strTemp = "";
%>
	  <input type="radio" value="1" name="show_con" <%=strTemp%> onClick="document.form_.page_action.value='';document.form_.submit();"> <font color="#FF0000">Show Faculties Excluded in Evaluation report</font>	  </td>
      <td width="0%">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="22%">&nbsp;</td>
      <td width="33%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
int iCount = 0;
String[] astrConvertIsLAB = {"&nbsp;","YES"};

if(bolShowExcluded) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">FACULTY EXCLUDED FROM REPORT</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">SL # </td> 
      <td width="10%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder"> ID Number </td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Faculty Name </td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Section</td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Subject Code </td>
      <td width="30%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Subject Name </td>
      <td width="5%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Is LAB </td>
      <td width="5%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Delete</td>
    </tr>
<%//System.out.println(vRetResult);
for(int i=0; i<vRetResult.size(); i+=7, ++iCount){%>
    <tr>
      <td height="25" class="thinborder"><%=iCount+1%>.</td> 
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" align="center"><%=astrConvertIsLAB[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder" align="center"><a href="javascript:PageAction('<%=vRetResult.elementAt(i + 6)%>','0')"><img src="../../../images/delete.gif" border="0"></a>
	  </td>
    </tr>
<%}%>
  </table>
<%}else{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">FACULTY EVALUATED BY STUDENT BUT NOT EXCLUDED </font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">SL # </td> 
      <td width="10%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder"> ID Number </td>
      <td width="15%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Faculty Name </td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Section</td>
      <td width="15%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Subject Code </td>
      <td width="30%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Subject Name </td>
      <td width="5%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Is LAB </td>
      <td width="5%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">Select</td>
    </tr>
<%//System.out.println(vRetResult);
for(int i=0; i<vRetResult.size(); i+=8, ++iCount){%>
    <tr>
      <td height="25" class="thinborder"><%=iCount+1%>.</td> 
      <td class="thinborder"><%=vRetResult.elementAt(i)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" align="center"><%=astrConvertIsLAB[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder" align="center"><input type="checkbox" name="sel_<%=iCount%>" value="<%=vRetResult.elementAt(i + 7)%>">
	  <input type="hidden" name="fac_<%=iCount%>" value="<%=vRetResult.elementAt(i + 6)%>">
	  <input type="hidden" name="is_lab_<%=iCount%>" value="<%=vRetResult.elementAt(i + 5)%>">
	  </td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" align="center" style="font-size:9px;"><a href="javascript:PageAction('','1');"><img src="../../../images/save.gif" border="0"></a> Click to Exclude Faculty from report.</td>
    </tr>
  </table>
<%}//end of else%>
<input type="hidden" name="max_disp" value="<%=iCount%>">
<%}//vRetResult is not null%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>