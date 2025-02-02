<%@ page language="java" import="utility.*, java.util.Vector, hr.PersonnelAssetManagement" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"/>
<title>Search Help</title>
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
<script src="../../../jscript/common.js"></script>
<script src="../../../Ajax/ajax.js"></script>

<script language="javascript">

	function SearchCollection() {
		document.form_.searchCollection.value = "1";
		document.form_.submit();
	}
	
	function checkAllSave() {
		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSave.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function CancelOperation(){
		document.form_.searchCollection.value = "";
		document.form_.submit();
	}
	
	function UpdateItemStatus(){
		document.form_.page_action.value = "2";
		document.form_.submit()
	}
	
</script>

<body bgcolor="#D2AE72" onLoad="document.form_.asset_code.focus();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	
	//authenticate user here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL ASSET MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{		
		request.getSession(false).setAttribute("go_home","../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
			"Admin/staff-System Administration-Help Management-Search Help","update_item_status.jsp");
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
	
	Vector vRetResult = null;	
	String strModuleIndex = null;
	String strSubModuleIndex = null;

	String[] astrDropListEqual = {"Any Keywords","All Keywords","Equal to"};
	String[] astrDropListValEqual = {"any","all","equals"};
	String[] astrSortByName    = {"Asset Code","Property No.","Serial No."};
	String[] astrSortByVal     = {"asset_code","property_no","serial_no"};
	
	int i = 0;
	int iSearchResult = 0;
	
	PersonnelAssetManagement pam = new PersonnelAssetManagement();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(pam.operateOnUpdateItemStatus(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = pam.getErrMsg();
		} else {
			if(strTemp.equals("2"))
				strErrMsg = "Item status successfully updated.";		
		}
	}	
	
	if(WI.fillTextValue("searchCollection").equals("1")){
		vRetResult = pam.operateOnUpdateItemStatus(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = pam.getErrMsg();
		else	
			iSearchResult = pam.getSearchCount();
	}
%>
<form name="form_" method="post" action="update_item_status.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic">
			<div align="center"><font color="#FFFFFF"><strong>:::: UPDATE ITEM STATUS PAGE ::::</strong></font></div></td>
	</tr>
	<tr>
	  <td width="3%" align="right"><a href="pam_main.jsp"></a></td>
      <td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
      <td width="17%" align="right"><a href="pam_main.jsp"><img src="../../../images/go_back.gif" border="0"></a></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td width="16%">Status</td>
		<td colspan="2">
			<select name="item_status">
				<option value="">ALL</option>
			
			<%if (WI.fillTextValue("item_status").equals("0")){%>
				<option value="0" selected>Issued</option>
			<%}else{%>
				<option value="0">Issued</option>
				
			<%}if (WI.fillTextValue("item_status").equals("1")){%>
				<option value="1" selected>Available</option>
			<%}else{%>
				<option value="1">Available</option>
			
			<%}if (WI.fillTextValue("item_status").equals("2")){%>
				<option value="2" selected>Damaged</option>
			<%}else{%>
				<option value="2">Damaged</option>
			
			<%}if (WI.fillTextValue("item_status").equals("3")){%>
				<option value="3" selected>Lost</option>
			<%}else{%>
				<option value="3">Lost</option>
			<%}%>
			</select>		</td>
	</tr>
	<tr>
      <td height="25">&nbsp;</td>
	  <td>Category:</td>
	  <td colspan="2">
	  	<select name="category">
        	<option value="">Select Category</option>
        	<%=dbOP.loadCombo("pam_catg","category_name"," from hr_pam_item_catg order by category_name",WI.fillTextValue("category"),false)%>
      	</select></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
	  <td>Classification:</td>
	  <td colspan="2">
	  	<select name="classification">
        	<option value="">Select Classification</option>
        	<%=dbOP.loadCombo("pam_classification","classification"," from hr_pam_item_classification "+
				"order by classification",WI.fillTextValue("classification"),false)%>
      	</select></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
	  <td>Asset Code: </td>
	  <td colspan="2"><select name="asset_code_con" style="font-size:11px;">
          <%=pam.constructGenericDropList(WI.fillTextValue("asset_code_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
          <input type="text" name="asset_code" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("asset_code")%>"></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
	  <td width="16%">Property Number:</td>
	  <td colspan="2">
	  	<select name="property_num_con" style="font-size:11px;">
          <%=pam.constructGenericDropList(WI.fillTextValue("property_num_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
      <input type="text" name="property_num" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("property_num")%>"></td>
    </tr>
	<tr>
      <td height="25">&nbsp;</td>
	  <td>Serial Num: </td>
	  <td colspan="2">
	  	<select name="serial_num_con" style="font-size:11px;">
          <%=pam.constructGenericDropList(WI.fillTextValue("serial_num_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
      <input type="text" name="serial_num" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("serial_num")%>"></td>
    </tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Product  Num: </td>
		<td colspan="2">
			<select name="product_num_con" style="font-size:11px;">
				<%=pam.constructGenericDropList(WI.fillTextValue("product_num_con"),astrDropListEqual,astrDropListValEqual)%> 
			</select>
			<input type="text" name="product_num" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" size="32" maxlength="64" value="<%=WI.fillTextValue("product_num")%>"></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Sort by: </td>
		<td colspan="2">
			<select name="sort_by1" style="font-size:11px;">
				<option value="">N/A</option>
				<%=pam.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by1_con" style="font-size:11px;">
				<option value="asc">Ascending</option>
				<%
					if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}
				%>
			</select>
			&nbsp;
			<select name="sort_by2" style="font-size:11px;">
				<option value="">N/A</option>
					<%=pam.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by2_con" style="font-size:11px;">
				<option value="asc">Ascending</option>
				<%
					if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}
				%>
			</select>
			&nbsp;
			<select name="sort_by3" style="font-size:11px;">
				<option value="">N/A</option>
					<%=pam.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by3_con" style="font-size:11px;">
				<option value="asc">Ascending</option>
				<%
					if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}
				%>
			</select>			</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="2">
			<input type="submit" name="Submit" value="Search" onClick="SearchCollection();" 
				style="font-size:14px; height:24px;border: 1px solid #FF0000; font-family:Verdana, Arial, Helvetica, sans-serif">
		</td>
	</tr>
	<tr>
		<td colspan="4">&nbsp;</td>
	</tr>
</table>

<%if(vRetResult!=null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="2" bgcolor="#B9B292" class="thinborderALL">
				<div align="center"><strong><font color="#FFFFFF">::: SEARCH RESULTS :::</font></strong></div></td>
		</tr>
		<tr bgcolor="#FFFFFF"> 
			<td width="72%" class="thinborderLEFT"><b> Total Results: <%=iSearchResult%> - Showing(<b><%=pam.getDisplayRange()%></b>)</b></td>
			<td width="28%" class="thinborderRIGHT" height="25"> &nbsp;
		<%
			int iPageCount = 1;
			iPageCount = iSearchResult/pam.defSearchSize;		
			if(iSearchResult % pam.defSearchSize > 0) 
				++iPageCount;
			strTemp = " - Showing("+pam.getDisplayRange()+")";
			
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="SearchCollection();">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
					}
				%>
				</select>
		<%}%></div>		</td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">

	<tr bgcolor="#FFFFFF" align="center" style="font-weight:bold">
		<td width="5%" height="28" class="thinborder">&nbsp;</td>
		<td width="10%" class="thinborder">Asset Code </td>
		<td width="10%" class="thinborder">Category</td>
		<td width="11%" class="thinborder">Classification</td>
		<td width="11%" class="thinborder">Property No.</td>
		<td width="11%" class="thinborder">Serial No.</td>
		<td width="11%" class="thinborder">Product No.</td>
		<td width="12%" class="thinborder">Status</td>
		<td width="12%" class="thinborder">Update Status</td>
		<td width="7%" class="thinborder"><font size="1"><strong>SELECT ALL<br></strong>
		      <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font></td>
	</tr>
	<%
		int iCount = 1;
		for(i=0;i<vRetResult.size(); i += 8,iCount++){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;");
			if(strTemp.equals("0"))
				strErrMsg = "Issued";
			else if (strTemp.equals("1"))
				strErrMsg = "Available";
			else if (strTemp.equals("2"))
				strErrMsg = "Damaged";
			else
				strErrMsg = "Lost";
	%>	  
	<tr bgcolor="#FFFFFF">
		<td height="25" class="thinborder"><%=iCount%></td>		
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%></td>
		<td class="thinborder"><%=strErrMsg%></td>
		<td class="thinborder" align="center">
			<%if(!strTemp.equals("0")){%>
				<select name="update_status_<%=iCount%>">
				<%if (WI.fillTextValue("update_status_"+iCount).equals("1")){%>
					<option value="1" selected>OK</option>
					<option value="2">Damaged</option>
					<option value="3">Lost</option>
				<%}else if (WI.fillTextValue("update_status_"+iCount).equals("2")){%>
					<option value="1">OK</option>
					<option value="2" selected>Damaged</option>
					<option value="3">Lost</option>
				<%}else if (WI.fillTextValue("update_status_"+iCount).equals("3")){%>
					<option value="1">OK</option>
					<option value="2">Damaged</option>
					<option value="3" selected>Lost</option>
				<%}else{%>
					<option value="1" selected>OK</option>
					<option value="2">Damaged</option>
					<option value="3">Lost</option>
				<%}%>
			  </select>	
			<%}else{%>
				&nbsp;
			<%}%>		</td>
		<td class="thinborder" align="center">
			<%if(!strTemp.equals("0")){%>
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" checked tabindex="-1">
			<%}else{%>
				&nbsp;
			<%}%>		</td>
	</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>">
	<tr bgcolor="#FFFFFF">
		<td height="10" colspan="10">&nbsp;</td>
	</tr>
	<tr bgcolor="#FFFFFF">
		<td height="25" colspan="10" align="center">
			<a href="javascript:UpdateItemStatus();"><img src="../../../images/update.gif" border="0"></a>
			<font size="1"> click to update item status</font>
			&nbsp;&nbsp;&nbsp;
			<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
			<font size="1"> click to cancel or go previous</font></td>
	</tr>
</table>
<%}//end of vRetResult%>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
		<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
	</tr>
	<tr> 
		<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
	</tr>
</table>

	<input type="hidden" name="searchCollection" value="<%=WI.fillTextValue("searchCollection")%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>