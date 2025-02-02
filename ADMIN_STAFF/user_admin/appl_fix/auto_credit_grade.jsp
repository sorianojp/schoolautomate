<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function checkAll()
{
	var maxDisp = document.form_.max_count.value;
	//this is the time I will check all.
	for(var i =0; i< maxDisp; ++i) {
		if(document.form_.selAll.checked)
			eval('document.form_.user_i'+i+'.checked = true');
		else
			eval('document.form_.user_i'+i+'.checked = false');
	}

}
function ReloadPage()
{
	document.form_.submit();		
}
function UpdateCredit()
{
	document.form_.update_.value = "1";
	document.form_.show_result.value = "1";
	
	this.ReloadPage();
}
function ShowResult() {
	document.form_.update_.value = "";
	document.form_.show_result.value = "1";
	
	this.ReloadPage();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Program fix-Auto Credit Grade",
								"auto_credit_grade.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = 2;
	//iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
		//												"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
			//											 null);
}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
AllProgramFix progFix = new AllProgramFix();
if(WI.fillTextValue("update_").length() > 0) {
	if(progFix.autoCreditSubject(dbOP, request, 1) == null)
		strErrMsg = progFix.getErrMsg();
	else	
		strErrMsg = "Updated successfully.";
}
if(WI.fillTextValue("sub_fr").length() > 0 && WI.fillTextValue("sub_to").length() > 0 && WI.fillTextValue("show_result").length() > 0) {
	vRetResult = progFix.autoCreditSubject(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = progFix.getErrMsg();
}	

int iMaxDisp = 0; 

%>


<form name="form_" action="./auto_credit_grade.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          AUTO CREDIT SUBJECT ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="2%">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:11px; color:#0000FF; font-weight:bold">Note: Credit From is the subject taken by the student and passed. Credit To is the subject to be inserted as credited subject </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" style="font-size:11px;">Subject Credit From </td>
      <td width="86%">
<%
strTemp = "0";
if(WI.fillTextValue("show_invalid_subject").length() > 0) 
	strTemp = "1";
%>
	  <select name="sub_fr" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	font-size: 14px; width:600px;">
          <option value=""></option>
          <%=dbOP.loadCombo("sub_index","sub_code +'('+sub_name +')'"," from subject where is_del = "+strTemp+" order by sub_code",WI.fillTextValue("sub_fr"),false)%> </select>
		  
		  <input type="checkbox" name="show_invalid_subject" value="checked" <%=WI.fillTextValue("show_invalid_subject")%> onClick="document.form_.show_result.value='';document.form_.update_.value='';document.form_.submit();"> Show Invalid Subjects
	</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" style="font-size:11px;">Subject Credit TO </td>
      <td>
	  <select name="sub_to" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	font-size: 14px; width:600px;">
          <option value=""></option>
          <%=dbOP.loadCombo("sub_index","sub_code +'('+sub_name +')'"," from subject where is_del = 0 order by sub_code",WI.fillTextValue("sub_to"),false)%> </select>
	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ShowResult();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {
boolean bolShowBkActn = false;
if(WI.fillTextValue("show_bk_actn").compareTo("1") == 0) 
	bolShowBkActn = true;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" bgcolor="#3366FF" class="thinborder"><font color="#FFFFFF"><b> 
        ::: LIST OF STUDENT HAVING GRADE ::: COUNT : <%=vRetResult.size()/10%></b></font></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="5%" bgcolor="#FFFFAF" class="thinborder" style="font-size:9px;">COUNT</td> 
      <td width="10%" height="25" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="30%" bgcolor="#FFFFAF" class="thinborder" style="font-size:9px;">STUDENT NAME </td>
      <td width="10%" bgcolor="#FFFFAF" class="thinborder"><font size="1">SY-TERM</font></td>
	  <td width="10%" bgcolor="#FFFFAF" class="thinborder"><font size="1">GRADE</font></td>
      <td width="10%" bgcolor="#FFFFAF" class="thinborder"><div align="center"><font size="1"><strong>UPDATE<br>
          SELECT ALL 
          <input type="checkbox" name="selAll" value="0" onClick="checkAll();">
          </strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 10, ++iMaxDisp) {%>
    <tr>
      <td class="thinborder"><%=iMaxDisp + 1%>. </td> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 4)%> - <%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
      <td class="thinborder"><div align="center">
          <input type="checkbox" name="user_i<%=iMaxDisp%>" value="<%=(String)vRetResult.elementAt(i + 9)%>">
        </div></td>
    </tr>
<%}%>
    <tr> 
      <td height="45" colspan="6" align="center" class="thinborder" valign="bottom">
	  <a href="javascript:UpdateCredit();"><img src="../../../images/save.gif" border="0"></a>Click to credit subject.</td>
    </tr>
  </table>
<%}//only if vRetResult is not null
%>

<table width="100%" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="show_result">
<input type="hidden" name="update_">
<input type="hidden" name="max_count" value="<%=iMaxDisp%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
