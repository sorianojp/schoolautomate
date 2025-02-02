<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {     
	 font-weight:normal;
}
.nav-highlight {    
     background-color:#BCDEDB;
}

</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
	function navRollOver(obj, state) {
  		document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	
	function PageAction(strAction, strInfoIndex){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
		}
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;	
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex){
		document.form_.prepareToEdit.value = '1';
		document.form_.page_action.value = "";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "0";
		document.form_.info_index.value = "";
		document.form_.minimum.value = "";
		document.form_.maximum.value = "";
		document.form_.c_index.selectedIndex = "";
		document.form_.submit();
	}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strIsExpectedEnroll = WI.fillTextValue("is_basic_expected_enrol");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORTS","encode_max_min_enrol_projection.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"encode_max_min_enrol_projection.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
Vector vEditInfo = null;

enrollment.ReportEnrollmentAUF reportEnrl = new enrollment.ReportEnrollmentAUF();
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(reportEnrl.operateOnEnrollmentProjection(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = reportEnrl.getErrMsg();
	else{
		if(strTemp.equals("1"))
			strErrMsg = "Section Successfully saved.";
		if(strTemp.equals("0"))
			strErrMsg = "Section Successfully deleted.";
		if(strTemp.equals("2"))
			strErrMsg = "Section Successfully updated.";
			
		strPrepareToEdit = "0";
	}
}

int iElemCount = 0;
vRetResult = reportEnrl.operateOnEnrollmentProjection(dbOP, request, 4);
if(vRetResult != null && vRetResult.size() > 0)
	iElemCount = reportEnrl.getElemCount();
	
if(strPrepareToEdit.equals("1")){
	vEditInfo = reportEnrl.operateOnEnrollmentProjection(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = reportEnrl.getErrMsg();
}

%>


<form name="form_" method="post" action="encode_max_min_enrol_projection.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr bgcolor="#A49A6A">
	<td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
		MINIMUM/MAXIMUM ENROLLMENT PROJECTION PAGE ::::</strong></font></div></td>
</tr>   
<tr><td height="25">&nbsp; &nbsp; &nbsp; &nbsp; <font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>    
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("bypass_check");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
	    <td height="25" colspan="3">
		<input type="checkbox" name="bypass_check" value="1" <%=strErrMsg%>>Click to bypass error checking
		</td>
	    </tr>
	<tr>
<%if(!strIsExpectedEnroll.equals("1")){%>	
	
	    <td height="25">&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("is_basic");
		if(strTemp.equals("1"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
	    <td height="25" colspan="3">
		<input type="checkbox" name="is_basic" value="1" <%=strErrMsg%> onClick="document.form_.submit();">Encode basic education		</td>
	    </tr>
<%}else{%>
	<input type="hidden" name="is_basic" value="<%=WI.fillTextValue("is_basic")%>">
<%}%>
	<tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td height="25" width="18%">SY/Term</td>
      <td colspan="2"> 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
<%
	strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>        
	&nbsp;
	<select name="semester">
<%
	strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));
	
	if(WI.fillTextValue("is_basic").equals("1") && !strTemp.equals("1") && !strTemp.equals("0"))
		strTemp = "1";
	
%>	<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
        </select> 
		&nbsp; &nbsp;
		<a href="javascript:document.form_.submit();"><img src="../../../../../images/form_proceed.gif" border="0" align="absmiddle"></a>	</td>      
    </tr>
	<%if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0){
	
if(WI.fillTextValue("is_basic").length() == 0)	{
	%>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="18%">College</td>
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");	
		if(vEditInfo != null && vEditInfo.size() > 0)
				strCollegeIndex = (String)vEditInfo.elementAt(1);	
		%>
		<td colspan="2">
			<select name="c_index" style="width:400px;">
				<option value=""></option>
				<%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0 order by c_name", strCollegeIndex,false)%>
			</select>		</td>
	</tr>
	
<%}else{
	if(!strIsExpectedEnroll.equals("1")){
%>
		<tr>
	    <td height="25">&nbsp;</td>
	    <td>Education Level</td>
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");	
		if(vEditInfo != null && vEditInfo.size() > 0)
				strCollegeIndex = (String)vEditInfo.elementAt(1);	
		%>
	    <td colspan="2">
			<select name="c_index" style="width:200px;">
				<option value=""></option>
				<%=dbOP.loadCombo("distinct edu_level","  edu_level_name"," from bed_level_info order by edu_level",strCollegeIndex,false)%>
			</select>		</td>
	    </tr>
	<%}else{%>

		<tr>
	    <td height="25">&nbsp;</td>
	    <td>Grade Level</td>
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");	
		if(vEditInfo != null && vEditInfo.size() > 0)
				strCollegeIndex = (String)vEditInfo.elementAt(1);	
		%>
	    <td colspan="2">
			<select name="c_index" style="width:200px;">
				<option value=""></option>
				<%=dbOP.loadCombo("g_level","  level_name"," from bed_level_info order by g_level_order",strCollegeIndex,false)%>
			</select>		</td>
	    </tr>	
	
	<%}
}%>
		
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="18%">Minimum</td>		
		<%
			strTemp = WI.fillTextValue("minimum");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
		%>
		<td width="79%">
			<input type="text" name="minimum" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','minimum');style.backgroundColor='white'" 
			 onKeyUp="AllowOnlyInteger('form_','minimum')"	size="10" >		</td>
	</tr>
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="18%">Maximum</td>		
		<%
			strTemp = WI.fillTextValue("maximum");
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);
		%>
		<td width="79%">
			<input type="text" name="maximum" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','minimum');style.backgroundColor='white'" 
			onKeyUp="AllowOnlyInteger('form_','minimum')" size="10" >		</td>
	</tr>
	
	
	<tr><td height="10" colspan="4"></td></tr>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td colspan="2">
		<%
			if(strPrepareToEdit.equals("0")){%>
			<a href="javascript:PageAction('1','');"><img src="../../../../../images/save.gif" border="0"></a>
			<font size="1">Click to save information</font>
			<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../../../images/edit.gif" border="0"></a>
			<font size="1">Click to edit information</font>
			<%}%>
			<a href="javascript:ReloadPage();"><img src="../../../../../images/refresh.gif" border="0"></a>
			<font size="1">Click to reload page</font>		</td>		
	</tr>
	<%}%>
