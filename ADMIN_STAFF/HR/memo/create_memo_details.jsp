<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Create Memo Details</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
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
<script language="JavaScript">

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
		if(!confirm('Are you sure you want to delete this memo?'))
			return;
	}
	document.form_.page_action.value = strAction;
	if(strAction == '1') {
		document.form_.prepareToEdit.value='';
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, 
					strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond) + 
	"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"viewList",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function CancelRecord(){
	location ="./create_memo_details.jsp";
}
function PrintMemo(strMemoRef) {
	var loadPg = "./memo_print.jsp?info_index="+strMemoRef;
	
	var win=window.open(loadPg,"Print Memo",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<% 
	String strErrMsg = null;
	String strTemp = null;

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-MEMO MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
			"Admin/staff-HR Management-Memo Management-Create Memo Details","create_memo_detailss.jsp");
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
	hr.HRMemoManagement  mt = new hr.HRMemoManagement();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(mt.operateOnMemoDetails(dbOP, request, Integer.parseInt(strTemp)) == null){
			strErrMsg = mt.getErrMsg();
		} else {
			if(strTemp.equals("0"))
				strErrMsg = " Memo Detail removed successfully";
			if(strTemp.equals("1"))
				strErrMsg = " Memo Detail recorded successfully";
			if(strTemp.equals("2"))
				strErrMsg = " Memo Detail updated successfully";
				
			strPrepareToEdit = "0";
		}
	}
	
	if(strPrepareToEdit.equals("1")) {
		vEditInfo = mt.operateOnMemoDetails(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = mt.getErrMsg();
	}
	vRetResult = mt.operateOnMemoDetails(dbOP, request,4);

	boolean bolReloadPage = WI.fillTextValue("reloadPage").equals("1");
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.memo_name.focus();">
<form action="./create_memo_details.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic" align="center"><font color="#FFFFFF" >
	  	<strong>::::   MEMO DETAILS FOR PERSONNEL ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="19%" height="30">TYPE OF MEMO </td>
<%	if (vEditInfo != null  && !bolReloadPage) 
		strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
	else 
		strTemp = WI.fillTextValue("memo_type_index");
	strErrMsg = " FROM hr_preload_memo_type order by MEMO_TYPE";
%>	  <td width="28%" height="30">
        <select name="memo_type_index" onChange="ReloadPage()">
          <option value="">Select Memo Type</option>
          <%=dbOP.loadCombo("memo_type_index", "memo_type", strErrMsg, strTemp, false)%>
        </select></td>
    <td width="49%">
<%if(iAccessLevel > 1){%>
		<a href='javascript:viewList("hr_preload_memo_type","memo_type_index",
			"memo_type","TYPE OF MEMO",	"hr_memo_details","memo_type_index", 
			" and hr_memo_details.is_del = 0","","memo_type_index")'><img src="../../../images/update.gif" border="0"></a>
		<font size="1">click to add to types of memo </font>
<%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%">&nbsp;</td>
      <td width="96%" height="36" valign="bottom">MEMO NAME </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
	<%
		if (vEditInfo != null && !bolReloadPage) 
			strTemp = (String)vEditInfo.elementAt(3);
		else
			strTemp = WI.fillTextValue("memo_name"); 
	%>
      <td height="23">
	  <input name="memo_name" type="text" class="textbox" value="<%=strTemp%>" 
	  	onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64"></td>
    </tr>
    <tr>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">MEMO CONTENT </td>
    </tr>
	<% 
		if (vEditInfo != null  && !bolReloadPage) 
			strTemp = (String)vEditInfo.elementAt(4);
		else
			strTemp = WI.fillTextValue("memo_content"); 
	%>
	
    <tr>
      <td>&nbsp;</td>
      <td height="23">
	  	<textarea name="memo_content" cols="64" rows="15" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
    </tr>
    <tr>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="96%" height="25"> 
        <% if (iAccessLevel > 1){
			if (vEditInfo  == null){%>        
        		<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        		<font size="1">click to save entry </font> 
				<a href='javascript:CancelRecord()'><img src="../../../images/refresh.gif" border="0"></a><font size="1"></font>
        	<%}else{ %>        
				<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a> 
       			<font size="1">click to save changes</font><a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel and clear entries</font> 
      <%} // end else vEdit Info == null
		  } // end iAccessLevel  > 1%> 
	  </td>
    </tr>
    <tr>
      <td height="22" colspan="2">&nbsp;</td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 1) { %>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBEEE0"> 
      <td height="25" colspan="4" align="center" class="thinborder">
	  	<strong>LIST OF MANDATORY MEMOS</strong></td>
    </tr>
    <tr> 
      <td width="80%" height="25" class="thinborder"><strong>NAME OF MEMO / CONTENT </strong></td>
      <td width="6%" class="thinborder"><strong>EDIT</strong></td>
      <td width="8%" class="thinborder"><strong>DELETE</strong></td>
      <td width="6%" class="thinborder"><strong>PRINT</strong></td>
    </tr>
    <% 
		String strCurrTypeIndex = "";
		for (int i=1 ; i < vRetResult.size(); i+=5){
		if (!strCurrTypeIndex.equals((String)vRetResult.elementAt(i+1))){
			strCurrTypeIndex = (String)vRetResult.elementAt(i+1);
	%>
    <tr>
      <td height="25" colspan="4" bgcolor="#FEF3E9" class="thinborder"><strong>&nbsp;&nbsp;TYPE OF MEMO : &nbsp;<font color="#FF0000"><%=(String)vRetResult.elementAt(i+4)%></font></strong> </td>
    </tr>
	<%}%> 
    <tr> 
      <td height="12" class="thinborderLEFT" bgcolor="#F3F3F3">
	  <%="Title :<strong>" + (String)vRetResult.elementAt(i+2) + "</strong>"%></td>
      <td rowspan="2" valign="top" class="thinborder">
<%  if (iAccessLevel > 1){%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
<%}else{%> N/A <%}%>      </td>
      <td rowspan="2" valign="top" class="thinborder"> 
<%  if ( iAccessLevel == 2) {%> 
		<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif"  border="0"></a> 
<%}else{%> NA <%}%> </td>
      <td rowspan="2" valign="top" class="thinborder">
		<a href="javascript:PrintMemo('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/print.gif"  border="0"></a> 
	  </td>
    </tr>
    <tr>
      <td height="13" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
    </tr>
    <%}%>
  </table>
<% } //vRetResult != null && vRetResult.size() > 0 %> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>  
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="reloadPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>