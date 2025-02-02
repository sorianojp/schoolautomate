<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">
function UpdateStatus() {
	document.form_.page_action.value = '1';
}
</script>
<body bgcolor="#D2AE72" onLoad="document.form_.project.focus();">
<%@ page language="java" import="utility.*,Accounting.ProjectManagement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Project management(update_stat)","update_stat.jsp");
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
														"Accounting","Administration",request.getRemoteAddr(), 
														"update_stat.jsp");	
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
//end of authenticaion code.	
	ProjectManagement projMgmt = new ProjectManagement();	
	Vector vRetResult    = null;
	
	if(WI.fillTextValue("project").length() > 0) {
		vRetResult = projMgmt.operateOnCreateProject(dbOP, request, 5);
		if(vRetResult == null)
			strErrMsg = projMgmt.getErrMsg();
	}
	else	
		strErrMsg = "Please enter project code/name.";

	strTemp = WI.fillTextValue("page_action");
	if(vRetResult != null && strTemp.length() > 0) {
		if(!projMgmt.closeProject(dbOP, request,  (String)vRetResult.elementAt(0)) )
			strErrMsg = projMgmt.getErrMsg();
		else {
			strErrMsg = "Project status changed successfully.";
			vRetResult.setElementAt(WI.fillTextValue("close_date"), 4);//close date. 
			vRetResult.setElementAt(WI.fillTextValue("proj_stat"), 5);//project stat.
		}
	}
		
%>
<form method="post" action="./update_stat.jsp" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::UPDATE PROJECT STATUS - PROJECT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg)%>	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="4">Project Name/Code        
      <input name="project" type="text" size="64" maxlength="64" value="<%=WI.fillTextValue("project")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      &nbsp;&nbsp;
      <input type="submit" name="12022" value=" Refresh " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="document.form_.preparedToEdit.value='';PageAction('','');">      </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {
String[] astrConvertTerm = {"Summer", "1st Sem", "2nd Sem","3rd Sem"};
double dRunningExpense = Double.parseDouble((String)vRetResult.elementAt(11));
Vector vTemp = projMgmt.viewProjectExpense(dbOP, (String)vRetResult.elementAt(0),dRunningExpense, request);
String strProjectCostAsOfNow = null;
if(vTemp != null)
	strProjectCostAsOfNow = (String)vTemp.elementAt(0);
else	
	strProjectCostAsOfNow = projMgmt.getErrMsg();
	
%>    
    <tr>
      <td height="25" colspan="5"><hr size=1></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Project Code</td>
      <td colspan="3"><%=vRetResult.elementAt(1)%></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="14%">Project Name</td>
      <td colspan="3"><%=vRetResult.elementAt(2)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Date</td>
      <td width="40%"><%=vRetResult.elementAt(3)%><%=WI.getStrValue((String)vRetResult.elementAt(4), " - ",""," - till date")%></td>
      <td width="12%">SY/Term</td>
      <td width="32%"><%=vRetResult.elementAt(6)%>, <%=astrConvertTerm[Integer.parseInt((String)vRetResult.elementAt(7))]%></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Approved by</td>
      <td><%=vRetResult.elementAt(8)%></td>
      <td>Approved Budget </td>
      <td><%=CommonUtil.formatFloat((String)vRetResult.elementAt(9), true)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Account</td>
      <td colspan="3"><%=vRetResult.elementAt( 12)%> : <%=vRetResult.elementAt(13)%> </td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Accumulated Cost As of now: <b> <%=strProjectCostAsOfNow%> </b></td>
      <td height="25">Update Date </td>
      <td height="25">
<%
strTemp = (String)vRetResult.elementAt(4);
%>
<input name="close_date" type="text" size="12" maxlength="12" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <a href="javascript:show_calendar('form_.close_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>    
	</td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="2" style="font-size:9px;"><%if(vTemp != null){%><%=WI.getStrValue(projMgmt.getErrMsg(), "Note : ", "","&nbsp;")%><%}%></td>
      <td>Project Status</td>
      <td>
<%
strTemp = (String)vRetResult.elementAt(5);
%>	
	  <select name="proj_stat">
          <option value="1">On-going</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>Completed</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>Stopped</option>
        </select>      </td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="2"><input type="submit" name="1" value=" Update Project Stat " style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="UpdateStatus();"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" colspan="4">&nbsp;</td>
    </tr>
<%}//show only if vRetResult is not null%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>