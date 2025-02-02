<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>...</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strPageAction) {
	document.form_.page_action.value = strPageAction;
	document.form_.show_all.value = '';
	document.form_.submit();
}
function ReloadPage(strAction) {
	document.form_.page_action.value = "";
	if(strAction == '1') //show all
		document.form_.show_all.value ='1';
	if(strAction == '2') {
		var printPgURL = "./sub_equiv_advising_listing.jsp";
		var win=window.open(printPgURL,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
		return;
	}
	document.form_.submit();
}
function PrintPg()
{
	var strSubCodeFrom = "";
	var strSubCodeTo   = "";
	if(document.subm.subcode_from.selectedIndex >=0)
		strSubCodeFrom = document.subm.subcode_from[document.subm.subcode_from.selectedIndex].text;
	if(document.subm.subcode_to.selectedIndex >=0)
		strSubCodeTo = document.subm.subcode_to[document.subm.subcode_to.selectedIndex].text;

	var printPgURL = "./curriculum_subject_list_print.jsp?subcode_from="+strSubCodeFrom+"&subcode_to="+strSubCodeTo+"&print_pg=1";
	if(document.subm.inc_course_desc && document.subm.inc_course_desc.checked)
		printPgURL += "&inc_=1";

	var win=window.open(printPgURL,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();


}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subject Equivalent - Advising","sub_equiv_advising.jsp");
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
														"Registrar Management","CURRICULUM-Subject Equivalent - Advising",request.getRemoteAddr(),
														"sub_equiv_advising.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";	


CurriculumSM SM = new CurriculumSM();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(SM.operateOnSubjEquivAdvising(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = SM.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}	

if(WI.fillTextValue("sub_lhs").length() > 0) 
	vRetResult = SM.operateOnSubjEquivAdvising(dbOP, request, 4);
	
%>

<form name="form_" method="post" action="./sub_equiv_advising.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SUBJECTS MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%
if(strErrMsg != null) {%>
    <tr style="font-weight:bold">
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE" colspan="2" style="font-size:14px; color:#FF0000;"><%=strErrMsg%></td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE"><a href="javascript:ReloadPage(1);">Show All Subjects Already Created</a></td>
      <td class="thinborderNONE"><a href="javascript:ReloadPage(2);">Show All Subjects Created With Course/Curriculum/units</a></td>
    </tr>
    <tr style="font-weight:bold">  
      <td width="2%" height="25">&nbsp;</td>
      <td width="49%" class="thinborderNONE">Subject LHS(will share offering from RHS subject) </td>
      <td width="49%" class="thinborderNONE">Subject RHS (Equivalent subject) </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>
         <select name="sub_lhs" style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;width:400px;" onChange="ReloadPage(0)">
         	<%=dbOP.loadCombo("sub_index","sub_code,sub_name"," from subject where IS_DEL=0 order by sub_code asc", WI.fillTextValue("sub_lhs"), false)%> 
        </select>	  </td>
      <td>
         <select name="sub_rhs" style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;width:400px;">
         	<%=dbOP.loadCombo("sub_index","sub_code,sub_name"," from subject where IS_DEL=0 order by sub_code asc", WI.fillTextValue("sub_rhs"), false)%> 
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" align="center" style="font-size:9px;">
	  <%if(iAccessLevel > 1) {%>
	  	<a href="javascript:PageAction('1');"><img src="../../../images/save.gif" border="0"></a> Save Subject equivalent
	  <%}%>	  </td>
    </tr>
  </table>

  
<table width=100% border=0 bgcolor="#FFFFFF">

    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" bgcolor="#B9B292"><div align="center">LIST
          OF EXISTING SUBJECTS BY SUBJECT TYPE</div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() >0)
{%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC" align="center" style="font-weight:bold"> 
      <td width="15%" height="25" class="thinborder" style="font-size:9px;">Subject Code </td>
      <td width="25%" class="thinborder" style="font-size:9px;">Subject Name </td>
      <td width="5%" class="thinborder" style="font-size:9px;">Lec/Lab Units </td>
      <td width="15%" class="thinborder" style="font-size:9px;">Equivalent Subject Code </td>
      <td width="25%" class="thinborder" style="font-size:9px;">Equivalent Sub Name</td>
      <td width="5%" class="thinborder" style="font-size:9px;">Lec/Lab Units </td>
      <td width="10%" class="thinborder" style="font-size:9px;">Delete</td>
    </tr>
    <%
strTemp = null;
strErrMsg = null;
int iCount = 0;

String strColorRHS = null;
String strLHSVal   = null;
String strRHSVal   = null;

for(int i = 0 ; i< vRetResult.size(); i += 7, ++iCount) {
if(strTemp == null) {
	strTemp   = (String)vRetResult.elementAt(i + 1);
	strErrMsg = (String)vRetResult.elementAt(i + 2);
	strLHSVal = strTemp;
	strRHSVal = strErrMsg;
	strColorRHS = "#FFFF99";
}
//else {
//	strTemp   = "&nbsp;";
//	strErrMsg = "&nbsp;";
//}
//or different subject... 
else if(!strLHSVal.equals(vRetResult.elementAt(i + 1)) || !strRHSVal.equals(vRetResult.elementAt(i + 2)) ) {
	strTemp   = (String)vRetResult.elementAt(i + 1);
	strErrMsg = (String)vRetResult.elementAt(i + 2);

	strLHSVal = strTemp;
	strRHSVal = strErrMsg;

	if(strColorRHS.equals("#FFFF99"))
		strColorRHS = "#cccccc";
	else
		strColorRHS = "#FFFF99";	
}
else {
	strTemp   = "&nbsp;";
	strErrMsg = "&nbsp;";
}
%>
    <tr> 
      <td class="thinborder" height="22"><%=strTemp%></td>
      <td class="thinborder"><%=strErrMsg%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td class="thinborder" bgcolor="<%=strColorRHS%>"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" bgcolor="<%=strColorRHS%>"><%=vRetResult.elementAt(i + 4)%></td>
      <td class="thinborder" bgcolor="<%=strColorRHS%>"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td class="thinborder" bgcolor="<%=strColorRHS%>" align="center"><input type="checkbox" name="sub_i<%=iCount%>" value="<%=vRetResult.elementAt(i)%>"></td>
    </tr>
<%
}//end of loop %>
<input type="hidden" name="max_disp" value="<%=iCount%>">
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" align="center" style="font-size:9px;">
	  <%if(iAccessLevel == 2) {%>
	  	<a href="javascript:PageAction('0');"><img src="../../../images/delete.gif" border="0"></a> Delete selected subject equivalent
	  <%}%>
	  </td>

	  </td>
    </tr>
  </table>

<%}//end of displaying %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="show_all">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>