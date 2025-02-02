<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
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
	function PageAction(strAction, strInfoIndex){
		if(strAction == '0'){
			if(!confirm("Do you want to delete this entry?"))
				return;
		}
		
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
			
		document.form_.page_action.value = strAction;
		
		if(strAction == '3'){
			document.form_.prepareToEdit.value = "1";
			document.form_.page_action.value = "";
		}
		
		document.form_.submit();
	
	}
	
	function Cancel(){
		document.form_.page_action.value = "";
		document.form_.info_index.value = "";
		document.form_.prepareToEdit.value = "0";
		document.form_.rank_name.value = "";
		document.form_.grade_greater_than.value = "";
		document.form_.is_gwa_greater.checked = false;
		document.form_.grade_less_than.value = "";
		document.form_.is_gwa_less.value = false;
		document.form_.submit();
	}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,student.GWAExtn,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-TOP STUDENTS","top_stud_rank_mgmt.jsp");
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
														"Registrar Management","TOP STUDENTS",request.getRemoteAddr(),
														"top_stud_rank_mgmt.jsp");
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

GWAExtn gwaExtn = new GWAExtn();

Vector vRetResult = null;

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if( gwaExtn.operateOnRankingForTopStudents(dbOP, request, Integer.parseInt(strTemp)) == null )
		strErrMsg = gwaExtn.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg ="Entry successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg ="Entry successfully saved.";
		if(strTemp.equals("2"))
			strErrMsg ="Entry successfully updated.";
			
		strPrepareToEdit = "0";		
	}
}
Vector vEditInfo = null;
if(strPrepareToEdit.equals("1")){
	vEditInfo = gwaExtn.operateOnRankingForTopStudents(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = gwaExtn.getErrMsg();
}
	
int iElemCount = 0;	

String strSYFrom = WI.fillTextValue("sy_from");
String strSem    = WI.fillTextValue("semester");
if(strSYFrom.length() > 0 && strSem.length() > 0){	
	vRetResult = gwaExtn.operateOnRankingForTopStudents(dbOP, request, 4);	
}


iElemCount = gwaExtn.getElemCount();


String[] astrGWAGrade = {"Grade", "GWA"};
%>

<form name="form_" action="./top_stud_rank_mgmt.jsp" method="post">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        TOP STUDENTS RANK MANGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="15%" height="25" >SY/Term </td>
      <td width="82%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<select name="semester" onChange="ReloadPage();">
        	<%
			strTemp = WI.fillTextValue("semester");
			if(strTemp.equals("1"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="1" <%=strErrMsg%>>First Semester</option> 
			
			<%
			if(strTemp.equals("2"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="2" <%=strErrMsg%>>Second Semester</option> 
			
			<%
			if(strTemp.equals("3"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="3" <%=strErrMsg%>>Third Semester</option> 
			
			<%
			if(strTemp.equals("0"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%><option value="0" <%=strErrMsg%>>Summer</option> 
      	</select>
		
		<a href="javascript:document.form_.submit();"><img src="../../../images/refresh.gif" border="0"></a>		</td>      
    </tr>
<%if(strSYFrom.length() > 0 && strSem.length() > 0){%>
    <tr>
        <td height="25" >&nbsp;</td>
        <td height="25" >Rank Name</td>
		<%
		strTemp = WI.fillTextValue("rank_name");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		%>
        <td >
			<input name="rank_name" type="text" size="40" maxlength="128" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
    </tr>
<!--    <tr>
        <td height="25" >&nbsp;</td>
        <td height="25" >GWA/Grade Greater Than</td>
		<%
		strTemp = WI.fillTextValue("grade_greater_than");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		%>
        <td >
			<input name="grade_greater_than" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','grade_greater_than');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyFloat("form_","grade_greater_than");'>
	  &nbsp; &nbsp;
	  <%
		strTemp = WI.fillTextValue("is_gwa_greater");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
	  <input type="checkbox" name="is_gwa_greater" value="0" <%=strErrMsg%>>Use Grade to compare with		</td>
    </tr>
    <tr>
        <td height="25" >&nbsp;</td>
        <td height="25" >GWA/Grade Less Than</td>
		<%
		strTemp = WI.fillTextValue("grade_less_than");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
		%>
        <td >
			<input name="grade_less_than" type="text" size="4" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','grade_less_than');style.backgroundColor='white'"
		  onKeyUp='AllowOnlyFloat("form_","grade_less_than");'>
		  &nbsp; &nbsp;
		<%
		strTemp = WI.fillTextValue("is_gwa_less");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		
		if(strTemp.equals("0"))
			strErrMsg = "checked";
		else
			strErrMsg = "";
		%>
		  <input type="checkbox" name="is_gwa_less" value="0" <%=strErrMsg%>>Use Grade to compare with		  </td>
    </tr>-->
    <tr>
        <td height="25" >&nbsp;</td>
		
        <td height="25" colspan="2" >
			A 
			<select name="is_gwa_greater">
				<%
				strTemp = WI.fillTextValue("is_gwa_greater");
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(3);
				for(int i =0; i < astrGWAGrade.length; i++){					
					if(strTemp.equals(i+""))
						strErrMsg = "selected";
					else
						strErrMsg = "";
				%>
				<option value="<%=i%>" <%=strErrMsg%>><%=astrGWAGrade[i]%></option>
				<%}%>
			</select>
			of
			<%
		strTemp = WI.fillTextValue("grade_greater_than");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(2);
		%>
			<input name="grade_greater_than" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','grade_greater_than');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyFloat("form_","grade_greater_than");'>
	  		% or better with no 
			<select name="is_gwa_less">
				<%
				strTemp = WI.fillTextValue("is_gwa_less");
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(5);
				
				for(int i =0; i < astrGWAGrade.length; i++){					
					if(strTemp.equals(i+""))
						strErrMsg = "selected";
					else
						strErrMsg = "";
				%>
				<option value="<%=i%>" <%=strErrMsg%>><%=astrGWAGrade[i]%></option>
				<%}%>
			</select> below 
			<%
		strTemp = WI.fillTextValue("grade_less_than");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
		%>
			<input name="grade_less_than" type="text" size="4" value="<%=strTemp%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','grade_less_than');style.backgroundColor='white'"
		  onKeyUp='AllowOnlyFloat("form_","grade_less_than");'>
		</td>
        </tr>
    <tr>
        <td height="25" >&nbsp;</td>
        <td height="25" >&nbsp;</td>
        <td >
			<%
			if(strPrepareToEdit.equals("0")){
			%>
			<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
			<font size="1">Click to save entry</font>
			<%}else{%>
			<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a>
			<font size="1">Click to update entry</font>
			<%}%>
			
			<a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
			<font size="1">Click to cancel operation</font>		</td>
    </tr>
<%}%>
  </table>
  
<%
if(vRetResult != null && vRetResult.size() > 0){
%>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td align="center" height="25"><strong>LIST OF RANKING FOR TOP STUDENT</strong></td>
	</tr>	
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td height="22" class="thinborder"><strong>RANK NAME</strong></td>
		<td width="16%" class="thinborder" align="center"><strong>GWA/Grade Greater Than</strong></td>
		<td width="9%" class="thinborder" align="center"><strong>Compare With</strong></td>
		<td width="16%" class="thinborder" align="center"><strong>GWA/Grade Less Than</strong></td>
		<td width="9%" class="thinborder" align="center"><strong>Compare With</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Option</strong></td>
	</tr>
	
	<%
	
	
	String strCurrGWA = null;
	String strPrevGWA = "";
	
	for(int i= 0; i < vRetResult.size(); i+=iElemCount){
		strCurrGWA = (String)vRetResult.elementAt(i+2);
		
	
		
		strTemp = "A "+astrGWAGrade[Integer.parseInt((String)vRetResult.elementAt(i+3))]+
			" of "+vRetResult.elementAt(i+2)+"% or better";
			
		if(WI.getStrValue(vRetResult.elementAt(i+4)).length() > 0)	
			strTemp += " with no "+astrGWAGrade[Integer.parseInt((String)vRetResult.elementAt(i+5))]+
				" below "+WI.getStrValue(vRetResult.elementAt(i+4));
		else
			strTemp += " but less than "+strPrevGWA+"%";
			
		if(!strPrevGWA.equals(strCurrGWA))
			strPrevGWA = strCurrGWA;
	%>
	<tr>
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i+1)%> (<%=strTemp%>)</td>
		<td class="thinborder" align="center"><%=vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" align="center"><%=astrGWAGrade[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+4));
		%>
		<td class="thinborder" align="center"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		<%
		if(strTemp.length() > 0)
			strTemp  = astrGWAGrade[Integer.parseInt((String)vRetResult.elementAt(i+5))];
		else
			strTemp = "&nbsp;";
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>
		<td class="thinborder" align="center">
			<a href="javascript:PageAction('3', '<%=vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
			<a href="javascript:PageAction('0', '<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	
	<%}%>
</table>
<%}%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="8" height="25">&nbsp;</td></tr>
	<tr><td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
