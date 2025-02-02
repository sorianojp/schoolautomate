<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Asset Brand</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
</style>
</head>
<script src="../../../../jscript/common.js"></script>
<script language="javascript">
function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length > 0)
		return;

	if(document.form_.close_wnd_called.value == "0") 
		window.opener.ReloadPage();
}

function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.submit();
}

function ReloadPage(){
	document.form_.reloadPage.value="1";
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this brand?'))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strAction == '1') 
		document.form_.prepareToEdit.value='';
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function CancelRecord(){
	location ="./asset_brand.jsp";
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector, hr.PersonnelAssetManagement" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null; 
	
	//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/fatal_error.jsp");

	//end of authenticaion code.

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),"Admin/staff-HR-Personnel Asset Management-Asset Brand","asset_brand.jsp");
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
	Vector vEditInfo = null;
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	PersonnelAssetManagement pam = new PersonnelAssetManagement();

	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(pam.operateOnAssetBrand(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = pam.getErrMsg();

		} else {
			if(strPageAction.equals("0"))
				strErrMsg = " Asset Brand removed successfully";
			if(strPageAction.equals("1"))
				strErrMsg = " Asset Brand recorded successfully";
			if(strPageAction.equals("2"))
				strErrMsg = " Asset Brand updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	vRetResult = pam.operateOnAssetBrand(dbOP, request, 4);
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = pam.operateOnAssetBrand(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = pam.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="document.form_.brand_name.focus()" onUnload="ReloadParentWnd();">
<form action="./asset_brand.jsp" method="post" name="form_">
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center">
				<font color="#FFFFFF" ><strong>:::: PERSONNEL ASSET MANAGEMENT: BRAND REGISTRY PAGE ::::</strong></font>			</td>
		</tr>
		<tr>
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
	</table>

    <table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="20%">&nbsp;</td>
        <td width="80%"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
      </tr>
	  <tr>
        <td width="20%">&nbsp;</td>
        <td width="80%">&nbsp;</td>
      </tr>
      <tr>
        <td height="25">Brand Name: </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(1);
			else
				strTemp = WI.fillTextValue("brand_name"); 
		%>
        <td>
			<input name="brand_name" type="text" size="30" value="<%=strTemp%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="16">
		</td>
      </tr>
      <tr>
        <td height="25">Category: </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(3);
			else
				strTemp = WI.fillTextValue("category"); 
		%>		
        <td>
			<select name="category">
          		<option value="">Select Category</option>
          		<%=dbOP.loadCombo("pam_catg","category_name"," from hr_pam_item_catg order by category_name",strTemp,false)%>
          	</select>
		</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
        <td>
        <% if (iAccessLevel > 1){
			if (vEditInfo  == null){%>        
        		<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
        		<font size="1">click to save entry </font> 
				<a href='javascript:CancelRecord()'><img src="../../../../images/refresh.gif" border="0"></a><font size="1">&nbsp;</font>
        	<%}else{ %>        
				<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../../images/edit.gif" border="0"></a> 
       			<font size="1">click to save changes</font><a href='javascript:CancelRecord()'><img src="../../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel and clear entries</font> 
      <%} // end else vEdit Info == null
		  } // end iAccessLevel  > 1%>  
		</td>
      </tr> 
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
      <tr>
        <td colspan="2">&nbsp;</td>
      </tr>
    </table>
 <%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  		<tr bgcolor="#B9B292">
    		<td height="28" colspan="4" align="center" class="thinborder"><b>:: LIST OF ASSETS CATEGORIES IN RECORD :: </b></td>
    	</tr>
  		<tr>
    		<td width="40%" height="25" align="center" class="thinborder"><strong>BRAND NAME </strong></td>
    		<td width="40%" align="center" class="thinborder"><strong>CATEGORY</strong></td>
    	    <td width="20%" align="center" class="thinborder" colspan="2"><strong>OPTIONS</strong></td>
  		</tr>
	<%for(int i =0; i < vRetResult.size(); i += 4){%>
  	<tr>
    <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%>&nbsp;</td>
    <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
    <td align="center" class="thinborder">
		<%  if (iAccessLevel > 1){%>
		  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" width="40" height="26" border="0"></a>
		<%}else{%> 
			N/A 
		<%}%>      
	</td>
    <td height="25" align="center" class="thinborder">
	<%  if ( iAccessLevel == 2) {%> 
		<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif"  border="0"></a> 
        <%}else{%> NA <%}%> </td>
    </td>
  </tr>
<%}%>
</table>
<%}//if vRetResult is not null%>

<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="1" height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#0D3371">
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
<input type="hidden" name="close_wnd_called" value="0">
<input type="hidden" name="donot_call_close_wnd">
<input type="hidden" name="reloadPage" value="0">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
