<%@ page language="java" import="utility.*,Accounting.Budget,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Setup Budget</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function CancelOperation(){
		location = "./budget_setup.jsp";
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
	function FocusField(){
		document.form_.expense_name.focus();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this budget setup?'))
				return;
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
	
	function AddToList() {
		var strNewCOA  = document.form_.coa_search.value;
		if(strNewCOA.length == 0) 
			return;
			
		var strCOAList = document.form_.coa_list.value;
		if(strCOAList.length == 0) 
			strCOAList = strNewCOA;
		else if(strCOAList.indexOf(strNewCOA) > -1)
			return;
		else 	
			strCOAList += ","+strNewCOA;
		
		document.form_.coa_list.value = strCOAList;
	}
	
	var objCOA;
	function MapCOAAjax() {
		objCOA=document.getElementById("coa_info");
			
		var objCOAInput = document.form_.coa_search;
		if(objCOAInput.value.length == 1)
			return;
			
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name=coa_search";
		this.processRequest(strURL);
	}
	
	function COASelected(strAccountName, objParticular) {
		
		objCOA.innerHTML = "";
	}
	///use ajax to update voucher date and voucher number.
	function UpdateInfo(strIndex) {
		//do nothing..
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
	}
	
	function loadSearchDept() {
		var objCOA=document.getElementById("load_search_dept");
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=search_dept&all=1";
		this.processRequest(strURL);
	}
	
	function UpdateCategories(){
		var pgLoc = "./budget_categories.jsp?opner_form_name=form_";	
		var win=window.open(pgLoc,"UpdateCategories",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BUDGET"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
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
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ACCOUNTING-BUDGET","budget_setup.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	String strCollegeIndex = WI.fillTextValue("c_index");
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"");	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vTemp = null;
	int iSearchResult = 0;
	
	Budget budget = new Budget();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(budget.operateOnBudgetSetup(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = budget.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Budget setup successfully removed.";
			if(strTemp.equals("1"))
				strErrMsg = "Budget setup successfully recorded.";
			if(strTemp.equals("2"))
				strErrMsg = "Budget setup successfully edited.";
			
			strPrepareToEdit = "";
		}
	}
	
	vRetResult = budget.operateOnBudgetSetup(dbOP,request,4);
	if(vRetResult == null)
		strErrMsg = budget.getErrMsg();
	else
		iSearchResult = budget.getSearchCount();
	
	if(strPrepareToEdit.length() > 0){
		vEditInfo = budget.operateOnBudgetSetup(dbOP,request,3);
		if(vEditInfo == null)
			strErrMsg = budget.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="FocusField();">
<form name="form_" action="./budget_setup.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SETUP BUDGET ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Expense Name: </td>
			<td width="77%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("expense_name");
				%>
				<input type="text" name="expense_name" value="<%=strTemp%>" class="textbox" size="48" maxlength="256"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Category: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("catg_index");
						
					strErrMsg = " from ac_budget_setup_catg where is_valid = 1 order by catg_name ";
				%>
				<select name="catg_index">
          			<option value="">Select Category</option>
          			<%=dbOP.loadCombo("catg_index","catg_name", strErrMsg, strTemp,false)%> 
        		</select>
				&nbsp;
				<a href="javascript:UpdateCategories();"><img src="../../../images/update.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Budget:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("amount");
						
					strTemp = CommonUtil.formatFloat(strTemp, false);
					strTemp = ConversionTable.replaceString(strTemp, ",", "");
					if(strTemp.equals("0"))
						strTemp = "";
				%>
				<input type="text" name="amount" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('form_','amount');style.backgroundColor='white'" value="<%=strTemp%>"
					onkeyup="AllowOnlyFloat('form_','amount')" size="15" maxlength="15" /></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strCollegeIndex = WI.getStrValue((String)vEditInfo.elementAt(3));
					else
						strCollegeIndex = WI.fillTextValue("c_index");
				%>
				<select name="c_index" onChange="loadDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        		</select></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department: </td>
			<td colspan="2">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
					else
						strTemp = WI.fillTextValue("d_index");
				%>
				<label id="load_dept">
				<select name="d_index">
         			<option value="">ALL</option>
          		<%if ((strCollegeIndex.length() == 0) || strCollegeIndex.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp, false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp, false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Charge to Accounts: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(8);
						strTemp = strTemp.substring(1, strTemp.length()-1);
					}
					else
						strTemp = WI.fillTextValue("coa_list");
				%>
				<textarea name="coa_list" style="font-size:12px" cols="65" rows="6" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Chart of Account Search </td>
			<td>
				<input type="text" name="coa_search" class="textbox" size="16"
	  				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  				onkeyUP="MapCOAAjax();">&nbsp;&nbsp;&nbsp;
				<a href="javascript:AddToList();">Add to List</a>&nbsp;&nbsp;&nbsp;
				<label id="coa_info" style="font-size:11px;position:absolute;width:300px"></label></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Remark</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
					else
						strTemp = WI.fillTextValue("remarks");
				%>
				<textarea name="remarks" style="font-size:12px" cols="65" rows="6" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){
				if(vEditInfo != null && vEditInfo.size() > 0){%>
					<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<font size="1">click to edit budget setup. </font>&nbsp; 
				    <%}else{%>
					<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">click to save budget setup. </font>&nbsp;			
				    <%}%>
				
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
				<font size="1">click to cancel/clear fields </font>
			    <%}else{%>
				Not authorized to add/edit budget setup.
			    <%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" colspan="3"><strong><u>VIEW OPTIONS: </u></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Category: </td>
		    <td>
				<select name="search_catg">
          			<option value="">All Categories</option>
          			<%=dbOP.loadCombo("catg_index","catg_name", " from ac_budget_setup_catg where is_valid = 1 order by catg_name ", WI.fillTextValue("search_catg"),false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
		    <td width="20%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
		    <td width="77%">
				<%
					String strCollegeCon = WI.fillTextValue("search_college");
				%>
				<select name="search_college" onChange="loadSearchDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeCon,false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Department: </td>
		    <td>
				<label id="load_search_dept">
				<select name="search_dept">
         			<option value="">ALL</option>
          		<%if ((strCollegeIndex.length() == 0) || strCollegeIndex.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp = WI.fillTextValue("search_dept"), false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon , strTemp = WI.fillTextValue("search_dept"), false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td valign="middle">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to implement search options</font></td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: BUDGET SETUP LISTING :::  </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - 
					Showing(<strong><%=WI.getStrValue(budget.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3">&nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/budget.defSearchSize;		
				if(iSearchResult % budget.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+budget.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Expense Name </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Budget</strong></td>
			<td width="8%"  align="center" class="thinborder"><strong>College</strong></td>
			<td width="8%"  align="center" class="thinborder"><strong>Dept.</strong></td>
			<td width="12%"  align="center" class="thinborder"><strong>Category</strong></td>
			<td width="22%" align="center" class="thinborder"><strong>Chart of Accounts </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+5), true)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "N/A")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "ALL")%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
			<td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
				<img src="../../../images/edit.gif" border="0"></a>
				<%if(iAccessLevel == 2){%>
					<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
					<img src="../../../images/delete.gif" border="0"></a>
				<%}
			}else{%>
				Not authorized.
			<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" >&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
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