<%@ page language="java" import="utility.*,java.util.Vector,chedReport.ChedProgProfile" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED Reports</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.ched_form_.strValue.select();
	document.ched_form_.strValue.focus();	
}
function PrepareToEdit(index){
	document.ched_form_.prepareToEdit.value = "1";
	document.ched_form_.info_index.value=index;
	document.ched_form_.donot_call_close_wnd.value = "1";
}

function AddRecord(){
	document.ched_form_.page_action.value="1";
	document.ched_form_.donot_call_close_wnd.value = "1";
}

function EditRecord(){
	document.ched_form_.page_action.value="2";
	document.ched_form_.donot_call_close_wnd.value = "1";
}
function DeleteRecord(strInfoIndex){
var vProceed = confirm("Confirm Delete of " + document.ched_form_.label.value);
	if(vProceed){
		document.ched_form_.page_action.value="0";
		document.ched_form_.info_index.value =strInfoIndex;
		document.ched_form_.donot_call_close_wnd.value = "1";
		this.SubmitOnce("ched_form_");
	}
}
function ReloadPage(){
	document.ched_form_.reloadPage.value = "1";
	document.ched_form_.submit();
	document.ched_form_.donot_call_close_wnd.value = "1";
}

function CancelEdit(tablename,labelname){
	document.ched_form_.donot_call_close_wnd.value = "1";
	location = "./ched_updatelist.jsp?tablename=" + tablename +"&labelname=" + labelname+"&opner_form_name="+
	document.ched_form_.opner_form_name.value;
}

function CloseWindow(){
	document.ched_form_.close_wnd_called.value = "1";
	
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 	document.ched_form_.opner_form_field_value.value;
<% }%>	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"ched_form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"ched_form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.ched_form_.opner_form_field_value.value;
<% }%>

	if(document.ched_form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.ched_form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"ched_form_")%>.submit();

		window.opener.focus();
	}
}


</script>

<body bgcolor="#663300" onUnload="ReloadParentWnd();" onLoad="FocusID();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar-Ched Reports",
								"ched_updatelist.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}

	boolean noError = false;
	int iAction = 0;
	strTemp = WI.fillTextValue("page_action");
	
	Vector vRetEdit = null;
	String strLabel = WI.fillTextValue("label");
	String strTableName = WI.fillTextValue("tablename");
	String strFieldValue = WI.fillTextValue("strValue");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strInfoIndex = WI.fillTextValue("info_index");	
	String strLastEntry = WI.fillTextValue("opner_form_field_value");
	

	HRManageList  hrList = new HRManageList();
	
	iAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
	
	switch(iAction){
	case 0:
		if (!hrList.deleteFromListAllowed(dbOP,request)){
			strErrMsg = hrList.getErrMsg();
			break;
		}
	
		vRetResult = hrList.operateOnList(dbOP,0, strTableName,strColName,strFieldValue,strInfoIndex, strIndexName);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = strLabel + " removed successfully.";
			strLastEntry = "0";
			noError = true;
		}
		break;
	case 1: 
		vRetResult = hrList.operateOnList(dbOP,1,strTableName,strColName, strFieldValue,strInfoIndex, strIndexName);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = strLabel + " added successfully.";
			strLastEntry = (String)vRetResult.elementAt(0);
			noError = true;
		}
		break;

	case 2:
		vRetResult = hrList.operateOnList(dbOP,2, strTableName,strColName,strFieldValue,strInfoIndex, strIndexName);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = strLabel + " edited successfully";
			strPrepareToEdit = "0";
			strLastEntry = (String)vRetResult.elementAt(0);			
			noError = true;
		}
		break;
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnList(dbOP,3,strTableName,strColName,strFieldValue,strInfoIndex,strIndexName);	
	}
	
	vRetResult = hrList.operateOnList(dbOP,4,strTableName,strColName,strFieldValue,strExtraCond, null);

%>
<form action="./ched_updatelist.jsp" method="post" name="ched_form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%=strLabel%> RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%><a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td valign="top"><%=strLabel%>&nbsp;&nbsp; <input name="strValue" type="text" class="textbox" onFocus="CharTicker('ched_form_','64','strValue','count_');style.backgroundColor='#D3EBFF'" onBlur="CharTicker('ched_form_','64','strValue','count_');style.backgroundColor='white'" onKeyUp="CharTicker('ched_form_','64','strValue','count_');" value="<%=strTemp%>" size="64"> 
        <font size="1">Allowed Characters</font> <input name="count_" type="text" class="textbox_noborder" size="4" maxlength="4" readonly="yes"> 
      </td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <% if (vRetEdit!=null && vRetEdit.size() > 0) strTemp = (String) vRetEdit.elementAt(1);
		   else strTemp = WI.fillTextValue("strValue"); 
%>
      <td valign="top">CODE 
        <input name="code" type="text" class="textbox" size="8" maxlength="8"
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> <% if (strPrepareToEdit.compareTo("1") == 0){%> <input name="image" type="image" onClick='EditRecord()' src="../../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit("<%=strTableName%>","<%=strLabel%>");'> 
        <img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> <%}else{%> <input type="image" onClick='AddRecord()' src="../../../images/add.gif" border="0"> 
        <font size="1">click to add entry</font> <%}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>


 <% if (vRetResult !=null){ %>  
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" bgcolor="#666666"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF <%=strLabel%> </font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="9%"><font size="1">&nbsp;</font></td>
      <td width="72%"><font size="1"><strong>NAME</strong></font></td>
      <td width="8%"><font size="1"><strong>EDIT</strong></font></td>
      <td width="11%"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=2){ %>
    <tr> 
      <td>&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><div align="center"> 
          <% if (iAccessLevel > 1) {%>
          <input type="image" src="../../../images/edit.gif" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'
	  							width="40" height="26">
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td><%if(iAccessLevel== 2 && strTableList != null && strTableList.length() > 0 ){%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"> 
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
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
      </tr>
  </table>
  <input type="hidden" name="tablename" value="<%=strTableName%>">
  <input type="hidden" name="colname" value="<%=strColName%>">
  <input type="hidden" name="indexname" value="<%=strIndexName%>">
  <input type="hidden" name="label" value="<%=strLabel%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="extra_cond" value="<%=strExtraCond%>">
  <input type="hidden" name="table_list" value="<%=strTableList%>">
  <input type="hidden" name="indexes" value="<%=strIndexNames%>">
  <input type="hidden" name="extra_tbl_cond" value="<%=strExtraTableCondition%>">  

  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"ched_form_")%>">
  <input type="hidden" name="opner_form_field" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_field"),"")%>">
  <input type="hidden" name="opner_form_field_value" value="<%=strLastEntry%>">
  
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

