<%@ page language="java" import="utility.*,java.util.Vector, hr.HRLeaveSetting" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Misc Deduction Preload Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function PageAction(strPageAction, strInfoIndex,strCode){	
	document.form_.print_page.value = "";
	document.form_.donot_call_close_wnd.value = "1";
	if (strPageAction == 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.info_index.value = strInfoIndex;
			document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}		
	}else{
		document.form_.page_action.value = strPageAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "";
		if (strPageAction == 1)
			document.form_.save.disabled = true;
		document.form_.submit();
		//this.SubmitOnce("form_");
	}	
}

function PrepareToEdit(strInfoIndex){
	document.form_.donot_call_close_wnd.value = "1";	
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function CancelRecord(){
	document.form_.donot_call_close_wnd.value = 1;
	document.form_.close_wnd_called.value = "";
	location = "hr_cert_signatories.jsp";
//	ClearFields();
//	document.form_.donot_call_close_wnd.value = "1";
//	document.form_.prepareToEdit.value = "";
//	document.form_.print_page.value="";
//	this.SubmitOnce("form_");	
}
function ClearFields(){
	document.form_.donot_call_close_wnd.value = 1;
	location = "./hr_cert_signatories.jsp?close_wnd_called=0&donot_call_close_wnd=1";
}

///////////////to reload parent window if this is closed //////////////
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();
		window.opener.focus();
	}
}

-->
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./loan_setting_print.jsp" />
<% return;}
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR-LEAVE APPLICATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-LEAVE","hr_cert_signatories.jsp");
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

	//end of authenticaion code.	
	HRLeaveSetting hrSignatories = new HRLeaveSetting();
	Vector vRetResult = null;
	Vector vEditInfo = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");
	String strInfoIndex = WI.fillTextValue("info_index");

	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (hrSignatories.operateOnLeaveSignatories(dbOP, request, 0) != null)
				strErrMsg = "Signatory deleted successfully";
			else 
				strErrMsg = hrSignatories.getErrMsg();
			
		}else if(strPageAction.compareTo("1") == 0){
			if (hrSignatories.operateOnLeaveSignatories(dbOP, request, 1) != null)
				strErrMsg = "Signatory saved successfully";
			else
				strErrMsg = hrSignatories.getErrMsg();
			
		}else if(strPageAction.compareTo("2") == 0){
			if (hrSignatories.operateOnLeaveSignatories(dbOP,request,2) != null){
				strErrMsg = "Signatory name updated successfully";
				strPrepareToEdit = "";
			}else
				strErrMsg = hrSignatories.getErrMsg();
		}
	}
	
	if (strPrepareToEdit.length() > 0){
		vEditInfo = hrSignatories.operateOnLeaveSignatories(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = hrSignatories.getErrMsg();
	}
	
	vRetResult = hrSignatories.operateOnLeaveSignatories(dbOP,request,4, "103");
	if (vRetResult != null && strErrMsg == null){
		strErrMsg = hrSignatories.getErrMsg();	
	}	
%>
<form name="form_" method="post" action="./hr_cert_signatories.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        HR : CERTIFICATION SIGNATORIES MANAGEMENT PAGE ::::</strong></font></td>
    </tr>    
			
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td height="26">&nbsp;</td>
      <td>Category</td>
			<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = ((Long)vEditInfo.elementAt(1)).toString();
			else			
				strTemp = WI.fillTextValue("catg_index");
			%>
      <td colspan="2">
			<select name="catg_index">
        <%=dbOP.loadCombo("CATG_INDEX","CATG_NAME"," from manage_system_signatory_catg " +
				 " where CATG_INDEX in(103, 104, 105) order by CATG_NAME", strTemp, false)%>
      </select>
			</td>
    </tr>
    <tr> 
      <td width="3%" height="26">&nbsp;</td>
      <td width="17%">Signatory name </td>
			<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(4);
			else			
				strTemp = WI.fillTextValue("signatory_name");
			%>
      <td width="80%" colspan="2"><input name="signatory_name" type="text" size="50" maxlength="64" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Position / label</td>
			<%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(3);
			else			
				strTemp = WI.fillTextValue("label_name");
			%>
      <td colspan="2"><input name="label_name" type="text" size="50" maxlength="64" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    <tr>
      <td height="27" colspan="4">&nbsp;</td>
    </tr> 
	<%if (iAccessLevel > 1) { %>
    <tr> 
      <td height="38" colspan="4" align="center"><%if(strPrepareToEdit.compareTo("1") != 0) {%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1', '','');">
				<font size="1">click to save entries</font> 
        <%}else{%>
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=strInfoIndex%>','');">
				<font size="1"> click to save changes</font>
        <%}%>
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1"> click to clear fields </font></td>
    </tr>
		<%}//end if (iAccessLevel > 1) %>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="4" align="center" class="BorderAll"><font color="#FFFFFF"><strong>:: 
      LIST OF CERTIFICATION SIGNATORIES ::</strong></font></td>
    </tr>
    <tr> 
      <td width="23%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">CATEGORY</font></strong></td>
      <td width="28%" align="center" class="BorderBottomLeft"><strong>SIGNATORY</strong></td>
      <td width="28%" align="center" class="BorderBottomLeft"><strong>LABEL</strong></td>
      <td width="21%" align="center" class="BorderBottomLeftRight"><strong><font size="1">OPTION</font></strong></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size();i+=10){%>
    <tr> 
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
			%>
      <td height="25" class="BorderBottomLeft">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
			%>			
			<td class="BorderBottomLeft">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				strTemp = WI.getStrValue(strTemp);
			%>
      <td class="BorderBottomLeft">&nbsp;<%=strTemp%></td>
      <td align="center" class="BorderBottomLeftRight">
			<% if (iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border=0 > </a> 
				<% if (iAccessLevel ==2){%>
				<a href="javascript:PageAction('0', '<%=vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+2)%>')"><img src="../../../../images/delete.gif" border="0"></a>
				<%}%>
			<%}else{%>
				N/A
			<%}%>			</td>
    </tr>
    <%}// end for loop%>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
	
  <input type="hidden" name="print_page">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>