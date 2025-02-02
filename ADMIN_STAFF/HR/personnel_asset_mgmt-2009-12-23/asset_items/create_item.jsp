<%@ page language="java" import="utility.*, hr.PersonnelAssetManagement, java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script src="../../jscript/common.js"></script>
<script language="javascript">
function CancelRecord(){
	location ="./create_item.jsp";
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, 
					strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond) + 
	"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"viewList",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function LogItem(strMasteItemIndex){
	var pgLoc = "./pam_item_registry.jsp?opner_form_name=form_&forwarded=1&item_master_index="+strMasteItemIndex;
	var win=window.open(pgLoc,"LogItem",'width=1000,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function UpdateBrands(){
	var pgLoc = "./asset_brand.jsp?opner_form_name=form_";	
	var win=window.open(pgLoc,"UpdateBrands",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}

function UpdateCategories(){
	var pgLoc = "./asset_category.jsp?opner_form_name=form_";	
	var win=window.open(pgLoc,"UpdateCategories",'width=700,height=350,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function ReloadPage(){
	document.form_.change_value.value = "1";
	document.form_.print_page.value="";
	document.form_.submit();
}
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Are you sure you want to delete this item?'))
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
</script>
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
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Personnel Asset Management-Create Item","create_item.jsp");
	}
	catch(Exception exp)	{
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
	String strCatIndex = null;
	String strChangeValue = WI.fillTextValue("change_value");
	String strPrepareToEdit =  WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	PersonnelAssetManagement pam = new PersonnelAssetManagement();

	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(pam.operateOnMasterItem(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = pam.getErrMsg();
		} else {
			if(strPageAction.equals("0"))
				strErrMsg = " Master item removed successfully";
			if(strPageAction.equals("1"))
				strErrMsg = " Master item recorded successfully";
			if(strPageAction.equals("2"))
				strErrMsg = " Master item updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	vRetResult = pam.operateOnMasterItem(dbOP, request,4);
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = pam.operateOnMasterItem(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = pam.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./create_item.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic"> 
		<td height="25" colspan="4" align="center">
			<font color="#FFFFFF" ><strong>:::: PERSONNEL ASSET MANAGEMENT : ASSET REGISTRY PAGE ::::</strong></font></td>
	</tr>	
	
    <tr>
	    <td width="3%" height="15">&nbsp;</td>
        <td height="22"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
</table>

    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      
      <tr>
        <td width="3%" height="25">&nbsp;</td>
		<td width="17%">Category  : </td>
		<% 	
			if (vEditInfo != null) {
				if(strChangeValue.length() > 0)
					strTemp = WI.fillTextValue("category"); 
				else
					strTemp = (String)vEditInfo.elementAt(7);
			}
			else
				strTemp = WI.fillTextValue("category"); 
			strCatIndex = WI.getStrValue(strTemp, "0");			
		%>
        <td width="80%" height="25">
          <select name="category" onChange="ReloadPage();">
          	<option value="">Select Category</option>
          	<%=dbOP.loadCombo("pam_catg","category_name"," from hr_pam_item_catg order by category_name",strTemp,false)%>
          </select>
		  <a href="javascript:UpdateCategories();"><img src="../../../../images/update.gif" border="0"></a>		</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
		<td height="25">Classification    : </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(8);
			else
				strTemp = WI.fillTextValue("classification"); 
		%>
        <td height="25">
			<select name="classification">
          		<option value="">Select Classification</option>
          		<%=dbOP.loadCombo("pam_classification","classification"," from hr_pam_item_classification "+
					"order by classification",strTemp,false)%>
          	</select>
		<a href='javascript:viewList("hr_pam_item_classification","pam_classification",
				"classification","CLASSIFICATION","HR_PAM_ITEM_MASTER","ITEM_MASTER_INDEX", 
				" and HR_PAM_ITEM_MASTER.is_valid = 1","","classification")'>
		<img src="../../../../images/update.gif" border="0"></a>		</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
		<td height="25">Brand  : </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(9);
			else
				strTemp = WI.fillTextValue("brand"); 
		%>
        <td height="25">
          <select name="brand">
          	<option value="">Select Brand</option>
          	<%=dbOP.loadCombo("brand_index","brand_name"," from hr_pam_brand "+
				" where category_index = "+strCatIndex+
				" order by brand_name",strTemp,false)%>
          </select>
		<a href="javascript:UpdateBrands();"><img src="../../../../images/update.gif" border="0"></a>		</td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
		<td height="25">Description/Name    : </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(5);
			else
				strTemp = WI.fillTextValue("description"); 
		%>
        <td height="25">
          <input name="description" type="text" size="64" value="<%=strTemp%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="512">        </td>
      </tr>
      <tr>
        <td height="25">&nbsp;</td>
		<td height="25">Asset Unit   :</td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(10);
			else
				strTemp = WI.fillTextValue("asset_unit"); 
		%>
        <td height="25">
          <select name="asset_unit">
          	<option value="">Select Unit</option>
          	<%=dbOP.loadCombo("unit_index","unit_name"," from pur_preload_unit order by unit_name",strTemp,false)%>
          </select>
		  <a href='javascript:viewList("pur_preload_unit","unit_index","unit_name","UNIT","HR_PAM_ITEM_MASTER",
		  	"ITEM_MASTER_INDEX", " and HR_PAM_ITEM_MASTER.is_valid = 1","","asset_unit")'>
		  <img src="../../../../images/update.gif" border="0"></a>        </td>
      </tr>
      
      <tr>
        <td height="25">&nbsp;</td>
		<td height="25">Asset Code : </td>
		<% 	
			if (vEditInfo != null) 
				strTemp = (String)vEditInfo.elementAt(1);
			else
				strTemp = WI.fillTextValue("asset_code"); 
		%>
        <td>
			<input name="asset_code" type="text" size="32" value="<%=strTemp%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
      </tr>
      <tr>
        <td height="25" colspan="2">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="25" colspan="2">&nbsp;</td>
        <td height="25">
		<% if (iAccessLevel > 1){
			if (vEditInfo  == null){%>        
        		<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
				<a href='javascript:CancelRecord()'><img src="../../../../images/refresh.gif" border="0"></a>
        	<%}else{ %>        
				<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../../images/edit.gif" border="0"></a> 
       			<a href='javascript:CancelRecord()'><img src="../../../../images/cancel.gif" border="0"></a>
      		<%} // end else vEdit Info == null
		  } // end iAccessLevel  > 1%>          </td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
    </table>
    <%
if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
  <tr bgcolor="#B9B292">
    <td height="28" colspan="7" align="center" class="thinborder"><b>:: LIST OF ASSETS REGISTRY IN RECORD :: </b></td>
    </tr>
  <tr>
    <td width="11%" height="25" align="center" class="thinborder"><strong>ASSET CODE </strong></td>
    <td width="9%" align="center" class="thinborder"><strong>CATEGORY </strong></td>
    <td width="12%" align="center" class="thinborder"><strong>CLASSIFICATION</strong></td>
    <td width="10%" align="center" class="thinborder"><strong>BRAND</strong></td>
    <td width="20%" align="center" class="thinborder"><strong>DESCRIPTION/NAME</strong></td>
    <td width="6%" align="center" class="thinborder"><strong>ASSET UNIT </strong></td>
    <td width="20%" align="center" class="thinborder"><strong>OPTIONS</strong></td>
  </tr>
<%for(int i =0; i < vRetResult.size(); i += 11){%>
  <tr>
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
    <td height="25" align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
    <td height="25" align="center" class="thinborder"><font size="3" color="#666633">
	<%if(iAccessLevel > 1){%>
		<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/edit.gif" border="0"></a> 
		<%if(iAccessLevel == 2){%>
		<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../../images/delete.gif" border="0"></a> 
		<%}
	}%>	
	<input name="log_item" type="button" style="font-size:11px; height:18px;border: 1px solid #FF0000;" 
		value="LOG" onClick="javascript:LogItem('<%=(String)vRetResult.elementAt(i)%>');">
	</td>
  </tr>
  
<%}%>
</table>
<%}//if vRetResult is not null%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" colspan="2">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A" class="footerDynamic"> 
	<td width="1%" height="25">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page">
<input type="hidden" name="change_value">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
