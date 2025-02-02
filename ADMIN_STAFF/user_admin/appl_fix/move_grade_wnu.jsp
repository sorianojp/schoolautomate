<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null || !strSchCode.startsWith("WNU") || request.getSession(false).getAttribute("userIndex") == null) {%>
		<p style="font-size:14px; font-weight:bold; color:#FF0000">
			Page Access Denied. Please login again/ Contact System admin.
		</p>
	
	<%return;}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.move_.value = "";
	document.form_.submit();
}
function MoveStud() {
	var iMaxDisp = document.form_.max_disp.value;
	var bolIsChecked = false;
	
	var obj;
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.form_.gs_'+i);
		if(obj.checked) {
			bolIsChecked = true;
			break;
		}
	}
	if(bolIsChecked) {
		document.form_.move_.value='1';
		document.form_.submit();
		return;
	}
	alert("Please select atleast one grade to move.");
	return;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Application Fox-Move Grade","move_grade_wnu.jsp");
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
														"move_grade_wnu.jsp");
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
Vector vRetResult = new Vector();
Vector vLeft      = new Vector();
Vector vRight     = new Vector();
AllProgramFix APF = new AllProgramFix();

if(WI.fillTextValue("move_").length() > 0) {
	if(APF.moveGradeOfAStudent(dbOP, request, 1) == null)
		strErrMsg = APF.getErrMsg();
	else	
		strErrMsg = "Grades moved successfully.";
}
//I have to now get left and right grades, 
vRetResult = APF.moveGradeOfAStudent(dbOP, request, 4);
if(vRetResult == null) {
	if(strErrMsg == null) 
		strErrMsg = APF.getErrMsg();
}
else {
	vLeft = (Vector)vRetResult.remove(0);
	vRight = (Vector)vRetResult.remove(0);
}

String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem"};
%>
<form name="form_" action="./move_grade_wnu.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
        MOVE GRADE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"MESSAGE : ","","")%></strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Student ID  &nbsp;&nbsp;&nbsp; 
        <input name="stud_id" type="text" size="20" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="48%" height="25">SY/Term From 
        <input name="sy_left" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_left")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> 
      - 
      <select name="sem_left">
        <option value="0">Summer</option>
<%
strTemp = WI.fillTextValue("sem_left");
if(strTemp.compareTo("1") ==0){%>
        <option value="1" selected>1st Sem</option>
        <%}else{%>
        <option value="1">1st Sem</option>
        <%}if(strTemp.compareTo("2") == 0){%>
        <option value="2" selected>2nd Sem</option>
        <%}else{%>
        <option value="2">2nd Sem</option>
        <%}if(strTemp.compareTo("3") == 0){%>
        <option value="3" selected>3rd Sem</option>
        <%}else{%>
        <option value="3">3rd Sem</option>
        <%}%>
      </select></td>
      <td width="50%" height="25" colspan="2">
	  SY/Term To:
	  <input name="sy_right" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_right")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"> - 
	  <select name="sem_right">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("sem_right");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td align="right"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null){
int iMaxDisp = 0;%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td width="50%" valign="top">
			<table width="100%" bgcolor="#FFCC00" border="0" cellspacing="1" cellpadding="1">
				<tr> 
					<td height="25" colspan="4" bgcolor="#BFBF80" align="center" style="font-weight:bold; font-size:9px;">
						Grade for SY/Term: <%=WI.fillTextValue("sy_left")%> - <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("sem_left"))]%>
					</td>
				</tr>
				
			  <tr bgcolor="#FFFFFF" align="center" style="font-weight:bold"> 
				<td width="26%" height="25"><font size="1">SUBJECT CODE </font></td>
				<td width="65%"><font size="1">SUBJECT NAME</font></td>
				<td width="9%"><font size="1">GRADE</font></td>
				<td width="9%"><font size="1">MOVE</font></td>
			  </tr>
			  <%while(vLeft.size() > 0){%>
				  <tr bgcolor="#FFFFFF" align="center" style="font-weight:bold"> 
					<td width="26%" height="25"><font size="1"><%=vLeft.elementAt(3)%></font></td>
					<td width="65%"><font size="1"><%=vLeft.elementAt(4)%></font></td>
					<td width="9%"><font size="1"><%=vLeft.elementAt(1)%></font></td>
					<td width="9%">
						<input type="checkbox" name="gs_<%=iMaxDisp++%>" value="<%=vLeft.elementAt(0)%>">
					</td>
				  </tr>
			  <%vLeft.remove(0);vLeft.remove(0);vLeft.remove(0);vLeft.remove(0);vLeft.remove(0);}%>
			  <input type="hidden" name="max_disp" value="<%=iMaxDisp%>">
        </table>
		</td>
		<td width="50%" valign="top">
			<table width="100%" bgcolor="#FFCC00" border="0" cellspacing="1" cellpadding="1">
				<tr> 
					<td height="25" colspan="3" bgcolor="#BFBF80" align="center" style="font-weight:bold; font-size:9px;">
						Grade for SY/Term: <%=WI.fillTextValue("sy_right")%> - <%=astrConvertTerm[Integer.parseInt(WI.fillTextValue("sem_right"))]%>
					</td>
				</tr>
				
			  <tr bgcolor="#FFFFFF" align="center" style="font-weight:bold"> 
				<td width="26%" height="25"><font size="1">SUBJECT CODE </font></td>
				<td width="65%"><font size="1">SUBJECT NAME</font></td>
				<td width="9%"><font size="1">GRADE</font></td>
			  </tr>
			  <%while(vRight.size() > 0){%>
				  <tr bgcolor="#FFFFFF" align="center" style="font-weight:bold"> 
					<td width="26%" height="25"><font size="1"><%=vRight.elementAt(3)%></font></td>
					<td width="65%"><font size="1"><%=vRight.elementAt(4)%></font></td>
					<td width="9%"><font size="1"><%=vRight.elementAt(1)%></font></td>
				  </tr>
			  <%vRight.remove(0);vRight.remove(0);vRight.remove(0);vRight.remove(0);vRight.remove(0);}%>
        </table>
		</td>
	</tr>
	<tr>
		<td height="25" align="center">
<%if(iMaxDisp > 0){%>	
		<input type="button" border="0" value="MOVE >>" onClick="MoveStud();">

<%}%>		</td>
		<td align="center">	</td>
	</tr>

  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26"><div align="center"></div></td>
      <td><div align="center"></div></td>
    </tr>
    <tr> 
      <td height="41" colspan="2"><div align="center"></div></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="move_">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
