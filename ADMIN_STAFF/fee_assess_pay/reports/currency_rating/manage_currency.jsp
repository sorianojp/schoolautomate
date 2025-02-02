<%@ page language="java" import="utility.*, java.util.Vector, locker.Currency " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link href="../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../../css/frontPageLayout.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="javascripts/Ajax/ajax.js"></script>

<script language="javascript">

	function PageAction(strAction, strInfoIndex) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?"))
				document.form_.page_action.value ='0';	
		}
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value ='';
		document.form_.prepareToEdit.value ='1';
		
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function CancelRecord(){
		location = "manage_currency.jsp";
	}		
</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	Currency currency = new Currency();
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");

	try{
		dbOP = new DBOperation();
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
	

	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
															"manage_currency.jsp");
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","REPORTS-CASHIER REPORT",request.getRemoteAddr(),
															"manage_currency.jsp");
	}
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



	int iCount = 1;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(currency.operateOnCurrency(request,dbOP, Integer.parseInt(strTemp)) == null)
			strErrMsg = currency.getErrMsg();
		else {	
			strErrMsg = "Operation Successful.";
			strPreparedToEdit = "0";
		}
	}

	if(strPreparedToEdit.equals("1")){		
		vEditInfo = currency.operateOnCurrency(request,dbOP, 3);
		if(vEditInfo == null)
			strErrMsg = currency.getErrMsg();
	}
	
	vRetResult = currency.operateOnCurrency(request,dbOP, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = currency.getErrMsg();	
%>
<body>
<form name="form_" method="post">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=1"></jsp:include>
	  </td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        CURRENCY MANAGEMENT PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="30"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="3%" height="28">&nbsp;</td>
    <td width="17%">Name</td>
    <td width="80%"><%if(vEditInfo != null && vEditInfo.size() > 0){		
			strTemp = (String)vEditInfo.elementAt(1);		
		}else{
			strTemp = WI.fillTextValue("curr_name");
			
		}%>
      <input type="text" name="curr_name" id="curr_name" value="<%=WI.getStrValue(strTemp)%>" /></td>
  </tr>
  <tr>
    <td height="27">&nbsp;</td>
    <td>Code</td>
    <td><%if(vEditInfo != null && vEditInfo.size() > 0){		
			strTemp = (String)vEditInfo.elementAt(2);		
		}else{
			strTemp = WI.fillTextValue("curr_code");
			
		}%>
      <input type="text" name="curr_code" id="curr_code" value="<%=WI.getStrValue(strTemp)%>" size="16" maxlength="32" /></td>
  </tr>
  <tr>
    <td height="27">&nbsp;</td>
    <td>Symbol</td>
    <td><%if(vEditInfo != null && vEditInfo.size() > 0){		
			strTemp = (String)vEditInfo.elementAt(3);		
		}else{
			strTemp = WI.fillTextValue("curr_symbol");
			
		}%>
      <input type="text" name="curr_symbol" id="curr_symbol" value="<%=WI.getStrValue(strTemp)%>" 
		 	size="4" maxlength="8"/></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="2" align="center"><%if(vEditInfo != null && vEditInfo.size() > 0){%>
      <input name="button" type="button" style="font-size:11px; height:26px;border: 1px solid #FF0000;"onclick="PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');" value="Update" />
			<font size="1"> click to save changes</font>
      <%}else{%>
      <input name="button" type="button" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onclick="PageAction('1','');" value="Save" />
			<font size="1"> click to Add currency</font>
      <%}%>
			<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
			<font size="1"> click to cancel/clear fields </font>
      <!-- if there are registered/available currency in the database -->
      <%if(vRetResult != null && vRetResult.size() > 0){%></td>
    </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="2" align="center">&nbsp;</td>
  </tr>
</table>
		<!-- if edit button is click, show update and restore button. else show add current button -->
		<table width="100%" border="0" cellspacing="0" cellpadding="0" bordercolor="#FFFFFF" class="thinborder">
				<tr bgcolor="#B9B292" style="color:#FFFFFF;"> 			
					<td height="25" colspan="6" align="center" class="thinborder" bgcolor="#A49A6A">
						<strong>::: LIST OF CURRENCY ::: </strong>
					</td>
				</tr>
				<tr bgcolor="#FFFFF0" height="18px">
					<td height="25" width="9%" align="center" class="thinborder">&nbsp;</td>
					<td width="26%" align="center" class="thinborder"><strong>Name</strong></td>
					<td width="25%" align="center" class="thinborder"><strong>Code</strong></td>
					<td width="18%" align="center" class="thinborder"><strong>Symbol</strong></td>
					<td width="22%"  colspan="2" align="center" class="thinborder"><strong>Options</strong></td>
				</tr>
			<%	
			
				for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
				<tr  align="center" bgcolor="#FFFFF0">
					<td height="25" align="center" class="thinborder"><%=iCount%></td>
					<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
					<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
					<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
					<td class="thinborder"  colspan="2">
					
					<input type="button" name="editBtn" value=" EDIT "
						onclick = "PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');" 
						style="font-size:11px; height:26px;border: 1px solid #FF0000;"/>
					
					&nbsp;
					<input type="button" name="deleteBtn" value="DELETE"
						onclick = "PageAction('0','<%=(String)vRetResult.elementAt(i)%>');" 
						style="font-size:11px; height:26px;border: 1px solid #FF0000;"/>	
					</td>
				</tr>
				<%}%>
	</table>
	<%}%>	
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>
