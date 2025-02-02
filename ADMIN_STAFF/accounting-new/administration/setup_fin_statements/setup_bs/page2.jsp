<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}
function PreparedToEdit(strIndex) {
	document.form_.info_index.value = strIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}

///for searching COA
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name=coa_search";
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	objCOA.innerHTML = "End of Processing..";
}
///use ajax to update voucher date and voucher number.
function UpdateInfo(strIndex) {
	//do nothing..
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
</script>
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Set up balance sheet-Page2","page2.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Accounting","Administration",request.getRemoteAddr(), 
														"page2.jsp");	
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

//end of authenticaion code.
	
	Administration admin = new Administration();	
	Vector vRetResult        = null;
	Vector vEditInfo         = null;
	String strSQLQuery       = null;
	java.sql.ResultSet rs    = null;
	
	String strBSMainIndex = WI.fillTextValue("bs_main_ref");
	String strCOACF       = WI.fillTextValue("coa_cf");
	String strSGIndex     = WI.fillTextValue("sg_ref");
	String strSGName      = null;
	if(strCOACF.length() == 0) {
		strSQLQuery = "select ac_set_bs_main.COA_CF,SG_INDEX,CF_NAME,sg_name from AC_SET_BS_MAIN "+
					"join AC_COA_CF on (AC_COA_CF.coa_cf = ac_set_bs_main.coa_cf) "+
					"join AC_SET_BS_SUB_PRELOAD on (SG_PRELOAD_INDEX = sg_index) "+
					"where BS_MAIN_INDEX="+
						strBSMainIndex;
		rs = dbOP.executeQuery(strSQLQuery);
		if(rs.next()){
			strCOACF   = rs.getString(1);
			strSGIndex = rs.getString(2);
			
			strSGName = rs.getString(3) + " ::: "+ rs.getString(4);
		}
		rs.close();
	}
	strSGName = WI.getStrValue(strSGName,WI.fillTextValue("sg_name"));
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(admin.operateOnBalanceSheetPage2(dbOP, request, strBSMainIndex, Integer.parseInt(strTemp)) == null)
			strErrMsg = admin.getErrMsg();
		else {
			strErrMsg = "Balance Sheet set up infomration updated successfully.";	
			strPreparedToEdit = "0";
		}
	}
	vRetResult = admin.operateOnBalanceSheetPage2(dbOP, request, strBSMainIndex, 4);
	if(strPreparedToEdit.equals("1"))
		vEditInfo = admin.operateOnBalanceSheetPage2(dbOP, request, strBSMainIndex, 3);
%>
<form name="form_" method="post" action="page2.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0">
    <tr> 
      <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2"><strong><%=strSGName%></strong></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="20%" style="font-size:10px;">Sub-Group Items</td>
      <td width="78%"> 
        <select name="bs_sub_ref">
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("bs_sub_ref");
%>
<%=dbOP.loadCombo("BS_MAIN_INDEX","SG_ITEM_NAME"," FROM AC_SET_BS_MAIN where COA_CF="+strCOACF+" and SG_INDEX="+strSGIndex+" and is_valid =1 order by SG_ITEM_ORDER", strTemp, false)%>
        </select>		</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td style="font-size:10px;">Item name  in Balance Sheet</td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("item_name");
%>
	  <input type="text" name="item_name" class="textbox" value="<%=WI.getStrValue(strTemp)%>"  maxlength="96" size="32"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td style="font-size:10px;">General Operation</td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("is_add");

if(strTemp.equals("1") || strTemp.length() == 0) {
	strErrMsg = "";
	strTemp = " checked";
}else {	
	strTemp = "";
	strErrMsg = " checked";
}
%>
	  	<input type="radio" name="is_add" value="1"<%=strTemp%>> ADD &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  	<input type="radio" name="is_add" value="0"<%=strErrMsg%>>SUBTRACT 
	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="top" style="font-size:10px;"><br>List of Chart of Account</td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("coa_list");
%>
	  <textarea name="coa_list" class="textbox" rows="5" cols="70"><%=strTemp%></textarea>
	  </td>
    </tr>
    <tr> 
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>
	  
  <table width="100%" border="0">
    <tr valign="top"> 
      <td width="2%">&nbsp;</td>
      <td width="20%" style="font-size:10px;">Chart of Account Quick Search</td>
      <td width="78%"><input type="text" name="coa_search" class="textbox" size="16"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onkeyUP="MapCOAAjax();">&nbsp;&nbsp;&nbsp;<a href="javascript:AddToList();">Add to List</a><br>
	  <label id="coa_info" style="font-size:11px;"></label>
	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <%if(iAccessLevel > 1 && strPreparedToEdit.equals("0")) {%>
        <input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
      <%}else if(iAccessLevel > 1){%>
        <input type="submit" name="1" value="Edit Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value=<%=vEditInfo.elementAt(0)%>">
		&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="submit" name="1" value="Cancel Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.date_taken.value='';document.form_.license_no.value='';document.form_.remarks.value=''">
	  <%}%>
	  </td>
    </tr>
    
    <tr> 
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>:: LIST OF ACCOUNTS FOR BALANCE SHEET :: </strong></font></div></td>
    </tr>
    <tr> 
      <td width="15%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">SUB-GROUP ITEM </td>
      <td width="25%" height="25" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">NAME TO APPEAR ON BALANCE SHEET</span></td>
      <td width="40%" align="center" style="font-size:9px; font-weight:bold" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">ACCOUNT #</span></td>
      <td width="5%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">OPERATION</td>
      <td width="7%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
      <td width="8%" align="center" style="font-size:9px; font-weight:bold" class="thinborder">&nbsp;</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 6){%>
    <tr> 
      <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" style="font-size:18px; font-weight:bold" align="center">
	  <%if(vRetResult.elementAt(i + 2).equals("1")){%>
	  +
	  <%}else{%>
	  -
	  <%}%>
	  </td>
      <td class="thinborder">
		<%if(iAccessLevel > 1){%>
		  	<a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');">Edit</a>
		<%}else{%>&nbsp;<%}%>
	   </td>
      <td class="thinborder">
		<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
		 <%}else{%>&nbsp;<%}%>
	  </td>
    </tr>
<%}%>
  </table>
<%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
  
  <!-- page information -->
  <input type="hidden" name="bs_main_ref" value="<%=strBSMainIndex%>">
  <input type="hidden" name="coa_cf" value="<%=strCOACF%>">
  <input type="hidden" name="sg_ref" value="<%=strSGIndex%>">
  <input type="hidden" name="sg_name" value="<%=strSGName%>">
  
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>