<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script src="../../../../Ajax/ajax.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '3') {
		document.form_.page_action.value = '';
		document.form_.preparedToEdit.value = '1';
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
		return;
	}
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete project information.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value  = strInfoIndex;
	
	if(strAction == '0')
		document.form_.submit();
}

///for searching COA
var objCOA;
function MapCOAAjax(strIsBlur) {
	objCOA=document.getElementById("coa_info");

	var objCOAInput = document.form_.coa_code;
	if(objCOAInput.value.length < 3)
		return;
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name=coa_code&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "<font size=1 color='blue'>"+strAccountName+"</font>";
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.ProjectManagement,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Project management(create)","create.jsp");
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
														"create.jsp");	
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
	Vector vEditInfo     = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(projMgmt.operateOnCreateProject(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = projMgmt.getErrMsg();
		else {
			strPreparedToEdit = "0";
			strErrMsg = "Operation successful.";
		}
	}
	vRetResult = projMgmt.operateOnCreateProject(dbOP, request, 4);
	if(strPreparedToEdit.equals("1"))
		vEditInfo = projMgmt.operateOnCreateProject(dbOP, request, 3);
%>
<form method="post" action="./create.jsp" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: Manage Project Information ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="5" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg)%>	  </td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp;</td>
      <td>Project Code </td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("proj_code");
%>	
	  <input type="text" name="proj_code" maxlength="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr valign="bottom">
      <td width="2%" height="25">&nbsp;</td>
      <td width="17%">Project Name</td>
      <td width="29%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("proj_name");
%>	
	  <input type="text" name="proj_name" maxlength="64"  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="15%">Project Status: </td>
      <td width="37%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("proj_stat");
%>	
	  <select name="proj_stat">
          <option value="1">On-going</option><!--
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
          <option value="3"<%=strErrMsg%>>Stopped</option>-->
        </select>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Start Date</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("start_date");
if(strTemp.length() == 0) 
	strTemp = WI.getTodaysDate(1);
%>	
	  <input name="start_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
	  </td>
      <td>Running Cost : </td>
      <td style="font-size:9px;">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(11);
else
	strTemp = WI.fillTextValue("running_cost");
%>	
	  <input name="running_cost" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','running_cost');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','running_cost');">
        (Total expense as of creation)</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>SY/ Term<%}else{%>Year<%}%> </td>
      <td valign="bottom"> 
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("sy_from");
%>	
	  <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
<%if(bolIsSchool){%>
        -
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else
	strTemp = WI.fillTextValue("sy_from");
%>	
        <select name="term">
            <option value="1">1st Sem</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
            <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
            <option value="3"<%=strErrMsg%>>3rd Sem</option>
<%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
            <option value="0"<%=strErrMsg%>>Summer</option>
          </select>      
<%}else{//if companies, i have to set this to 1.%>
<input type="hidden" name="term" value="1">
<%}%>
		  </td>
      <td colspan="2" valign="bottom"><font color="#0000FF">NOTE: Running Cost is encoded only for existing project before implementation of SchoolBliz </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Approved by : </td>
      <td colspan="3" valign="bottom">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = WI.fillTextValue("approved_by");
%>	
	  <input name="approved_by" type="text" size="64" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Approved Budget : </td>
      <td colspan="3" valign="bottom" style="font-size:9px;">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(9);
else
	strTemp = WI.fillTextValue("budget");
%>	
	  <input name="budget" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','budget');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','budget');">
        (If indicated in the project approval) </td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size=1 color="#0000FF"></td>
    </tr>
    <tr valign="top">
      <td height="31">&nbsp;</td>
      <td height="31">CHARGE PROJECT TO  : <strong></strong></td>
      <td height="31" colspan="3">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(12);
else
	strTemp = WI.fillTextValue("coa_code");
%>	
	  <input name="coa_code" type="text" size="32" maxlength="64" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="MapCOAAjax('0');">
          <label id="coa_info"></label>      </td>
    </tr>
    <tr bgcolor="#DDDDDD"> 
      <td height="22">&nbsp;</td>
      <td style="font-weight:bold; font-size:11px;">Search Condition:</td>
      <td colspan="3" style="font-size:11px;">
	  <input type="checkbox" value="checked" <%=WI.fillTextValue("consider_sy")%> name="consider_sy"> Show Project for the <%if(bolIsSchool){%>SY/ Term<%}else{%>Year<%}%> Only <br>&nbsp;
	  Show Project Status :: 
<%
if(request.getParameter("info_index") == null)
	strTemp = "1";
else
	strTemp = WI.fillTextValue("show_status");
if(strTemp.length() == 0) 
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" value="" name="show_status" <%=strErrMsg%> onClick="document.form_.consider_sy.checked = true">  ALL
<%
if(strTemp.equals("1")) 
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" value="1" name="show_status" <%=strErrMsg%>> On going
<%
if(strTemp.equals("2")) 
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" value="2" name="show_status" <%=strErrMsg%>> Completed
<%
if(strTemp.equals("3")) 
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" value="3" name="show_status" <%=strErrMsg%>> Stopped
	  
	  &nbsp;&nbsp;
	  <input type="submit" name="12022" value=" Refresh " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="document.form_.preparedToEdit.value='';PageAction('','');"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" align="center">
<%if(!strPreparedToEdit.equals("1")){%>
	  	<input type="submit" name="1" value=" Create Project Info " style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.preparedToEdit.value='';PageAction('1','');">
<%}else{%>
	  	<input type="submit" name="12" value=" Edit Project Info " style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="PageAction('2','<%=vEditInfo.elementAt(0)%>');">
	  	&nbsp;&nbsp;
		<input type="submit" name="122" value=" Cancel " style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';">
<%}%>	  </td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" colspan="4">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><font color="#000033"><b>LIST OF PROJECTS IN RECORD </b></font></div></td>
    </tr>
    <tr>
      <td width="75%" height="25"><font size="1"><strong>TOTAL PROJECTS IN RECORD : <%=vRetResult.size()/14%> </strong></font></td>
      <td width="25%" style="font-size:9px;">Color :: Green = Completed, Grey = Closed </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="6%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Code</td>
      <td width="23%" height="25" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Name</td>
      <td width="12%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project  Date</td>
      <td width="8%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Running Expense</td>
      <td width="12%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Approved By</td>
      <td width="7%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Approved Budget</td>
      <td width="7%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Charged To</td>
      <td width="15%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Account Name</td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Options</td>
    </tr>
<%
String strBGColor = ""; int iProjStat = 0;
for(int i = 0; i < vRetResult.size(); i += 14){
	iProjStat = Integer.parseInt((String)vRetResult.elementAt(i + 5));
	if(iProjStat == 2)
		strBGColor = " bgcolor='#BFFFBF'";
	else if(iProjStat == 3)
		strBGColor = " bgcolor='#CCCCCC'";
%>
    <tr<%=strBGColor%>>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td  height="25" class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), " - ",""," - till date")%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 11), true)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 9), true)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 13)%></td>
      <td class="thinborder"><%if(iProjStat > 1){%>&nbsp;<%}else{%>
	  <%if(iAccessLevel > 1){%>
	  	<a href="javascript:PageAction('3','<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border="0" ></a>
	  <%}if(iAccessLevel == 2){%>
		<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border="0"></a>
	  <%}
	  }//show only if it is ongoing.. %>
	  </td>
    </tr>
<%}%>
  </table>
<%}//only if vRetResult is not null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="4%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>