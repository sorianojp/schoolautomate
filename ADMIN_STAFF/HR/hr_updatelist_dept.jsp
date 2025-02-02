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
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value=index;
	document.staff_profile.donot_call_close_wnd.value = "1";
}

function ViewInfo(){
	document.staff_profile.page_action.value="3";
	document.staff_profile.donot_call_close_wnd.value = "1";
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
	location = "./hr_updatelist_dept.jsp?tablename=" + tablename + "&indexname=" + indexname + 
	"&colname=" + colname + "&label=" + labelname+"&opner_form_name="+
	document.staff_profile.opner_form_name.value +"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond);
}

function CloseWindow(){
	document.staff_profile.close_wnd_called.value = "1";
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.staff_profile.donot_call_close_wnd.value.length >0)
		return;

	if(document.staff_profile.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>.submit();
		window.opener.focus();
	}
}

function viewBLDGS(){
	var loadPg = "./hr_updatelist_bldg.jsp";
	
	var win=window.open(loadPg,"dept_main",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body bgcolor="#663300" onUnload="ReloadParentWnd();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management - update list",
								"hr_updatelist_dept.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(), 
														"hr_updatelist_dept.jsp");	
if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}

}
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

	HRManageList  hrList = new HRManageList();
	
	iAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
	
	switch(iAction){
	case 0:
	
		vRetResult = hrList.operateOnOffices(dbOP,request,0);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "Office record removed successfully.";
			noError = true;
		}
		break;
	case 1: 
		vRetResult = hrList.operateOnOffices(dbOP,request,1);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "Office record added successfully.";
			noError = true;
		}
		break;

	case 2:
		vRetResult = hrList.operateOnOffices(dbOP,request,2);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "Office record edited successfully";
			strPrepareToEdit = "0";
			noError = true;
		}
		break;
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnOffices(dbOP,request,3);	
		if (vRetEdit == null) 
			strErrMsg = hrList.getErrMsg();
	}
	
	vRetResult = hrList.operateOnOffices(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null) 
		strErrMsg = hrList.getErrMsg();
		

%>
<form action="./hr_updatelist_dept.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          OFFICES RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=3 color=#FF0000> <strong>","</strong></font>","")%><a href="javascript:CloseWindow();">
	  <img src="../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td width="16%">Location </td>
      <td width="83%" valign="top"> 
        <select name="bldg_index">
	  <option value=""></option>
<%	
	strTemp = WI.fillTextValue("bldg_index");
	if ( vRetEdit != null) 
		strTemp =  WI.getStrValue((String)vRetEdit.elementAt(4));
%>
	  <%=dbOP.loadCombo("BLDG_INDEX", "BLDG_NAME",
	  					" from E_ROOM_BLDG where is_del = 0 order by BLDG_NAME",strTemp,false)%>
	  </select>
        <a href='javascript:viewBLDGS()'>
				 <img src="../../images/update.gif" width="60" height="26" border="0"></a> 
        <font size="1">click to list location</font></td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td>Office Name&nbsp;</td>
      <td valign="top"> 
        <% if (vRetEdit!=null && vRetEdit.size() > 0) strTemp = (String) vRetEdit.elementAt(1);
   else strTemp = WI.fillTextValue("office"); 
%> <input name="office" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="40"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Office Code </td>
      <td> 
        <% if (vRetEdit!=null && vRetEdit.size() > 0) strTemp = WI.getStrValue((String)vRetEdit.elementAt(3));
   else strTemp = WI.fillTextValue("code"); 
%> <input name="code" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="20"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Office Head</td>
      <td> 
        <% if (vRetEdit!=null && vRetEdit.size() > 0) strTemp = WI.getStrValue((String) vRetEdit.elementAt(2));
   else strTemp = WI.fillTextValue("head"); 
%> <input name="head" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="40"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td> <% if (strPrepareToEdit.compareTo("1") == 0){%> <input name="image" type="image" onClick='EditRecord()' src="../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit("<%=strTableName%>",
		"<%=strIndexName%>","<%=strColName%>","<%=strLabel%>","<%=strTableList%>","<%=strIndexNames%>",
		"<%=strExtraTableCondition%>","<%=strExtraCond%>");'> <img src="../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> <%}else{%> <input name="image" type="image" onClick='AddRecord()' src="../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> <%}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>


 <% if (vRetResult !=null){ %>  
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td colspan="5" bgcolor="#666666" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF OFFICES</font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="10%" class="thinborder"><strong>OFFICE CODE</strong></td>
      <td width="43%" class="thinborder"><strong>OFFICE NAME </strong></td>
      <td width="30%" class="thinborder"><strong>HEAD OF OFFICE</strong></td>
      <td width="7%" class="thinborder"><strong>EDIT</strong></td>
      <td width="8%" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=5){ %>
    <tr> 
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></td>
      <td class="thinborder"><div align="center"> 
          <% if (iAccessLevel > 1) {%>
          <input type="image" src="../../images/edit.gif" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'
	  							width="40" height="26">
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td class="thinborder"><%if(iAccessLevel== 2 && strTableList != null && strTableList.length() > 0 ){%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"> 
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

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

