<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">

<script language="JavaScript" src="../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.page_action.value = "";
	
	document.form_.submit();
}
function PostCharge(strORNumber, strPosition) {
	
	document.form_.or_number.value = strORNumber;
	document.form_.no_of_unit.value = eval('document.form_.no_of_unit'+strPosition+'.value');
	if(document.form_.no_of_unit.value.length == 0) {
		alert("Please enter no of units.");
		return;
	}
	document.form_.page_action.value = "1";
	document.form_.submit();
	
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.

	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"FIXES-other_sch_fee.jsp","other_sch_fee.jsp");
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
if(!comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId")))//NOT AUTHORIZED if not super user.
{
	dbOP.cleanUP();
	response.sendRedirect("../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
AllProgramFix programFix = new AllProgramFix();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(programFix.operateOnVerifyPostCharge(dbOP, request, 1) == null)
		strErrMsg = programFix.getErrMsg();
	else	
		strErrMsg = "Posting is successful.";
}
vRetResult = programFix.operateOnVerifyPostCharge(dbOP, request, 4);
if(vRetResult == null)
	strErrMsg = programFix.getErrMsg();

%>
<form action="./other_sch_fee.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          OTHER SCHOOL FEE FIX PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes"> </td>
      <td width="5%">Term</td>
      <td width="22%" height="25"><select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
      <td width="38%"><a href="javascript:ReloadPage();">
	  <img src="../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="5">Enter Stud ID (to display all leave it blank) 
        <font size="1"> 
        <input name="stud_id" type="text" size="24" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </font> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" colspan="5">NOTE : This page displays students with other 
        school fee payment without other school fee being POSTED</td>
    </tr>
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
   
  <table width="100%" border="0" cellpadding="1" cellspacing="1" bgcolor="#000000">
    <tr> 
      <td height="25" colspan="9" bgcolor="#DDDDDD" align="center"><B> LIST OF 
        STUDENT WITHOUT OTHER SCHOOL FEE POSTED (TOTAL : <%=vRetResult.size()/10%>)</B></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="13%"><font size="1"><strong>STUD ID</strong></font></td>
      <td width="13%"><font size="1"><strong>OR NUMBER</strong></font></td>
      <td width="30%"><font size="1"><strong>OTH SCH FEE NAME</strong></font></td>
      <td width="7%"><font size="1"><strong>AMOUNT PAID</strong></font></td>
      <td width="10%"><font size="1"><strong>DATE PAID</strong></font></td>
      <td width="10%"><font size="1"><strong>AMT OF OTH SCH FEE</strong></font></td>
      <td width="7%"><font size="1"><strong>NO OF UNIT</strong></font></td>
      <td width="8%"><font size="1"><strong>POST CHARGE</strong></font></td>
    </tr>
<%
for(int i = 0,j = 0 ; i < vRetResult.size() ; i += 10,++j){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 9)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td><%=(String)vRetResult.elementAt(i + 8)%></td>
      <td><input name="no_of_unit<%=j%>" type="text" size="2" maxlength="2" 
	  value="<%=WI.fillTextValue("no_of_unit"+j)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td><a href='javascript:PostCharge("<%=(String)vRetResult.elementAt(i + 2)%>","<%=j%>");'>
	  POST</a></td>
    </tr>
<%}%>
  </table>
 <%}//vRetResult not null
 %>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="reloadPage">
<input type="hidden" name="or_number">
<input type="hidden" name="no_of_unit">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>