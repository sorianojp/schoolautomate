<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
///for searching COA
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == '0') {
		if(!confirm("Are you sure you want to Delete."))
			return;
	}		
	document.form_.page_action.value = strAction;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ReportRegistrar,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Map Otr can grad","otr_can_grad_map.jsp");
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

ReportRegistrar RR = new ReportRegistrar();
Vector vRetResult = null;
if(WI.fillTextValue("course").length() > 0) {
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(RR.operateOnMapSubjectGroupForm19(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = RR.getErrMsg();
		else
			strErrMsg = "Operation successful.";
	}
	vRetResult = RR.operateOnMapSubjectGroupForm19(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = RR.getErrMsg();
}	
%>
<form action="./otr_can_grad_map.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          Subject Group Mapping ::::</strong></font></strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="26">&nbsp;</td>
      <td>Course</td>
      <td>
		<select name="course" onChange="document.form_.page_action.value='';document.form_.submit();" style="font-size:10px;font-weight:bold">
		<option value="">Select Course</option>
<%
strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_code asc";
%>
<%=dbOP.loadCombo("course_index","course_code+' ::: '+course_name",strTemp,WI.fillTextValue("course"), false)%> 
	    </select>	  
	  </td>
    </tr>
<%if(WI.fillTextValue("course").length() > 0) {
strTemp = WI.fillTextValue("course");
//I have to get the degree type.. 
strErrMsg = "select degree_type from course_offered where course_index = "+strTemp;
strErrMsg = dbOP.getResultOfAQuery(strErrMsg, 0);
if(strErrMsg == null)
	strErrMsg = "";
if(strErrMsg.equals("1")) {//graduate.
	strErrMsg = "cculum_masteral";
}
else if(strErrMsg.equals("2")){//medicine.
	strErrMsg = "cculum_medicine";
}
else {//UG
	strErrMsg = "curriculum";
}
	strTemp = " from "+strErrMsg+" join subject_group on (subject_group.group_index = "+strErrMsg+".group_index) where course_index = "+strTemp+
		" and is_valid = 1 and not exists "+
		"(select * from SUB_GROUP_MAP_FORM19 where subject_group.group_index = sg_index and course_index_ = "+strTemp+") order by group_name";
%>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td width="19%">Subject Group </td>
      <td width="79%"><select name="sg_index">
	  <%//=dbOP.loadCombo("subject_group.GROUP_INDEX","GROUP_NAME", " from SUBJECT_GROUP where not exists "+
	  	//		"(select * from SUB_GROUP_MAP_FORM19 where group_index = sg_index and course_index_ = "+WI.fillTextValue("course")+") and is_del=0 order by group_name",
	  	//		WI.fillTextValue("sg_index"),false)%>
		<%=dbOP.loadCombo("distinct subject_group.GROUP_INDEX","GROUP_NAME", strTemp,WI.fillTextValue("sg_index"),false)%>
      </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2">Copy from existing Group mapped (Group in display) :
        <select name="copy_fr" onChange="document.form_.sg_name.value=document.form_.copy_fr[document.form_.copy_fr.selectedIndex].text">
          <option value="">Select to copy</option>
          <%=dbOP.loadCombo("distinct sg_name","SG_NAME", " from SUB_GROUP_MAP_FORM19 order by SUB_GROUP_MAP_FORM19.sg_name",null,false)%>
        </select></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Group to Display </td>
      <td>
	  <input name="sg_name" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("sg_name")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Order Number </td>
      <td>
	  <select name="order_no">
<%
Vector vTemp = new Vector();
vTemp.addElement("1");vTemp.addElement("2");vTemp.addElement("3");vTemp.addElement("4");vTemp.addElement("5");vTemp.addElement("6");
vTemp.addElement("7");vTemp.addElement("8");vTemp.addElement("9");vTemp.addElement("10");vTemp.addElement("11");vTemp.addElement("12");
vTemp.addElement("13");
vTemp.addElement("14");
vTemp.addElement("15");
vTemp.addElement("16");
vTemp.addElement("17");
vTemp.addElement("18");
vTemp.addElement("19");
vTemp.addElement("20");
vTemp.addElement("21");
vTemp.addElement("22");

//strTemp = "select order_no from SUB_GROUP_MAP_FORM19 where course_index_ = "+WI.fillTextValue("course")+" order by order_no desc";
//java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
//while(rs.next())
//	vTemp.removeElementAt(rs.getInt(1) - 1);
for(int i = 0; i < vTemp.size(); ++i) {%>
		<option value="<%=vTemp.elementAt(i)%>"><%=vTemp.elementAt(i)%></option>
<%}%>
	  </select>	  </td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38">&nbsp;</td>
      <td height="38" valign="bottom">
<%if(iAccessLevel > 1) {%>
			<input type="submit" name="123" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
			 onClick="PageAction('1','');">
<%}%>      </td>
    </tr>
    <tr> 
      <td height="26" colspan="3"><div align="right"></div></td>
    </tr>
<%}//do not show if course is not selected.%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: Mapping Information::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder">Order Number </td>
      <td width="40%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Subject Group To Display in Report </span></td>
      <td width="40%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Subject Group</span></td>
      <td width="10%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">DELETE</td>
    </tr>
<%
for(int i = 0; i < vRetResult.size() ; i += 4){%>
    <tr> 
      <td height="37" class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%if(iAccessLevel ==2 ) {%>
        <input type="submit" name="122" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
      <%}%></td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult.. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>