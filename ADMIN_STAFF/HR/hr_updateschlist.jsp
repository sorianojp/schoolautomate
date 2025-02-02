<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList" %>
<%
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
function CancelEdit(){
	location = "./hr_updateschlist.jsp";
}

function CloseWindow()
{
	window.opener.document.staff_profile.submit()
	window.opener.focus();
	self.close();
}
</script>

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
								"Admin/staff-HR Management - update School list",
								"hr_updateschlist.jsp");
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
														"hr_updateschlist.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}

if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}

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
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strInfoIndex = WI.fillTextValue("info_index");	
	
	HRManageList  hrList = new HRManageList();
	
	iAction = Integer.parseInt(WI.getStrValue(strTemp,"0"));

	switch(iAction){
	case 1: 
		vRetResult = hrList.operateOnSchools(dbOP,request,iAction);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "School Information added successfully.";
			noError = true;
		}
		break;

	case 2:
		vRetResult = hrList.operateOnSchools(dbOP,request,iAction);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "School Information edited successfully";
			strPrepareToEdit = "0";
			noError = true;
		}
		break;
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnSchools(dbOP,request,3);
	}
	
	vRetResult = hrList.operateOnSchools(dbOP,request,4);
	
	

%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_updateschlist.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SCHOOLS RECORDS PAGE ::::</strong></font></div></td>
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
	strTemp2 = (String) vRetEdit.elementAt(2);
   }else{
   	strTemp = WI.fillTextValue("strSchool");
	strTemp2 = WI.fillTextValue("strAdd");
   }
%>
      <td width="99%" valign="middle">NAME OF SCHOOL&nbsp;<br>
        <input name="strSchool" id="strSchool" value="<%=strTemp%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64">
        <br>
        SCHOOL CODE<br>
<%
	if (vRetEdit != null && vRetEdit.size() > 0) 
		strTemp = WI.getStrValue((String) vRetEdit.elementAt(3));
	else
		strTemp = WI.fillTextValue("sch_code");
%>
        <input name="sch_code" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16"> 
        <br>
        ADDRESS OF SCHOOL<br>
        <input name="strAdd" id="strAdd" value="<%=strTemp2%>" size="64" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> 
        <% if (strPrepareToEdit.compareTo("1") == 0){%>
        <input name="image" type="image" onClick='EditRecord()' src="../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> 
        <%}else{%>
        <input name="image" type="image" onClick='AddRecord()' src="../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> 
        <%}%>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>


 <% if (vRetResult !=null && vRetResult.size() > 0){ %>  
  <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" bgcolor="#666666"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF SCHOOLS </font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="14%"><font size="1">&nbsp;</font></td>
      <td width="64%"><font size="1"><strong>NAME</strong></font></td>
      <td width="10%">&nbsp;</td>
      <td width="12%">&nbsp;</td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=4){ %>
    <tr> 
      <td>&nbsp;</td>
      <td><strong><%=(String)vRetResult.elementAt(i+1)%>
	  			<%=WI.getStrValue((String)vRetResult.elementAt(i+3),"(",")","")%></strong><br>
				<font size=1><%=(String)vRetResult.elementAt(i+2)%></font></td>
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
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
</form>
</body>
</html>

