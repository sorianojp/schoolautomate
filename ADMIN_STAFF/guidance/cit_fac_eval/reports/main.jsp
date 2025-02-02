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
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
//viewRef 0 = view Detail, 1= view summary, 2 = view comments.. 
function viewInfo(strFacIndex, viewRef) {
	var strIsLAB = "0";
	if(document.form_.is_lab[1].checked)
		strIsLAB = "1";
	var strPgLoc = "sy_from="+document.form_.sy_from.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value+
					"&is_lab="+strIsLAB+"&fac_ref="+strFacIndex;
	
	if(viewRef == 0) 
		strPgLoc = "./view_detail.jsp?"+strPgLoc;
	if(viewRef == 1) 
		strPgLoc = "./view_summary.jsp?"+strPgLoc;
	if(viewRef == 2) 
		strPgLoc = "./view_comments.jsp?"+strPgLoc;

	if(document.form_.inc_all.checked)
		strPgLoc += "&inc_all=1";	
	
	var win=window.open(strPgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewQuestion(strIsLAB) {
	var strPgLoc = "./view_question.jsp?is_lab="+strIsLAB+"&sy_from="+document.form_.sy_from.value+
	"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(strPgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Guidance & Counseling-Faculty Evaluation-Reports-main","main.jsp");
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
														"main.jsp");
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
Vector vRetResult = null;
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = facEval.getFacListEvaluated(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = facEval.getErrMsg();
}
%>
<form action="./main.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: EVALUATED FACULTY LIST ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="8%">SY-Term</td>
      <td width="89%">
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
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="8%">Lec/Lab</td>
      <td width="27%">
<%
strTemp = WI.fillTextValue("is_lab");
if(strTemp.equals("0") || strTemp.length() == 0) 
	strErrMsg = "checked ";
else	
	strErrMsg = "onClick='document.form_.submit();'";
%>
	  <input type="radio" name="is_lab" value="0" <%=strErrMsg%>> Lec &nbsp;&nbsp;
<%
if(strTemp.equals("1")) 
	strErrMsg = "checked";
else	
	strErrMsg = "onClick='document.form_.submit();'";
%>
	  <input type="radio" name="is_lab" value="1" <%=strErrMsg%>> Lab	  </td>
      <td width="18%">&nbsp;</td>
      <td width="43%">&nbsp;</td>
      <td width="1%">&nbsp;</td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" style="font-size:9px; color:#0000FF; font-weight:bold">
	  <input type="checkbox" name="inc_all" value="checked" <%=WI.fillTextValue("inc_all")%>>
	  Include the evaluation done after scheduled Date </td>
      <td>
	  <a href="javascript:viewQuestion('0');">View/Print Lec Question</a>
	  </td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" align="center"><input type="submit" name="1" value="&nbsp;&nbsp;Show Faculties Evaluated&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;"></td>
      <td>
		<a href="javascript:viewQuestion('1');">View/Print Lab Question</a>
	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">Evaluated Faculty List </font></strong></div></td>
    </tr>
    <tr>
      <td width="42%" height="25">&nbsp;</td>
      <td width="58%" height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="3%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Faculty ID </td>
      <td width="17%" height="25" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Faculty ID </td>
      <td width="50%" align="center" style="font-size:9px; font-weight:bold;" class="thinborder">Faculty Name </td>
      <td width="10%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">View Detail </td>
      <td width="10%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">View Summary </td>
      <td width="10%" style="font-size:9px; font-weight:bold;" align="center" class="thinborder">View Comments </td>
    </tr>
<%//System.out.println(vRetResult);
for(int i=0; i<vRetResult.size(); i+=3){%>
    <tr> 
      <td height="25" class="thinborder"><%=i/3 + 1%>.</td>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td align="center" class="thinborder"><a href="javascript:viewInfo('<%=vRetResult.elementAt(i)%>',0);"><img src="../../../../images/view.gif" border="0"></a></td>
      <td align="center" class="thinborder"><a href="javascript:viewInfo('<%=(String)vRetResult.elementAt(i)%>',1);"><img src="../../../../images/view.gif" border="0"></a></td>
      <td align="center" class="thinborder"><a href="javascript:viewInfo('<%=(String)vRetResult.elementAt(i)%>',2);"><img src="../../../../images/view.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
  <%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>