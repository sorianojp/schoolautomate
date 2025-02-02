<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoEducation" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.

	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value=index;
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value=index;
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function ReloadPage(){
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function CancelEdit(){
	document.staff_profile.page_action.value="";
	document.staff_profile.prepareToEdit.value="";
	document.staff_profile.edu_name.value="";
	document.staff_profile.edu_code.value="";
	document.staff_profile.order_no.value="";
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function CloseWindow(){
	document.staff_profile.close_wnd_called.value = "1";
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.staff_profile.donot_call_close_wnd.value.length >0)
		return;

	if(document.staff_profile.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
		window.opener.focus();
	}
}
</script>

<body bgcolor="#663300" onUnload="ReloadParentWnd();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management -Education Levels",
								"hr_educ_levels.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(), 
														"hr_educ_levels.jsp");	
if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}

}
	//System.out.println(iAccessLevel);
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
	boolean noError = false;
	int iAction = 0;

	String[] astrEduGroup = {"&nbsp;", "BS", "MA/MS/MD/L.l.B.", "Ph.D. / DD"};	
	Vector vRetEdit = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	HRInfoEducation  hrList = new HRInfoEducation();
	iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));

	switch(iAction){
	case 0 : 
		if (hrList.operateOnEducationLevel(dbOP,request,0) == null) strErrMsg = hrList.getErrMsg();
		else{strErrMsg = "Education Level removed successfully.";  noError = true; strPrepareToEdit = "";}
		break;

	case 1: 
		if (hrList.operateOnEducationLevel(dbOP,request,1) == null) strErrMsg = hrList.getErrMsg();
		else{ strErrMsg = "Education Level added successfully."; noError = true;}
		break;
		
	case 2:
		if (hrList.operateOnEducationLevel(dbOP,request,2) == null) strErrMsg = hrList.getErrMsg();
		else{ strErrMsg = "Educational Level edited successfully"; strPrepareToEdit = ""; noError = true;}
		break;
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnEducationLevel(dbOP,request,3);
		if (vRetEdit == null){
			strErrMsg = hrList.getErrMsg();
			strPrepareToEdit = "";
	}	}
	
	vRetResult = hrList.operateOnEducationLevel(dbOP,request,4);
	if (vRetResult == null) strErrMsg = hrList.getErrMsg();
%>
<form action="./hr_educ_levels.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EDUCATIONAL LEVEL RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
	<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td>Education Level</td>
			<%
				if (vRetEdit != null)
					strTemp = WI.getStrValue((String)vRetEdit.elementAt(1));
				else
					strTemp = WI.fillTextValue("edu_name");
			%>
			<td>
				<input class="textbox" value="<%=strTemp%>" name="edu_name" type="text" size="64" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
	<%if(bolAUF){%>
		<tr> 
			<td>Education Group </td>
			<td>
				<%					
					if(vRetEdit != null && vRetEdit.size() > 0)
						strTemp = WI.getStrValue((String)vRetEdit.elementAt(4));
					else
						strTemp = WI.fillTextValue("educ_group");
				%>
				<select name="educ_group">
					<option value=""></option>
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>BS</option>
				<%}else{%>
					<option value="1">BS</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>MA/MS/MD/L.l.B.</option>
				<%}else{%>
					<option value="2">MA/MS/MD/L.l.B.</option>
				
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>Ph.D. / DD</option>
				<%}else{%>
					<option value="3">Ph.D. / DD</option>
				<%}%>
				</select></td>
		</tr>
	<%}%>
		<tr> 
			<td>Code</td>
			<%
				if (vRetEdit != null) 
					strTemp = WI.getStrValue((String)vRetEdit.elementAt(3));
				else 
					strTemp = WI.fillTextValue("edu_code");%>
			<td>
				<input class="textbox"  value="<%=strTemp%>" name="edu_code" type="text" size="8" maxlength="8" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr> 
			<td>Order No.</td>
			<%
				if (vRetEdit != null)
					strTemp = WI.getStrValue((String)vRetEdit.elementAt(2));
				else
					strTemp = WI.fillTextValue("order_no");%>
			<td>
				<input class="textbox" onKeyUp="AllowOnlyFloat('staff_profile','order_no');" value="<%=strTemp%>" name="order_no" 
					type="text" size="4" maxlength="4" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
				<font color="#FF0000" size="1">( 1 as the highest educational level..) </font></td>
		</tr>
		<tr> 
			<%
				if (vRetEdit != null)
					strTemp = (String) vRetEdit.elementAt(1);
				else
					strTemp = WI.fillTextValue("strValue");%>
			<td colspan="2" valign="top">&nbsp;</td>
		</tr>
		<tr> 
			<td width="19%">&nbsp;</td>
			<td width="81%">
			<% if (strPrepareToEdit.compareTo("1") == 0){%>
				<a href="javascript:EditRecord()"><img src="../../../images/edit.gif" border="0"> </a>
				<font size="1">click to save changes</font> <a href="javascript:CancelEdit()">
				<img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>
				<font size="1">click to cancel edit</font> 
			<%}else{%> 
				<a href="javascript:AddRecord()"><img src="../../../images/add.gif" width="42" height="32" border="0"></a>
				<font size="1">click to add entry</font>
			<%}%></td>
		</tr>
		<tr> 
			<td colspan="2">&nbsp;</td>
		</tr>
	</table>
 <% if (vRetResult !=null){%>  
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td colspan="6" bgcolor="#666666" class="thinborder"><div align="center"> 
          <strong><font color="#FFFFFF">LIST OF EDUCATIONAL LEVELS</font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="10%" class="thinborder">ORDER NO</td>
      <td width="15%" class="thinborder">&nbsp;CODE </td>
      <td width="45%" class="thinborder">NAME</td>
      <td width="15%" class="thinborder">GROUP</td>
      <td width="15%" class="thinborder">OPTIONS</td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=5){ 
		strTemp = (String)vRetResult.elementAt(i);
		if (strTemp == null) strTemp = "&nbsp;";
		else strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),false);
	%>
    <tr> 
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
	  <%
	  	
	  %>
      <td class="thinborder"><%=astrEduGroup[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+4), "0"))]%></td>
      <td align="center" class="thinborder">
	  	<a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/edit.gif" border="0"></a> 
		<a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

