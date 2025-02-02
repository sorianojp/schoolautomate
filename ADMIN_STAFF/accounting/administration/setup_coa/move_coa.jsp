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
	var imgWnd;
	
	function ShowProcessing()
	{
		imgWnd=
		window.open("../../../../commfile/processing.htm","PrintWindow",'width=600,height=300,top=220,left=200,toolbar=no,location=no,directories=no,status=no,menubar=no');
		this.SubmitOnce('form_');
		imgWnd.focus();
	}
	function CloseProcessing()
	{
		if (imgWnd && imgWnd.open && !imgWnd.closed) imgWnd.close();
	}

	function Delete(strCOAIndex){
		if(!confirm("Are you sure you want to delete this COA and move every child one level higher?"))
			return;
		document.form_.coa_index.value = strCOAIndex;
		document.form_.remove_coa.value = "1";
		this.ShowProcessing();
	}
	
	function GoBack(strImmediateParent){
		var vCountry = "";
		var vTemp = document.form_.parent_level.value;
		var vAcctClass = document.form_.acct_class.value;				
		vTemp--;
		
		var vLocation = "./move_coa.jsp?parent_index="+strImmediateParent+"&parent_level="+vTemp+"&acct_class="+vAcctClass;
		
		if(document.form_.country){
			vCountry = document.form_.country.value;
			vLocation += "&country="+vCountry;
		}
		
		location = vLocation;
	}
	
	function UpdateSubAccounts(strParentIndex){
		var vCountry = "";
		var vTemp = document.form_.parent_level.value;
		var vAcctClass = document.form_.acct_class.value;
		vTemp++;
		
		var vLocation = "./move_coa.jsp?parent_index="+strParentIndex+"&parent_level="+vTemp+"&acct_class="+vAcctClass;
		
		if(document.form_.country){
			vCountry = document.form_.country.value;
			vLocation += "&country="+vCountry;
		}
		
		location = vLocation;
	}
	
	function ReloadPage(){
		document.form_.is_reloaded.value = "1";
		document.form_.submit();
	}
	
	function CancelOperation(){
		document.form_.is_reloaded.value = "";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strTemp = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","move_coa.jsp");
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
	
	String strSALevels = null;
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
			
		if(WI.fillTextValue("acct_class").length() > 0 || WI.fillTextValue("country").length() > 0){
			if(!strParentLevel.equals("1")){
				vParentInfo = coa.getCOAInfo(dbOP, request, strParentIndex);
				if(vParentInfo == null)
					strErrMsg = coa.getErrMsg();
				else
					strImmediateParent = WI.getStrValue((String)vParentInfo.elementAt(6), "");
			}
			
			if(WI.fillTextValue("remove_coa").length() > 0){
				if(!coa.moveCOA(dbOP, request))
					strErrMsg = coa.getErrMsg();
			}
			
			vRetResult = coa.operateOnSubAccountSetup(dbOP, request, 4);
			if(vRetResult == null && WI.fillTextValue("remove_coa").length() == 0)
				strErrMsg = coa.getErrMsg();
		}
	}
%>
<body bgcolor="#D2AE72" onUnload="CloseProcessing();">
<form action="./move_coa.jsp" method="post" name="form_">
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
					<strong><%=(String)vParentInfo.elementAt(2)%></strong>
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
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
  	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder"><div align="center">
				<strong>::: LIST OF LEVEL <%=WI.fillTextValue("parent_level")%> SUB-ACCOUNTS :::</strong></div></td>
	 	</tr>
		<tr>
			<td height="25" width="35%" align="center" class="thinborder"><strong>Account Name</strong></td>
			<td width="24%" align="center" class="thinborder"><strong>Account Type</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Account Order</strong></td>
			<td width="14%" align="center" class="thinborder"><strong>Sub-Accounts</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 16){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%><br>(<%=(String)vRetResult.elementAt(i+3)%>)</td>
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
				<%if(((String)vRetResult.elementAt(i+7)).equals("0") && (Integer.parseInt(strSALevels) > Integer.parseInt(strParentLevel))){%>
					<a href="javascript:UpdateSubAccounts('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../../images/view.gif" border="0"></a>
				<%}else{%>&nbsp;
				<%}%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+15);
			%>
			<td align="center" class="thinborder">
				<a href="javascript:Delete('<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../../images/delete.gif" border="0"></a></td>
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
	
	<input type="hidden" name="parent_level" value="<%=strParentLevel%>">
	<input type="hidden" name="parent_index" value="<%=strParentIndex%>">
	<input type="hidden" name="has_CC" value="<%=strHasCC%>">
	<input type="hidden" name="is_reloaded">
	<input type="hidden" name="coa_index">
	<input type="hidden" name="remove_coa">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
