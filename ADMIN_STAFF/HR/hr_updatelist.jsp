<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/td.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function FocusID() {
	document.staff_profile.strValue.select();
	document.staff_profile.strValue.focus();	
}
function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value=index;
	document.staff_profile.donot_call_close_wnd.value = "1";
}

function ViewInfo(){
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}
function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.donot_call_close_wnd.value = "1";
}

function EditRecord(){
	document.staff_profile.page_action.value="2";
	document.staff_profile.donot_call_close_wnd.value = "1";
}
function DeleteRecord(strInfoIndex){
var vProceed = confirm("Confirm Delete of " + document.staff_profile.label.value);
	if(vProceed){
		document.staff_profile.page_action.value="0";
		document.staff_profile.info_index.value =strInfoIndex;
		document.staff_profile.donot_call_close_wnd.value = "1";
		this.SubmitOnce("staff_profile");
	}
}
function ReloadPage(){
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
	document.staff_profile.donot_call_close_wnd.value = "1";
}

function CancelEdit(tablename,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
	document.staff_profile.donot_call_close_wnd.value = "1";
	location = "./hr_updatelist.jsp?tablename=" + tablename + "&indexname=" + indexname + 
	"&colname=" + colname + "&label=" + labelname+"&opner_form_name="+
	document.staff_profile.opner_form_name.value +"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond);
}

function CloseWindow(){
	document.staff_profile.close_wnd_called.value = "1";
if(document.staff_profile.opner_form_field_value.value.length > 0) {	
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.staff_profile.opner_form_field_value.value;
<% }%>	
}
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
if(document.staff_profile.opner_form_field_value.value.length > 0) {
	<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
			document.staff_profile.opner_form_field_value.value;
	<% }%>
}

	if(document.staff_profile.donot_call_close_wnd.value.length >0)
		return;

	if(document.staff_profile.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();

		window.opener.focus();
	}
}


</script>

<body bgcolor="#663300" onUnload="ReloadParentWnd();" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;

	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management - update list",
								"hr_updatelist.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;
//if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}
//}
	//System.out.println(iAccessLevel);
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}
	boolean noError = false;
	int iAction = 0;
	strTemp = WI.fillTextValue("page_action");
	
	boolean bolShowDel = true; //i have to set it to false if extra_cond = null
	
	Vector vRetEdit = null;
	String strLabel = WI.fillTextValue("label");
	String strTableName = WI.fillTextValue("tablename");
	String strColName = WI.fillTextValue("colname");
	String strIndexName = WI.fillTextValue("indexname");
	String strFieldValue = WI.fillTextValue("strValue");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strInfoIndex = WI.fillTextValue("info_index");	
	String strTableList = WI.fillTextValue("table_list");
	String strIndexNames = WI.fillTextValue("indexes");
	String strExtraTableCondition = WI.fillTextValue("extra_tbl_cond");
	String strExtraCond = WI.fillTextValue("extra_cond");
	if(WI.fillTextValue("hide_del").equals("1")) {
		bolShowDel   = false;
	}
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
<form action="./hr_updatelist.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%=strLabel%> RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%><a href="javascript:CloseWindow();">
	  <img src="../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
<% if (vRetEdit!=null && vRetEdit.size() > 0) strTemp = (String) vRetEdit.elementAt(1);
   else strTemp = WI.fillTextValue("strValue"); 

strErrMsg = WI.getStrValue(WI.fillTextValue("max_len"), "64");
%>
      <td colspan="2" valign="top"><%=strLabel%>&nbsp;&nbsp; <textarea name="strValue" cols="40" rows="4" class="textbox"
	  onfocus="CharTicker('staff_profile','<%=strErrMsg%>','strValue','count_');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('staff_profile','<%=strErrMsg%>','strValue','count_');style.backgroundColor='white'" 
	  onkeyup="CharTicker('staff_profile','<%=strErrMsg%>','strValue','count_');"><%=strTemp%></textarea>
        <br>
        Allowed Characters <input type="text" name="count_" class="textbox_noborder" readonly="yes" tabindex="-1">
		</td>
      <td width="1%"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="9%">&nbsp;</td>
      <td width="89%"> <% if (strPrepareToEdit.compareTo("1") == 0){%> <input name="image" type="image" onClick='EditRecord()' src="../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit("<%=strTableName%>",
		"<%=strIndexName%>","<%=strColName%>","<%=strLabel%>","<%=strTableList%>","<%=strIndexNames%>",
		"<%=strExtraTableCondition%>","<%=strExtraCond%>");'>
		
		<img src="../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> <%}else{%> <input name="image" type="image" onClick='AddRecord()' src="../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> <%}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp; </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
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
          <input type="image" src="../../images/edit.gif" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'>
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td><%if(iAccessLevel== 2 && strTableList != null && strTableList.length() > 0 && bolShowDel){%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"> 
        <img src="../../images/delete.gif" width="55" height="28" border="0"></a> 
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
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
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

  <input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>">
  <input type="hidden" name="opner_form_field" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_field"),"")%>">
  <input type="hidden" name="opner_form_field_value" value="<%=WI.getStrValue(strLastEntry,"")%>">
  
  <input type="hidden" name="hide_del" value="<%=WI.fillTextValue("hide_del")%>">
<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
<!-- this is very important - onUnload do not call close window -->

<input type="hidden" name="max_len" value="<%=WI.getStrValue(WI.fillTextValue("max_len"), "64")%>">
</form>
</body>
</html>

