<%@ page language="java" import="utility.*,Accounting.COASetting,java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>COA Sub-Account Setup</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
	
	function UpdateCostCenters(strParentIndex){
		var sT = "./coa_update_cost_center_list.jsp?parent_index="+strParentIndex+"&opner_form_name=form_";
		var win=window.open(sT,"UpdateCostCenters",'dependent=yes,width=900,height=500,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function GoBack(strImmediateParent){
		var vCountry = "";
		var vTemp = document.form_.parent_level.value;
		var vAcctClass = document.form_.acct_class.value;				
		vTemp--;
		
		var vLocation = "./coa_setup_sub_accounts.jsp?parent_index="+strImmediateParent+"&parent_level="+vTemp+"&acct_class="+vAcctClass;
		
		if(document.form_.country){
			vCountry = document.form_.country.value;
			vLocation += "&country="+vCountry;
		}
		
		location = vLocation;
	}
	
	function UpdateSubAccounts(strParentIndex, strSubAccountName){
		var vCountry = "";
		var vTemp = document.form_.parent_level.value;
		var vAcctClass = document.form_.acct_class.value;
		vTemp++;
		
		document.form_.sub_acc_name.value=strSubAccountName;
		//alert(docu
		
		var vLocation = "./coa_setup_sub_accounts.jsp?parent_index="+strParentIndex+"&parent_level="+vTemp+"&acct_class="+vAcctClass;
		
		if(document.form_.country){
			vCountry = document.form_.country.value;
			vLocation += "&country="+vCountry;
		}
		
		location = vLocation;
	}
	
	function UpdateTaxCode() {
		var loadPg = "../chart_of_accounts/tax_code.jsp";
		var win=window.open(loadPg,"UpdateTaxCode",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function ReloadPage(){
		document.form_.is_reloaded.value = "1";
		document.form_.submit();
	}
	
	function CancelOperation(){
		document.form_.is_reloaded.value = "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.info_index.value = "";
		document.form_.submit();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this sub-account?'))
				return;
		}
		
		if(strAction == '1' || strAction == '2'){
			if(document.form_.acct_class.value.length == 0){
				alert("Please select classification.");
				return;
			}
			
			if(document.form_.has_CC.value == '1' && document.form_.country.value.length == 0){
				alert("Please select country.");
				return;
			}
			
			if(document.form_.acct_name.value.length == 0){
				alert("Please provide account name.");
				return;
			}
			
			if(document.form_.tax_code.value.length == 0){
				alert("Please select tax code.");
				return;
			}
		}
		
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","coa_setup_sub_accounts.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
	
	int iMaxValue = 0;
	String strSALevels = null;
	String strSADigits = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strParentLevel = WI.getStrValue(WI.fillTextValue("parent_level"), "1");
	String strParentIndex = WI.fillTextValue("parent_index");
	String strImmediateParent = null;
	String strHasCC = "0";
	
	Vector vParentInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vSegmentSetup = null;
	COASetting coa = new COASetting();
	
	vSegmentSetup = coa.operateOnSegmentSetup(dbOP, request, 4);
	if(vSegmentSetup == null)
		strErrMsg = coa.getErrMsg();
	else{
		if((String)vSegmentSetup.elementAt(0) != null)
			strHasCC = "1";
	
		strSALevels = (String)vSegmentSetup.elementAt(2);
		strSADigits = (String)vSegmentSetup.elementAt(3);		
		if(strSADigits.equals("1"))
			iMaxValue = 9;
		else if(strSADigits.equals("2"))
			iMaxValue = 99;
		else
			iMaxValue = 999;
			
		if(WI.fillTextValue("acct_class").length() > 0 || WI.fillTextValue("country").length() > 0){
			if(!strParentLevel.equals("1")){
				vParentInfo = coa.getCOAInfo(dbOP, request, strParentIndex);
				if(vParentInfo == null)
					strErrMsg = coa.getErrMsg();
				else
					strImmediateParent = WI.getStrValue((String)vParentInfo.elementAt(6), "");
			}
		
			strTemp = WI.fillTextValue("page_action");
			if(strTemp.length() > 0){
				if(coa.operateOnSubAccountSetup(dbOP, request, Integer.parseInt(strTemp)) == null)
					strErrMsg = coa.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Sub-account successfully removed.";
					if(strTemp.equals("1"))
						strErrMsg = "Sub-account successfully recorded.";
					if(strTemp.equals("2"))
						strErrMsg = "Sub-account successfully edited.";
					
					strPrepareToEdit = "0";
				}
			}
			
			vRetResult = coa.operateOnSubAccountSetup(dbOP, request, 4);
			if(vRetResult == null && strTemp.length() == 0)
				strErrMsg = coa.getErrMsg();
				
			if(strPrepareToEdit.equals("1")){
				vEditInfo = coa.operateOnSubAccountSetup(dbOP, request, 3);
				if(vEditInfo == null){
					strErrMsg = coa.getErrMsg();
					strPrepareToEdit = "0";
				}
			}
		}
	}
%>
<body bgcolor="#D2AE72">
<form action="./coa_setup_sub_accounts.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF">
			  	<strong>:::: ACCOUNT CLASSIFICATION SETUP ::::</strong></font></div></td>
    	</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="87%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td width="10%" align="right">
			<%if(!strParentLevel.equals("1")){%>
				<a href="javascript:GoBack('<%=strImmediateParent%>');">
					<img src="../../../../images/go_back.gif" border="0"></a>
			<%}%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<%if(strHasCC.equals("1")){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Country:</td>
			<td>
				<%if(vParentInfo == null){
					strErrMsg = 
						" from ac_coa_setup_country "+
						" join country on (country.country_index = ac_coa_setup_country.country_index) "+
						" order by country_name ";
					
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(14);
					else
						strTemp = WI.fillTextValue("country");
				%>
					<select name="country" onChange="CancelOperation();">
						<option value="">Select country</option>
						<%=dbOP.loadCombo("display_order","country_name", strErrMsg, strTemp, false)%>
					</select>
				<%}else{%>
					<input type="hidden" name="country" value="<%=(String)vParentInfo.elementAt(1)%>">
					<strong><%=(String)vParentInfo.elementAt(4)%></strong>
				<%}%></td>
		</tr>
		<%}%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Classification:</td>
			<td width="77%">				
				<%if(vParentInfo == null){
					if(vEditInfo != null && vEditInfo.size() > 0)						
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("acct_class");
				%> 
					<select name="acct_class" onChange="CancelOperation();">
						<option value="">Select classification</option>
						<%=dbOP.loadCombo("coa_cf","cf_name"," from ac_coa_cf", strTemp, false)%>
					</select>
				<%}else{%>
					<input type="hidden" name="acct_class" value="<%=(String)vParentInfo.elementAt(1)%>">
					<strong><%=(String)vParentInfo.elementAt(2)%>  </strong>
				<%}%></td>
		</tr>		
		<%if(vParentInfo != null){%>	
		<tr>
			<td height="25">&nbsp;</td>
			<td>Account Code: </td>
			<td><strong><%=(String)vParentInfo.elementAt(5)%></strong></td>
		</tr>
		<%}%>
		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Sub-Account Level:</td>
			<td><strong><%=strParentLevel%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Account Name: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("acct_name");
				%>
				<input name="acct_name" type="text" size="32" maxlength="256" class="textbox" value="<%=strTemp%>" 
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Account Type: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0 && !(WI.fillTextValue("is_reloaded")).equals("1"))
						strErrMsg = (String)vEditInfo.elementAt(7);
					else
						strErrMsg = WI.getStrValue(WI.fillTextValue("acct_type"), "0");
				%>
				<select name="acct_type" onChange="ReloadPage();">
				<%if(strErrMsg.equals("0")){%>
					<option value="0" selected>Header (Non-Postable)</option>
				<%}else{%>
					<option value="0">Header (Non-Postable)</option>
					
				<%}if(strErrMsg.equals("1")){%>
					<option value="1" selected>Detail Account (Postable)</option>
				<%}else{%>
					<option value="1">Detail Account (Postable)</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Account Order: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						int iTemp = Integer.parseInt((String)vEditInfo.elementAt(12));
						strTemp = Integer.toString(iTemp);
					}
					else
						strTemp = WI.fillTextValue("acct_order");
				%>				
				<select name="acct_order">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(strTemp,"1"));
				for(int i = 1; i <= iMaxValue ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Tax Code: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("tax_code");
				%>
				<select name="tax_code">
					<option value="">Select tax code</option>
					<%=dbOP.loadCombo("TAX_CODE_INDEX","TAX_CODE +' ::: '+DESCRIPTION,tax_rate",
					" from AC_COA_TAXCODE order by TAX_CODE asc",strTemp, false)%>
				</select>
				
				<a href="javascript:UpdateTaxCode();"><img src="../../../../images/update.gif" border="0" ></a>
				<font size="1">Update  Tax Code</font></td>
		</tr>
	<%	
		if(strErrMsg.equals("0")){
	%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(13);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("with_cost_center"), "0");					
					
					if(strTemp.equals("1"))
						strTemp = " checked";				
					else
						strTemp = "";
				%>
				<input name="with_cost_center" type="checkbox" value="1"<%=strTemp%>>With Cost Center</td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../../images/save.gif" border="0"></a>
				<%}else {
					if(vEditInfo!=null){%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../../images/edit.gif" border="0"></a>
					<%}
				}%>
				<a href="javascript:CancelOperation();"><img src="../../../../images/cancel.gif" border="0"></a>
			<%}else{%>
				Not authorized to add/modify sub-account details.
			<%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
  	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center">
				<strong>::: LIST OF LEVEL <%=WI.fillTextValue("parent_level")%> SUB-ACCOUNTS :::</strong></div></td>
	 	</tr>
		<tr>
			<td height="25" width="29%" align="center" class="thinborder"><strong>Account Name</strong></td>
			<td width="22%" align="center" class="thinborder"><strong>Account Type</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Account Order</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Unit Centers</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Sub-Accounts</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 16){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">
			<%
				if(((String)vRetResult.elementAt(i+7)).equals("0"))
					strTemp = "Header (Non-Postable)";
				else
					strTemp = "Detail Account (Postable)";
			%>
				<%=strTemp%></td>
			<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+12)%></td>
			<td align="center" class="thinborder">
			<%if(((String)vRetResult.elementAt(i+7)).equals("0") && ((String)vRetResult.elementAt(i+13)).equals("1")){%>
				<a href="javascript:UpdateCostCenters('<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../../images/update.gif" border="0"></a>
			<%}else{%>&nbsp;<%}%></td>
			<td align="center" class="thinborder">
			<%if(((String)vRetResult.elementAt(i+7)).equals("0") && (Integer.parseInt(strSALevels) > Integer.parseInt(strParentLevel))){%>
				<a href='javascript:UpdateSubAccounts("<%=(String)vRetResult.elementAt(i)%>","<%=(String)vRetResult.elementAt(i+2)%>");'>
					<img src="../../../../images/update.gif" border="0"></a>
			<%}else{%>&nbsp;<%}%>
			</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+15);
			%>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){
					if(strTemp.equals("0")){%>
						<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../../images/edit.gif" border="0"></a>
						<%if(iAccessLevel == 2){%>
							<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
								<img src="../../../../images/delete.gif" border="0"></a>
						<%}
					}else{%>
						Not allowed.
					<%}
				}else{%>
					Not authorized.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="parent_level" value="<%=strParentLevel%>">
	<input type="hidden" name="parent_index" value="<%=strParentIndex%>">
	<input type="hidden" name="has_CC" value="<%=strHasCC%>">
	<input type="hidden" name="is_reloaded">
	<input type="hidden" name="sub_acc_name" value="<%=WI.fillTextValue("sub_acc_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>