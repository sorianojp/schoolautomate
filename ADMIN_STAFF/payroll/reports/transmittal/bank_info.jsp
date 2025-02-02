<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRTransmittal"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
 %>
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transmittal Bank info</title>
<meta http-equiv="Content-Type" content=asd"text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

	TD.thinborder {
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	}
	TABLE.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	}

</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function CancelRecord(){
	document.form_.donot_call_close_wnd.value = "1";
	location = "./bank_info.jsp";
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex, strAccount){
		var vProceed = confirm('Delete '+strAccount+' ?');
		if(!vProceed)
			return;

	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function PageAction(strAction,strIndex,strEmployer){
	if(strAction == 0){
	}
	
	if(strAction == 1){
		document.form_.save.disabled = true;
	}	
	if(strAction == 3){
		document.form_.prepareToEdit.value = "1";
		
	}
	if(strAction == 3 || strAction == 0)
		document.form_.employer_index.value = strIndex;
	
	document.form_.page_action.value = strAction;	
	this.SubmitOnce('form_');
}

function ReloadPage() {
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce('form_');
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();
		window.opener.focus();
	}
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","bank_info.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"bank_info.jsp");

if (strTemp == null) 
	strTemp = "";
//
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

PRTransmittal PRBanks = new PRTransmittal(request);
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
String strPageAction = WI.fillTextValue("page_action");
String[] astrValues = {"26", "94", "47"};
String[] astrCodes = {"MBTC", "GBB","PSB"};
										 
Vector vEditInfo = null;
Vector vRetResult = null;
PRBanks.populateSupportedBanks(dbOP);
String strMainIndex = WI.fillTextValue("bank_main_index");

if(strPageAction.length() > 0){		
	if(PRBanks.operateOnBankAccounts(dbOP, request, Integer.parseInt(strPageAction)) != null){
		strErrMsg = "Operation Successful";
		strPrepareToEdit = "";
	}else
		strErrMsg = PRBanks.getErrMsg();
}

if(strPrepareToEdit.equals("1")){
	vEditInfo = PRBanks.operateOnBankAccounts(dbOP,request, 3);
}

vRetResult = PRBanks.operateOnBankAccounts(dbOP, request, 4);
%>
<body bgcolor="#D2AE72" class="bgDynamic" onUnload="ReloadParentWnd();">
<form action="bank_info.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="3" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      BANK INFO ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><table width="95%" border="0" align="center" cellpadding="4" cellspacing="0">
 
    <tr> 
      <td width="6%">&nbsp;</td>
			<td width="25%">Bank Name </td>
				<%
				 if(vEditInfo != null && vEditInfo.size() > 0)
					strMainIndex = (String) vEditInfo.elementAt(4);
				 else
					strMainIndex = WI.fillTextValue("bank_main_index");
				%>							
				<td width="69%">
				<select name="bank_main_index" onChange="ReloadPage();">
 					<option value="">Select Bank Name</option>
					<%=dbOP.loadCombo("bank_main_index","bank_name", " from pr_supported_bank where is_allowed = 1 " +
					" order by bank_name", strMainIndex, false)%>
				</select>				</td>
     </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Branch Code </td>
		  <%
		 	 if(vEditInfo != null && vEditInfo.size() > 0)
	   	  strTemp = (String) vEditInfo.elementAt(2);
		   else
		 		strTemp = WI.fillTextValue("branch_code");
			%>
      <td>
			<input name="branch_code" value="<%=WI.getStrValue(strTemp,"")%>" type= "text" class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10"></td>
    </tr>
    <tr> 
      <td width="6%">&nbsp;</td>
	  <td>Account No </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(3);
	     else
				strTemp = WI.fillTextValue("account_no");		
	  %>
	  <td><input name="account_no" value="<%=WI.getStrValue(strTemp,"")%>" type= "text" class="textbox"  
				 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="16"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Company Code </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(5);
	     else
				strTemp = WI.fillTextValue("company_code");		
	  %>			
      <td><input name="company_code" value="<%=WI.getStrValue(strTemp,"")%>" type= "text" class="textbox"  
				 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10"></td>
    </tr>
		<%if(strMainIndex.equals("6")){// for metrobank only%>
		<tr>
			<td>&nbsp;</td>
			<td>Bank Code </td>
		  <%
		 	 if(vEditInfo != null && vEditInfo.size() > 0)
	   	  strTemp = (String) vEditInfo.elementAt(2);
		   else
		 		strTemp = WI.fillTextValue("bank_code");
			%>			
			<td>
				<select name="bank_code" onChange="ReloadPage();">
				<%for(int i = 0; i < astrValues.length; i++){
					if(strTemp.equals(astrValues[i])){%>
        <option value="<%=astrValues[i]%>" selected><%=astrCodes[i]%></option>
				<%}else{%>
        <option value="<%=astrValues[i]%>"><%=astrCodes[i]%></option>
        <%}
				}%>
      </select></td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Payroll Accounts Branch </td>
		  <%
		 	 if(vEditInfo != null && vEditInfo.size() > 0)
	   	  strTemp = (String) vEditInfo.elementAt(6);
		   else
		 		strTemp = WI.fillTextValue("pay_branch_code");
			%>					
			<td><input name="pay_branch_code" value="<%=WI.getStrValue(strTemp,"")%>" type= "text" class="textbox"  
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10"></td>
		</tr>
		
		<tr> 
			<td width="6%">&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<%}%>
     <tr> 
       <td width="6%">&nbsp;</td>
	   <td colspan="2" align="center"> 
		 <% if (iAccessLevel > 1){%>
	     <%if(strPrepareToEdit.compareTo("1") != 0) {%>
		 <!--
		 <a href="javascript:saveRecord();"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
		 -->
		 <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
		 <font size="1">click to save entries</font> 
		 <%}else{%>
		 <!--
		 <a href="javascript:EditRecord();"><img src="../../../../images/edit.gif" border="0"></a>
		 -->
		 <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
		 <font size="1">click to save changes</font>
		 <%}%>
		 <!--
		 <a href='javascript:CancelRecord("")'><img src="../../../../images/cancel.gif" border="0"></a>
		 -->
			<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelRecord();">		 
		  <font size="1">click to cancel and clear entries</font> 
		  <%}%>		</td>
     </tr>
    </table>   </td></tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborder">EMPLOYERS</td>
    </tr>
    <tr>
      <td width="11%" height="25" align="center" class="thinborder">BANK NAME </td>
      <td width="15%" align="center" class="thinborder">BRANCH CODE </td> 
      <td width="27%" align="center" class="thinborder">ACCOUNT</td>
      <td width="30%" align="center" class="thinborder">COMPANY CODE</td>
      <td colspan="2" align="center" class="thinborder">OPTIONS</td>
    </tr>
    <%for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=15){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(iLoop+1)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(iLoop+2);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td> 
			<%
				strTemp = (String)vRetResult.elementAt(iLoop+3);
			%>			
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(iLoop+5);
			%>						
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td width="8%" align="center" class="thinborder"><a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(iLoop)%>');"><img src="../../../../images/edit.gif" border="0"></a></td>
      <td width="9%" class="thinborder"><div align="center">
			<%if(!((String)vRetResult.elementAt(iLoop+1)).equals("1")){%>
			<a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(iLoop)%>','<%=(String)vRetResult.elementAt(iLoop+2)%>');"><img src="../../../../images/delete.gif" border="0"></a>
			<%}else{%>
				DEFAULT
			  <%}%>
			</div></td>
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
 <input type="hidden" name="print_page">
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
<%
	dbOP.cleanUP();
%>
