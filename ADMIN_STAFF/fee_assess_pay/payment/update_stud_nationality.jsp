<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>UPDATE NATIONALITY</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function UpdateNationality(table,indexname,colname,labelname){ 
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
		"&opner_form_name=update_nationality";
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
}
function CloseWindow()
{
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"fa_payment")%>.submit()
	window.opener.focus();
	self.close();
}
function PageAction(strAction) {
	document.update_nationality.page_action.value = strAction;
	document.update_nationality.submit();
}
</script>

<body bgcolor="#D2AE72">
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT-assessedfees(enrollment)","update_stud_nationality.jsp");
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
														"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(),
														"update_stud_nationality.jsp");
if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
	strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
	int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}
}

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
String strStudID     = WI.fillTextValue("stud_id");
String strStudIndex  = WI.fillTextValue("stud_index");
String strIsTempStud = WI.fillTextValue("is_temp_stud");
boolean bolIsTempStud = false;
if(strIsTempStud.compareTo("1") == 0)
	bolIsTempStud = true;
enrollment.CourseRequirement CR = new enrollment.CourseRequirement();

strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("2") ==0)//edit or add. 
{
	//first delete and add a new entry. 
	enrollment.StudentInformation SI = new enrollment.StudentInformation();
	if(SI.changeForeignStat(dbOP, strStudIndex,bolIsTempStud,false,null))
	{
		if(SI.changeForeignStat(dbOP, strStudIndex,bolIsTempStud,true,WI.fillTextValue("nationality"), request))
			strErrMsg = "Naitionality changed successfully.";
		else	
			strErrMsg = SI.getErrMsg();
	}
	else	
		strErrMsg = SI.getErrMsg();
}
if(strTemp.compareTo("0") ==0) //delete
{
	enrollment.StudentInformation SI = new enrollment.StudentInformation();
	if(SI.changeForeignStat(dbOP, strStudIndex,bolIsTempStud,false,null))
		strErrMsg = "Alien status changed successfully.";
	else	
		strErrMsg = SI.getErrMsg();
}

%>


<form name="update_nationality" method="post" action="./update_stud_nationality.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          UPDATE STUDENT NATIONALITY ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="1%" height="25">&nbsp;</td>
      <td height="25" colspan="2"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a> 
        <font size="1"><strong>Click to close window</strong></font></td>
    </tr>
    <tr> 
      <td colspan="5" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">STUDENT ID : <strong><%=WI.fillTextValue("stud_id")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="35%" height="25">FOREIGN STUDENT : <font color="#9900FF"><strong> 
        <%
boolean bolIsAlienNationality = CR.isForeignNational(dbOP,strStudIndex,bolIsTempStud);
if(bolIsAlienNationality)
	strTemp = "1";
else	
	strTemp = "0";

	  if(bolIsAlienNationality){%>
        YES <%=WI.getStrValue(CR.getStudNationality(),"(",")","")%> 
        <%}else{%>
        NO 
        <%}%>
        </strong></font></td>
      <td height="25">
<%
if(bolIsAlienNationality) {%>
	  <a href='javascript:PageAction(0);'><img src="../../../images/delete.gif" border="0"></a> 
        <font size="1">Click if student is not foreign national</font>
<%}//show only if student is foreign national%>
		</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td>&nbsp; </td>
    </tr>
  </table>
  <table width="100%" border=0 cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="3"><div align="center"><font color="#FFFFFF"><strong>EDIT 
          NATIONALITY OF ALIEN STUDENT</strong></font></div></td>
    </tr>
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="15%">NEW STATUS</td>
      <td width="78%"> <select name="nationality">
          <%=dbOP.loadCombo("ALIEN_NATIONALITY_INDEX","NATIONALITY"," from NA_ALIEN_NATIONALITY order by NATIONALITY asc", null, false)%> 
        </select>
        <a href='javascript:UpdateNationality("NA_ALIEN_NATIONALITY","ALIEN_NATIONALITY_INDEX","NATIONALITY","NATIONALITY");'> 
        <img src="../../../images/update.gif" border="0"></a><font size="1">click 
        to update list of Nationality</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href='javascript:PageAction(2);'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">Click to EDIT nationality of student</font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"></tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<!-- all hidden fields go here -->
<input type="hidden" name="page_action">
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="stud_index" value="<%=WI.fillTextValue("stud_index")%>">
<input type="hidden" name="is_temp_stud" value="<%=WI.fillTextValue("is_temp_stud")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>