<%@ page language="java" import="utility.*, enrollment.DocRequestTracking, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">

</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="javascript">
	function Search(){
		document.form_.search_.value = '1';
		document.form_.submit();
	}		
	
	function DeleteDocument(strInfoIndex){
		document.form_.delete_remark.value = prompt("Remarks to Delete");		
		document.form_.request_index.value = strInfoIndex;		
		document.form_.page_action.value = "1";		
		document.form_.submit();
	}
	
	function ReleaseDocument(strInfoIndex){
		document.form_.release_remark.value = prompt("Remarks to Release");		
		document.form_.request_index.value = strInfoIndex;		
		document.form_.page_action.value = "2";		
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;	
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Document Request Tracking","search_request.jsp");		
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Document Request Tracking",request.getRemoteAddr(),
														"search_request.jsp");
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
	//end of authenticaion code.
	
	int iSearchResult = 0;
	
	DocRequestTracking docReq = new DocRequestTracking();
	Vector vRetResult = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(strTemp.equals("1")){
			if(!docReq.deleteRequestItems(dbOP,request))
				strErrMsg = docReq.getErrMsg();
			else
				strErrMsg = "Document Request successfully deleted.";
		}else{
			if(!docReq.releaseRequestItems(dbOP,request))
				strErrMsg = docReq.getErrMsg();
			else
				strErrMsg = "Document Request successfully released.";
		}
			
	}
	
	if(WI.fillTextValue("search_").length() > 0){
		vRetResult = docReq.searchRequest(dbOP, request);
		if(vRetResult == null)
			strErrMsg = docReq.getErrMsg();				
	}
	
	
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID Number ","Lastname","Firstname","Transaction No.","Request Date","Release Date"};
String[] astrSortByVal     = {"id_number","lname","fname","transaction_no","request_date","release_date"};
	


%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="search_request.jsp">
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#A49A6A">
      <td height="25" colspan="6" align="center"><font color="#FFFFFF"><strong>::::
        DOCUMENT REQUEST TRACKING ::::</strong></font></td>
    </tr>
</table>
<jsp:include page="./tabs.jsp?pgIndex=3"></jsp:include>

<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
	<td width="3%" height="25">&nbsp;</td>
	<td width="97%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
</tr>		
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">ID Number</td>
      <td colspan="5">
	  	<select name="id_number_con">
          <%=docReq.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%>
		</select>
		<input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td width="30%"><select name="lname_con">
          <%=docReq.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		  <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Firstname</td>
      <td>
	  	<select name="fname_con">
        	<%=docReq.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
      	</select>
      <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	<tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">Transaction No</td>
      <td colspan="5">
	  	<select name="transaction_no_con">
          <%=docReq.constructGenericDropList(WI.fillTextValue("transaction_no_con"),astrDropListEqual,astrDropListValEqual)%>
		</select>
		<input type="text" name="transaction_no" value="<%=WI.fillTextValue("transaction_no")%>" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	
	<tr> 
      <td height="25">&nbsp;</td>
      <td>Request Date</td>
      <td width="30%">
	  		<input type="text" name="request_date" readonly="yes" value="<%=WI.fillTextValue("request_date")%>" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10">
			<a href="javascript:show_calendar('form_.request_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a>
		</td>
      <td>Release Date</td>
      <td>
	  <input type="text" name="release_date" readonly="yes" value="<%=WI.fillTextValue("release_date")%>" class="textbox"
	  			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10">
		<a href="javascript:show_calendar('form_.release_date');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a>
	  </td>
    </tr>
	
	<tr><td colspan="5" height="10"></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Sort by: </td>
		<td width="20%">
			<select name="sort_by1">
				<option value="">N/A</option>
				<%=docReq.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
			</select></td>
		<td width="20%">
			<select name="sort_by2">
				<option value="">N/A</option>
				<%=docReq.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
			</select></td>
		<td width="40%">
			<select name="sort_by3">
				<option value="">N/A</option>
				<%=docReq.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
			</select></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td>
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
		<td>
			<select name="sort_by2_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
		<td>
			<select name="sort_by3_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
	</tr>
	
	<tr><td height="10" colspan="5"></td></tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td colspan="4">
			<a href="javascript:Search();"><img src="../../../images/form_proceed.gif" border="0" /></a>
		</td>
	</tr>
	<tr><td height="15" colspan="5">&nbsp;</td></tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<%
				strTemp = "REQUEST";
				if(WI.fillTextValue("show_in").equals("1"))
					strTemp = "DUE REQUEST";
			%>
		  	<td height="20" colspan="11" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>DOCUMENT REQUEST LIST</strong></div></td>
		</tr>	
			
		<tr>
			<td height="23" class="thinborder" width="5%"><strong>COUNT</strong></td>
			<td class="thinborder" width="8%"><strong>ID NUMBER</strong></td>
			<td class="thinborder" width="20%"><strong>STUDENT NAME</strong></td>
			<td class="thinborder" width="15%"><strong>DOCUMENT NAME</strong></td>
			<td class="thinborder" width="8%"><strong>REQUESTED</strong></td>
			<td class="thinborder" width="8%"><strong>RELEASE</strong></td>
			<td class="thinborder" ><strong>REQUIREMENTS</strong></td>
			<td class="thinborder" width="10%"><strong>REMARKS</strong></td>
			<td class="thinborder" align="center" width="12%"><strong>OPTION</strong></td>
		</tr>
	<%	int iCount = 1;
		String strReleased = null;
		String strDocRequirement = null;
		Vector vReqList = new Vector();
		for(int i = 0; i < vRetResult.size(); i += 9){
			strReleased = (String)vRetResult.elementAt(i+7);
			strDocRequirement = "";
			vReqList = (Vector)vRetResult.elementAt(i+8);
				if(vReqList.size() > 0) {
					for(int x = 0; x < vReqList.size(); x++){
						if((String)vReqList.elementAt(x) != null){
							if(strDocRequirement.length() == 0)
								strDocRequirement = (String)vReqList.elementAt(x)+";";
							else
								strDocRequirement += "<br>"+(String)vReqList.elementAt(x)+";";						
						}
						
					}
				}
		%>
		<tr>
			<td height="23" class="thinborder"><%=iCount++%>.</td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
			<td class="thinborder"><%=WI.getStrValue(strDocRequirement.toUpperCase(),"&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
			<td class="thinborder" align="center">
				<%if(strReleased.equals("1")){%>
					RELEASED
				<%}else{%>
				<a href="javascript:DeleteDocument('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>
				&nbsp;
				<a href="javascript:ReleaseDocument('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/release-02-55x18.gif" border="0"></a>
				<%}%>
			</td>
		</tr>
		<%}%>
	</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25" bgcolor="#FFFFFF">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>
	
	<input type="hidden" name="release_remark" value="<%=WI.fillTextValue("release_remark")%>"/>
	<input type="hidden" name="delete_remark" value="<%=WI.fillTextValue("delete_remark")%>"/>
	<input type="hidden" name="request_index" value="<%=WI.fillTextValue("request_index")%>"/>
	<input type="hidden" name="page_action" value="" />
	<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>