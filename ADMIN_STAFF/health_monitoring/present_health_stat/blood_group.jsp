<%@ page language="java" import="utility.*,health.PresentHealthStatus,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript">
function PageAction(strPageAction)
{
	document.form_.page_action.value = strPageAction;
	document.form_.donot_reload.value = "1";
	document.form_.submit();
}
function CloseWindow()
{	
	if(document.form_.donot_reload.value == 1)
		return;
	window.opener.document.form_.submit();
	window.opener.focus();
}
</script>

<body bgcolor="#8C9AAA" onUnload="CloseWindow();" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Present Health Status","blood_group.jsp");
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
														"Health Monitoring","Present Health Status",request.getRemoteAddr(),
														"blood_group.jsp");
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
    String strSQLQuery = "insert into hm_blood_group (user_index, blood_group, rh, bg)" +
    		"select user_index, bg, rh_factor, blood_group from hr_info_personal where not exists " +
    		"(select * from hm_blood_group where hm_blood_group.user_index = hr_info_personal.user_index) " +
    		"and blood_group is not null";
    dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);

PresentHealthStatus presentHealthStat = new PresentHealthStatus();

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//called for adde,edit or delete.
	if(presentHealthStat.operateOnBloodGroup(dbOP, request,Integer.parseInt(strTemp)) == null) {
		strErrMsg = presentHealthStat.getErrMsg();
	}	
	else
		strErrMsg = "Operation is successful.";		
}

//get all levels created.
Vector vRetResult = null;
Vector vStudInfo = null;
vRetResult = presentHealthStat.operateOnBloodGroup(dbOP, request,3);
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0) {
	java.sql.ResultSet rs = dbOP.executeQuery("select user_index, fname, mname, lname from user_table where id_number = '"+
		WI.fillTextValue("stud_id")+"'");
	if(rs.next()) {
		vStudInfo = new Vector();
		vStudInfo.addElement(rs.getString(1));
		vStudInfo.addElement(WI.formatName(rs.getString(2), rs.getString(3), rs.getString(4), 4));
	}
	rs.close();
}


if(vStudInfo == null)
	strErrMsg = OAdm.getErrMsg();
//gets bg info.
if(vRetResult != null && vRetResult.size() > 0)
	bolNoRecord = false;

dbOP.cleanUP();
%>
<form action="./blood_group.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td height="25" colspan="3" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BLOOD GROUP ENTRY MGMT. PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
	</table>
<%
if(vStudInfo != null){%>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="1%" height="25">&nbsp;</td>
      <td width="30%" align="right">ID : &nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td width="69%"><strong><%=WI.fillTextValue("stud_id")%></strong>
	  <input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>"></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td align="right">NAME : &nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td><strong> <%=(String)vStudInfo.elementAt(1)%></strong></td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td align="right">BLOOD GROUP :&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
      <td> <select name="group">
          <option value="1">A</option>
          <%
if(bolNoRecord)
	strTemp = WI.fillTextValue("group");
else	
	strTemp = (String)vRetResult.elementAt(0);

if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>B</option>
          <%}else{%>
          <option value="2">B</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>AB</option>
          <%}else{%>
          <option value="3">AB</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>O</option>
          <%}else{%>
          <option value="4">O</option>
          <%}%>
        </select> <select name="rh">
          <option value="0">+ve</option>
          <%
if(bolNoRecord)
	strTemp = WI.fillTextValue("rh");
else	
	strTemp = (String)vRetResult.elementAt(1);

if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>-ve</option>
          <%}else{%>
          <option value="1">-ve</option>
          <%}%>
        </select> </td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td> <%
if(bolNoRecord)
{%> <a href='javascript:PageAction(1);'><img src="../../../images/add.gif" border="0"></a><font size="1" >click 
        to add </font> <%}else if(iAccessLevel > 1){%> <a href='javascript:PageAction(2);'><img src="../../../images/edit.gif" border="0"></a><font size="1" >click 
        to save changes</font> <%}%> </td>
    </tr>
    <tr > 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
 <%}//only if stud info is not null%>
 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="donot_reload">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>