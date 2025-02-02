<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
</head>

<script language="JavaScript" src="../../jscript/common.js"></script>

<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex, strPrefix) {
	document.form_.donot_call_close_wnd.value = "1";
	if(strAction == 0){			
		if(!confirm("Do you want to delete this prefix "+strPrefix+" ?"))
			return;
		}		
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") 
		window.opener.ReloadPage();
}

function PrepareToEdit(strInfoIndex) {
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>

<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	
	String strInfoIndex = null;
	String strPageAction = null;	
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	//add security here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security


	try
	{
		dbOP = new DBOperation();
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

	ParentRegistration prSMS = new ParentRegistration();	

	Vector vEditInfo  = new Vector();
	Vector vRetResult = new Vector();	

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {		
		strPrepareToEdit = "0";	
		if(prSMS.operateOnGSMPrefix(dbOP,request, Integer.parseInt(strTemp)) == null)
				strErrMsg = prSMS.getErrMsg();			
		else		
			{
				if(strTemp.compareTo("1") == 0)							
					strErrMsg = "Prefix successfully added.";		
				if(strTemp.compareTo("2") == 0)			
					strErrMsg = "Prefix successfully edited.";
				if(strTemp.compareTo("0") == 0)					
					strErrMsg = "Prefix successfully deleted.";
			}
		}	
	
		//search all material
		vRetResult = prSMS.operateOnGSMPrefix(dbOP,request,4);
		if(vRetResult == null)
			strErrMsg = prSMS.getErrMsg();
			
		
//get vEditInfo If it is called.
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = prSMS.operateOnGSMPrefix(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = prSMS.getErrMsg();
}

%>


<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();">
<form action="./manage_gsm_prefix.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="8"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GSM PROVIDER PREFIX UPDATE ::::</strong></font></div></td>
    </tr>
	</table>
	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td height="30" colspan="3"><b><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg,"Message: ","","")%></font></b> </td>      
    </tr>
    <tr> 
      <td width="4%" height="30">&nbsp;</td>
	  <td height="30" width="15%">GSM Prefix</td>
	  <%
	  	strTemp = WI.fillTextValue("gsm_prefix");	  
	  	if(vEditInfo!=null && vEditInfo.size()>0)
	  		strTemp = (String)vEditInfo.elementAt(1);		
		
	  %>	
      <td width="96%" height="30">
	  	<input type="text" name="gsm_prefix" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white';" 					
					size="5" maxlength="3" value="<%=strTemp%>"/><font size="1">(917,918,923)</font>
	  </td>		
    </tr>
	
	<tr> 
      <td width="4%" height="30">&nbsp;</td>
	  <td height="30">Mobile Provider</td>
	  <%
	  	strTemp = WI.fillTextValue("mobile_provider");
		if(vEditInfo!=null && vEditInfo.size()>0)
	  		strTemp = (String)vEditInfo.elementAt(3);
      %>	
      <td width="96%" height="30">
	  <select name="mobile_provider" style="font-size:11px;" onChange="">
	  	<%=dbOP.loadCombo("PROVIDER_INDEX","PROVIDER_NAME"," from SMS_GSM_PROVIDER order by PROVIDER_INDEX", strTemp, false)%>
	  	</select>
	  </td>		
    </tr>
	
<%if(iAccessLevel > 1) {%>
    <tr> 
      <td height="51"></td>
      <td height="51" colspan="2"><font size="1"> 
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href="javascript:PageAction('1', '', '');"><img src="../../images/save.gif" border="0" name="hide_save"></a> 
        Click to save entries 
        <%}else{%>
        <a href="javascript:PageAction('2', '<%=WI.fillTextValue("info_index")%>', '');"><img src="../../images/edit.gif" border="0"></a> 
        Click to edit event 
        <%}%>
        <a href="./manage_gsm_prefix.jsp"><img src="../../images/cancel.gif" border="0"></a> 
        Click to clear entries </font></td>
    </tr>
    <%}//show only if authorized.%>
  </table>


<%if(vRetResult != null && vRetResult.size() > 0){%>

  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
   <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" class="thinborder"><div align="center"><font color="#FF0000">GSM PREFIX LIST</font></div></td>
    </tr>
    <tr> 
      <td width="31%" height="25" class="thinborder"><div align="center"><font size="1"><strong> PREFIX </strong></font></div></td>      
	  <td width="31%" height="25" class="thinborder"><div align="center"><font size="1"><strong> PROVIDER </strong></font></div></td>      
      <td class="thinborder"><div align="center"><font size="1"><strong>OPTIONS</strong></font></div></td>
    </tr>
<%
for(int i = 0; i < vRetResult.size(); i += 4){%>
    <tr> 
      <td height="25" class="thinborder" align="center">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>      
	  <td height="25" class="thinborder" align="center">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>      
      <td width="17%" class="thinborder"><div align="center"><font size="1">&nbsp; 
         <%
		if(iAccessLevel > 1){%>
          <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../images/edit.gif" width="53" height="28" border="0"></a> 
          <%}if(iAccessLevel == 2){%>
          <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+1)%>');"><img src="../../images/delete.gif" width="53" height="26" border="0"></a> 
		<%}%>
          </font></div></td>
    </tr>
<%}//for loop%>	
  </table>
<%}%>


<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="donot_call_close_wnd">
<input type="hidden" name="close_wnd_called" value="0">

</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>