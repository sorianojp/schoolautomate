<%@ page language="java" import="utility.*, citbookstore.BookOrders, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	boolean bolIsCIT = strSchCode.startsWith("CIT");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Ordering</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry? "))
		return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strInfoIndex;
	document.form_.show_info.value='1';
	document.form_.submit();
}

function CancelProcess(){
	location = "./dist_center_item_request_setting.jsp";
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = '1';		
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function UpdateBookExpiration(){
	document.form_.page_action.value='1';
	document.form_.submit();
}
function deleteOrders() {
	document.form_.page_action.value = '1';
	document.form_.submit();
}
function GoBack(){
	location = "../book_magement_settings_main.jsp";
}

function EditRecord(){
	document.form_.page_action.value='2';
	document.form_.submit();
}

function RefreshPage(){
	document.form_.show_info.value='1'; 
	document.form_.prepareToEdit.value='';
	document.form_.submit();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-PROPERTY","expiration_setting.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
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
		if(iAccessLevel == 0){
			response.sendRedirect("../../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	
	strErrMsg = "";
	Vector vRetResult = new Vector();
	Vector vEditInfo = new Vector();
	
	BookManagement bm = new BookManagement();
	
	String strSQLQuery = null;
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(bm.operateOnDistRequest(dbOP, request, Integer.parseInt(strTemp))==null)
			strErrMsg = bm.getErrMsg();
		else{
				if(strTemp.equals("1"))
					strErrMsg = "Entry successfully added.";
				if(strTemp.equals("2"))
					strErrMsg = "Entry successfully edited.";
				if(strTemp.equals("0"))
					strErrMsg = "Entry successfully deleted.";
			}
		
		strPrepareToEdit = "0";
	}
	
	if(WI.fillTextValue("show_info").length() > 0){
		bm.defSearchSize = 0;
		vRetResult = bm.operateOnDistRequest(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = bm.getErrMsg();	
			
		//System.out.println(strErrMsg);
	}
	
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = bm.operateOnDistRequest(dbOP,request,3);
		if(vEditInfo == null)
			strErrMsg = bm.getErrMsg();
	}
	
	

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./dist_center_item_request_setting.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: DISTRIBUTION CENTER REQUEST ITEM MANAGEMENT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan=""><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a></td>
		</tr>
	</table>
	
	
	
	
	<table width="100%" border="0" bgcolor="#FFFFFF">
		<tr>
			<td width="3%">&nbsp;</td>
			<td width="17%">DISTRIBUTION CENTER :</td>
			<%
				strTemp = WI.fillTextValue("loc_index");
				if(vEditInfo.size() > 0 && vEditInfo != null)
					strTemp = (String)vEditInfo.elementAt(2);				
			%>
			<td>
				<select name="loc_index" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 13;"				
				 onchange="document.form_.show_info.value='1'; document.form_.prepareToEdit.value=''; document.form_.submit();">
				<%=dbOP.loadCombo("DIST_LOC_INDEX","DIST_LOC_NAME"," from BS_BOOK_DIST_LOC order by DIST_LOC_NAME", strTemp,false)%> </select>
			</td>
		</tr>
		
		<tr>
			<td width="3%">&nbsp;</td>
			<td width="17%">BOOOK/ITEM TYPE :</td>
			<%
				strTemp = WI.fillTextValue("book_type");
				if(vEditInfo.size() > 0 && vEditInfo != null)
					strTemp = (String)vEditInfo.elementAt(1);
					
				//String strTemp2 = null;
				//if(strPrepareToEdit.equals("1"))
				//	strTemp2 = "document.form_.show_info.value='1';document.form_.prepareToEdit.value='1'; document.form_.submit();";
				//else
				//	strTemp2 = "document.form_.show_info.value='1';document.form_.submit();";
				// onchange="document.form_.show_info.value='1'; document.form_.submit();"

			%>
			<td>
				<select name="book_type">
                  <option value="">Select Book Type</option>
                  <%=dbOP.loadCombo("type_index","type_name", " from bs_book_type where is_valid = 1 order by type_name ",strTemp, false)%>
                </select>
			</td>
		</tr>
		<tr><td colspan="3" height="15">&nbsp;</td></tr>
		<tr>
			<td width="3%">&nbsp;</td>
			<td colspan="3">
			<% if (strPrepareToEdit.compareTo("1") == 0){%>
				<a href="javascript:EditRecord();">
				<img src="../../../images/edit.gif" border="0" /></a>
				<font size="1">Click to save</font>
				
				<a href="javascript:CancelProcess();">
				<img src="../../../images/cancel.gif"  border="0"></a>
				<font size="1">Click to cancel</font>
				
			<%}else{%>
				<a href="javascript:PageAction('1','');">
				<img src="../../../images/save.gif"  border="0"></a>
				<font size="1">Click to add entry</font>
				
				<a href="javascript:RefreshPage();">
				<img src="../../../images/refresh.gif"  border="0"></a>
				<font size="1">Click to refresh page</font>
			<%}%>
			</td>
		</tr>
		
	</table>  
    
    
<%if(vRetResult!=null && WI.fillTextValue("show_info").length() > 0){%>
    
    <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" bgcolor="#666666"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF ENTRY TO REQUEST </font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="9%"><font size="1">&nbsp;</font></td>
      <td width="72%"><font size="1"><strong>NAME</strong></font></td>
      <td width="8%"><font size="1"><strong>EDIT</strong></font></td>
      <td width="11%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=6){ %>
    <tr> 
      <td>&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>	  
      <td><div align="center"> 
          <% if (iAccessLevel > 1) {%>
          <input type="image" src="../../../images/edit.gif" onClick="PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td><%if(iAccessLevel==2){%> <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"> 
        <img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%>
        N/A
        <%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<%}%>  	

	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action"/>
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>"  />
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
	<input type="hidden" name="show_info"  value="<%=WI.fillTextValue("show_info")%>"/>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
