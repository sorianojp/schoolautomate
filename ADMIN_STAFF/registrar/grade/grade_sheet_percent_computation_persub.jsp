<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css"></head>
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this record.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","xxxx",request.getRemoteAddr(),null);

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
Vector vRetResult = null;

GradeSystemExtn gsExtn = new GradeSystemExtn();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(gsExtn.operateOnPercentComputation(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = gsExtn.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
vRetResult = gsExtn.operateOnPercentComputation(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = gsExtn.getErrMsg();
%>
<form name="form_" action="./grade_sheet_percent_computation_persub.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          GRADE COMPUTATOIN PERCENTAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5" style="font-size:14px;">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="5%">Term: </td>
      <td height="25" width="92%">
	  <select name="term">
	  	<option value="">1st and 2nd sem</option>
<%
strTemp = WI.fillTextValue("term");
if(strTemp.equals("0"))
	strTemp = " selected";
else	
	strTemp = "";
%>
		<option value="0"<%=strTemp%>>Summer</option>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Subject</td>
      <td height="25">
	    <select name="sub_index" style="width:500px; font-size:11px;">
			<option value=""></option>
			<%=dbOP.loadCombo("sub_index","sub_code, sub_name"," from subject where is_del = 0 order by sub_code", request.getParameter("sub_index"), false)%>
        </select>

	  </td>
    </tr>
    <tr> 
      <td height="26" valign="middle">&nbsp;</td>
      <td height="26">Prelim</td>
      <td height="26">
	  <input name="prelim" type="text" size="3" maxlength="2" value="<%=WI.fillTextValue("prelim")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25">Midterm</td>
      <td ><input name="mterm" type="text" size="3" maxlength="2" value="<%=WI.fillTextValue("mterm")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>

    <tr>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25">Finals</td>
      <td ><input name="finals" type="text" size="3" maxlength="2" value="<%=WI.fillTextValue("finals")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25" valign="middle">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td ><input type="button" name="1" value="<<< Save Information >>>" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="PageAction('1','');"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() >0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6"><div align="center">GRADE COMPUTATION PERCENTAGE</div></td>
    </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="10%" height="22" class="thinborder">SUB CODE</td>
      <td width="50%" class="thinborder">Subject Name</td>
      <td width="5%" class="thinborder">Prelim</td>
      <td width="5%" class="thinborder">Midterm</td>
      <td width="5%" class="thinborder">Finals</td>
      <td width="15%" class="thinborder">Term Applicable</td>
      <td width="10%" class="thinborder">Delete</td>
    </tr>
<%
String[] astrConvertTerm = {"SUMMER","1st and 2nd Sem"};
for(int i = 0 ; i< vRetResult.size(); i += 7){%>
    <tr>
      <td height="22" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"><%=astrConvertTerm[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i + 3), "1"))]%></td>
      <td class="thinborder">
	  	<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
	  </td>
    </tr>
<%}//end of loop %>
  </table>

<%}//end of displaying %>

 </table>
  <table width="100%"  cellpadding="0" cellspacing="0">
    <tr>
      <td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
    </tr>
    <tr>
      <td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td>&nbsp;</td>
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
