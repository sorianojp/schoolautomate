<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" buffer="16kb"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>TAX EXEMPTIONS</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 		
		 document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function viewHistory() {
	var pgLoc = "./tax_exemptions_history.jsp";
	var win=window.open(pgLoc,"view_history",'dependent=yes,width=600,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelRecord(){
	location = "./tax_exemptions.jsp";
}
///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}

///////////////////////////////////////// End of collapse and expand filter ////////////////////

</script>


<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	WebInterface WI = new WebInterface(request);

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Tax exemption","tax_exemptions.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vHistory = null;

	String[]  astrExemptionType={"Zero","Single","Head of Family","Married Employed","","","","","","","Dependent"};
 
	strTemp = WI.fillTextValue("page_action");
	
	if(strTemp.length() > 0) {
		if(prConfig.operateOnTaxExemption(dbOP, request, Integer.parseInt(strTemp)) == null){	
			strErrMsg = prConfig.getErrMsg();
			}
		else {
			strPrepareToEdit = "0";
			if(strTemp.equals("1"))
				strErrMsg = "Tax Exemption information successfully added.";
			if(strTemp.equals("2"))
				strErrMsg = "Tax Exemption information successfully edited.";
			if(strTemp.equals("0"))
				strErrMsg = "Tax Exemption information successfully removed.";
		}
	}

	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = prConfig.operateOnTaxExemption(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = prConfig.getErrMsg();
	}
	
	vRetResult  = prConfig.operateOnTaxExemption(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null){
		strErrMsg = prConfig.getErrMsg();
		}
	vHistory  = prConfig.operateOnTaxExemption(dbOP, request, 4, true);
%>
<form name="form_" action="./tax_exemptions.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: TAX EXEMPTIONS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 	
      <td height="23" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
	
    <tr>
      <td height="25">&nbsp;</td>
      <td>Effectivity Date</td>
      <td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("tax_validity_fr");
%>
        <input name="tax_validity_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.tax_validity_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = ((String)vEditInfo.elementAt(4));
else	
	strTemp = WI.fillTextValue("tax_validity_to");
%>
        <input name="tax_validity_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.tax_validity_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Exemption Type </td>
	  
      <td width="78%" valign="top"><select name="tax_status">
          <option value="0">Zero (Z)</option>
          <%	  
			  if(vEditInfo!=null && vEditInfo.size() > 0){		  
			  	strTemp = (String)vEditInfo.elementAt(0);
			  }else{
						strTemp = WI.fillTextValue("tax_status");					
			  }			  
		  if(strTemp.equals("1")){%>
          <option value="1" selected>Single(S)</option>
          <%}else{%>
          <option value="1">Single(S)</option>
          <%}if(strTemp.equals("2")){%>
          <option value="2" selected>Head of Family (HF)</option>
          <%}else{%>
          <option value="2">Head of Family (HF)</option>
					<%}%>
 				
          <%if(strTemp.equals("3")) {%>
          <option value="3" selected>Married Employed (ME)</option>
          <%}else{%>
          <option value="3">Married Employed (ME)</option>
				  <%}if(strTemp.equals("10")) {%>
          <option value="10" selected>Dependent</option>
          <%}else{%>
          <option value="10">Dependent</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td width="3%" height="30">&nbsp;</td>
      <td width="19%" height="30">Exemption Amount</td>
        <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("exempt_amt");
%>	  
      <td height="30"> <input name="exempt_amt" type="text" size="16" maxlength="16" value="<%=WI.getStrValue(strTemp,"0")%>">         
		<select name="exemption_type">
	  <option value="0" selected>total amount</option>	  
	 <% if(vEditInfo == null || vEditInfo.size() == 0) {%>
		  <option value="1">per exemption type</option>
	<%}%>
	  
	<%
	if(vEditInfo != null && vEditInfo.size() > 0){			
	if (Integer.parseInt((String)vEditInfo.elementAt(2)) > 0 ) {%>
		  <option value="1" selected>per exemption type</option>
	<%}%>	  </select> 
	<%}%>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
	  <%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("max_limit");
%>	 
      <td height="25">Maximum Limit </td>
      <td height="25"><input name="max_limit" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp,"0")%>"> 
        <font color="#FF0000" size="1">(applicable only if per exemption type)</font></td>
    </tr>
    <tr>
      <td height="35" align="center">&nbsp;</td>
      <td height="35" colspan="2">
			<%if(strPrepareToEdit.compareTo("1") != 0) {%>
			<input name="close_existing" type="checkbox" value="1">
			close existing exemption type
			with open effective date to
			<%}%>
			</td>
    </tr>
    <tr> 
      <td height="28" colspan="3" align="center">
	  <%if(strPrepareToEdit.compareTo("1") != 0) {%>
		<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:PageAction('1','');">		
	  <font size="1">click to save entries</font>
	  <%}else{%>	  
		<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:PageAction('2', '');">				
	  <font size="1">click to save changes</font>
	  <%}%>
		<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:CancelRecord();">				
	  <font size="1">click to cancel/clear entries</font>		<font size="1">&nbsp;</font></td>      
	  </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292"><font color="#FFFFFF"><strong>TAX EXEMPTION 
          ENTRIES</strong></font></td>
    </tr>
    <tr> 
      <td width="36%" height="26" align="center"><font size="1"><strong>EXEMPTION 
      TYPE </strong></font></td>
      <td width="23%" align="center"><font size="1"><strong>EXEMPTION AMOUNT</strong></font></td>
      <td width="26%" align="center"><font size="1"><strong>EFFECTIVITY DATES</strong></font></td>
      <td colspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <%  
	for (int i = 0; i < vRetResult.size(); i +=6){%>
    <tr> 
      <td height="25">&nbsp; 
        <% 
	if (Integer.parseInt((String)vRetResult.elementAt(i)) == 10){%>
        <%=astrExemptionType[Integer.parseInt((String)vRetResult.elementAt(i))]%> 
        per exemption type <br>
&nbsp;        (maximum = <%=(String)vRetResult.elementAt(i+2) %>)
        <%}else{%>
        <%=astrExemptionType[Integer.parseInt((String)vRetResult.elementAt(i))]%>
        <%}%>        </td>
      <td height="25" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 1),true)%><strong>&nbsp;</strong></td>
      <td height="25">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4)," - ",""," - present")%></td>
      <td width="7%" height="25">
	  <%if(iAccessLevel > 1){%>
	  <input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:PrepareToEdit('<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%>');">
	  <%}%>	  </td>
      <td width="8%"> 
        <%if(iAccessLevel == 2){%>        
        <input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i+5)%>');">
      <%}%></td>
    </tr>
    <% } // end for loop %>
  </table>
	<%}%>
	<%if(vHistory != null && vHistory.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td><div onClick="showBranch('branch1');swapFolder('folder1')">
          <img src="../../../images/box_with_plus.gif" width="7" height="7" border="0" id="folder1">
          <b><font color="#0000FF">View History</font></b></div>
        <span class="branch" id="branch1">
         <table  bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292"><strong>TAX EXEMPTION 
        ENTRIES HISTORY</strong></td>
    </tr>
    <tr> 
      <td width="36%" height="26" align="center"><font size="1"><strong>EXEMPTION 
      TYPE </strong></font></td>
      <td width="23%" align="center"><font size="1"><strong>EXEMPTION AMOUNT</strong></font></td>
      <td width="26%" align="center"><font size="1"><strong>EFFECTIVITY DATES</strong></font></td>
      <td colspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <%  
	for (int i = 0; i < vHistory.size(); i +=6){%>
    <tr> 
      <td height="25">&nbsp; 
        <% 
	if (Integer.parseInt((String)vHistory.elementAt(i)) == 10){%>
        <%=astrExemptionType[Integer.parseInt((String)vHistory.elementAt(i))]%> 
        per exemption type <br>
&nbsp;        (maximum = <%=(String)vHistory.elementAt(i+2) %>)
        <%}else{%>
        <%=astrExemptionType[Integer.parseInt((String)vHistory.elementAt(i))]%>
        <%}%>        </td>
      <td height="25" align="right"><%=CommonUtil.formatFloat((String)vHistory.elementAt(i + 1),true)%><strong>&nbsp;</strong></td>
      <td height="25">&nbsp;<%=WI.getStrValue((String)vHistory.elementAt(i+3))%><%=WI.getStrValue((String)vHistory.elementAt(i + 4)," - ",""," - present")%></td>
      <td width="7%" height="25">
	  <%if(iAccessLevel > 1){%>
	  <input type="button" name="edit2" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
		onClick="javascript:PrepareToEdit('<%=WI.getStrValue((String)vHistory.elementAt(i+5))%>');">
	  <%}%>	  </td>
      <td width="8%"> 
        <%if(iAccessLevel == 2){%>        
        <input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:PageAction('0','<%=(String)vHistory.elementAt(i+5)%>');">
      <%}%></td>
    </tr>
    <% } // end for loop %>
  </table>	
      </span> </td>
    </tr>
  </table>
  
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>