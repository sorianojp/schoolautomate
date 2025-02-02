<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../jscript/td.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value=index;
}

function ViewInfo()
{
	document.staff_profile.page_action.value="0";
}
function AddRecord()
{
	document.staff_profile.page_action.value="1";
}

function EditRecord()
{
	document.staff_profile.page_action.value="2";
}
function DeleteRecord()
{
	document.staff_profile.page_action.value="3";
}
function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.staff_profile.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.staff_profile.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		hideLayer(strTextBoxID);
		eval('document.staff_profile.'+strOthFieldName+'.disabled=true');
	}
}
function CancelEdit(tablename,indexname,colname,labelname){
	location = "./hr_updatelist.jsp?tablename=" + tablename + "&indexname=" + indexname + "&colname=" + colname + "&label=" + labelname;
}

function CloseWindow()
{
	window.opener.document.staff_profile.submit()
	window.opener.focus();
	self.close();
}
</script>

<body bgcolor="#663300">
<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;

	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-School Year Holidays",
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"holiday_records.jsp");	
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
	boolean noError = false;
	int iAction = 0;
	strTemp = WI.fillTextValue("page_action");
	
	Vector vRetEdit = new Vector();
	String strLabel = WI.fillTextValue("label");
	String strTableName = WI.fillTextValue("tablename");
	String strColName = WI.fillTextValue("colname");
	String strIndexName = WI.fillTextValue("indexname");
	String strFieldValue = WI.fillTextValue("strValue");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strInfoIndex = WI.fillTextValue("info_index");	
	
	HRManageList  hrList = new HRManageList();
	
	iAction = Integer.parseInt(WI.getStrValue(strTemp,"0"));

	switch(iAction){
	case 1: 
		vRetResult = hrList.operateOnList(dbOP,iAction,strTableName,strColName, strFieldValue,null, null);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = strLabel + " added successfully.";
			noError = true;
		}
		break;

	case 2:
		vRetResult = hrList.operateOnList(dbOP,iAction, strTableName,strColName,strFieldValue,strInfoIndex, strIndexName);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = strLabel + " edited successfully";
			strPrepareToEdit = "0";
			noError = true;
		}
		break;
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnList(dbOP,3,strTableName,strColName,strFieldValue,strInfoIndex,strIndexName);	
	}
	
	vRetResult = hrList.operateOnList(dbOP,4,strTableName,strColName,strFieldValue,null, null);

%>
<form action="./hr_updatelist.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          <%=strLabel%> RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"")%><a href="javascript:CloseWindow();"><img src="../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
      <% if (vRetEdit!=null && vRetEdit.size() > 0){
	strTemp = (String) vRetEdit.elementAt(1);
   }else{
   	strTemp = WI.fillTextValue("strValue");
   }
%>
      <td colspan="2" valign="middle"><%=strLabel%>&nbsp;&nbsp; 
        <textarea name="strValue" cols="32" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="85%"> 
        <% if (strPrepareToEdit.compareTo("1") == 0){%>
        <input name="image" type="image" onClick='EditRecord()' src="../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit("<%=strTableName%>","<%=strIndexName%>","<%=strColName%>","<%=strLabel%>");'><img src="../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> 
        <%}else{%>
        <input name="image" type="image" onClick='AddRecord()' src="../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> 
        <%}%>
      </td>
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
      <td width="14%"><font size="1">&nbsp;</font></td>
      <td width="64%"><font size="1"><strong>NAME</strong></font></td>
      <td width="10%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=2){ %>
    <tr> 
      <td>&nbsp;</td>
      <td><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><div align="center">
          <input type="image" src="../../images/edit.gif" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'
	  							width="40" height="26">
        </div></td>
      <td>&nbsp;</td>
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
</form>
</body>
</html>