</table>  
  
 
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	
	<tr>
	<%
	strTemp = "COLLEGE";
	if(WI.fillTextValue("is_basic").length() > 0)
		strTemp = "EDUCATION LEVEL";
	%>
		<td class="thinborder" height="23" align="center"><strong><%=strTemp%></strong></td>
		<td width="20%" align="center" class="thinborder"><strong>MINIMUM</strong></td>
		<td class="thinborder" width="20%" align="center"><strong>MAXIMUM</strong></td>
		<td class="thinborder" width="15%" align="center"><strong>OPTION</strong></td>
	</tr>
	

	<%
	String strCurrCollege = null;
	String strPrevCollege = "";
	
	for(int i = 0; i < vRetResult.size(); i+=iElemCount){
		strCurrCollege = (String)vRetResult.elementAt(i+2);
	%>
	
	
	
	<tr class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
		<td class="thinborder">&nbsp;<%=strCurrCollege%></td>
		<td class="thinborder" align="right" style="padding-right:10px;">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
		<td class="thinborder" align="right" style="padding-right:10px;">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+4))%></td>
		<td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')">
				<img src="../../../../../images/edit.gif" border="0" height="25" width="40" align="absmiddle"></a>
			&nbsp;
			<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
				<img src="../../../../../images/delete.gif" border="0" height="25" width="40" align="absmiddle"></a>
		</td>
	</tr>
	<%}%>
</table>
  
  
<%}%>
  


<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td height="25" colspan="8">&nbsp;</td></tr>
<tr bgcolor="#B8CDD1"><td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<!-- all hidden fields go here -->
	<input type="hidden" name="page_action" >
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
	<input type="hidden" name="is_basic_expected_enrol" value="<%=strIsExpectedEnroll%>">
</form>
</body>
</html>
<%dbOP.cleanUP();%>
