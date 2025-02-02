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
	this.SubmitOnce("staff_profile");
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
function DeleteRecord(strInfoIndex,strBuildingName){
var vProceed = confirm("Confirm Delete of Building :" + strBuildingName);
	if(vProceed){
		document.staff_profile.bldg_name.value= strBuildingName;
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

function CancelEdit(){
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.info_index.value = "";
	document.staff_profile.bldg_name.value="";
	document.staff_profile.bldg_code.value = "";
	document.staff_profile.year_constructed.value = "";
	document.staff_profile.prepareToEdit.value="";
	this.SubmitOnce("staff_profile");	
}

function CloseWindow(){
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
	HRManageList  hrList = new HRManageList();
	
	iAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	
	switch(iAction){
	case 0:
	
		vRetResult = hrList.operateOnBldgs(dbOP,request,0);
		
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "Building record removed successfully.";
			noError = true;
		}
		break;
	case 1: 
		vRetResult = hrList.operateOnBldgs(dbOP,request,1);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "Building record added successfully.";
			noError = true;
		}
		break;

	case 2:
		vRetResult = hrList.operateOnBldgs(dbOP,request,2);
		if (vRetResult == null){
			strErrMsg = hrList.getErrMsg();
		}else{
			strErrMsg = "Building record edited successfully";
			strPrepareToEdit = "0";
			noError = true;
		}
		break;
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnBldgs(dbOP,request,3);	
		if (vRetEdit == null) 
			strErrMsg = hrList.getErrMsg();
			
		//System.out.println(vRetEdit);
	}
	
	vRetResult = hrList.operateOnBldgs(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null) 
		strErrMsg = hrList.getErrMsg();
	

	//System.out.println(vRetEdit);

%>
<form action="./hr_updatelist_bldg.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          BUILDINGS RECORD PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%><a href="javascript:CloseWindow();">
	  <img src="../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="21%">Building Name</td>
      <td width="78%"> <% 
	if (vRetEdit!=null && vRetEdit.size() > 0) 
		strTemp = WI.getStrValue((String)vRetEdit.elementAt(1));
   else 
   		strTemp = WI.fillTextValue("bldg_name"); 

%> <input name="bldg_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="48" maxlength="64"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Building Code</td>
      <td> <% if (vRetEdit != null && vRetEdit.size() > 0) strTemp = WI.getStrValue((String)vRetEdit.elementAt(2));
   else strTemp = WI.fillTextValue("bldg_code"); 
	   //System.out.println(strTemp);
%> <input name="bldg_code" type="text" class="textbox" id="bldg_code" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="6" maxlength="6"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Year Constructed</td>
      <td>
        <% if (vRetEdit != null && vRetEdit.size() > 0) 
	  		strTemp = WI.getStrValue((String) vRetEdit.elementAt(3));
	   else strTemp = WI.fillTextValue("year_constructed"); 
	   
	   //System.out.println(strTemp);
%>
        <input name="year_constructed" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Number of Rooms/Offices</td>
      <td>&nbsp; <%if (vRetEdit != null && vRetEdit.size() > 0) {%> <font color="#0000FF"><strong><%=(String)vRetEdit.elementAt(4)%></strong></font> <%}%></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td> <% if (strPrepareToEdit.compareTo("1") == 0){%> <input name="image" type="image" onClick='EditRecord()' src="../../images/edit.gif" border="0"> 
        <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'> 
        <img src="../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font> <%}else{%> <input name="image" type="image" onClick='AddRecord()' src="../../images/add.gif" width="42" height="32"> 
        <font size="1">click to add entry</font> <%}%> </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
    </tr>
  </table>

<% if (vRetResult != null && vRetResult.size() > 0){%>

 <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td colspan="5" bgcolor="#666666" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF OFFICES</font></strong></div></td>
    </tr>
    <tr align="center"> 
      <td width="15%" height="25" class="thinborder"><strong>BLDG CODE</strong></td>
      <td width="45%" class="thinborder"><strong>BUILDING NAME</strong></td>
      <td width="23%" class="thinborder"><strong>YEAR CONSTRUCTED</strong></td>
      <td width="7%" class="thinborder"><strong>EDIT</strong></td>
      <td width="10%" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=4){ %>
    <tr> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
      <td class="thinborder"><div align="center"> 
          <% if (iAccessLevel > 1) {%>
		  
		  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>")'%>
          <img src="../../images/edit.gif" border="0">
		  </a>
          <%}else{%>
          N/A 
          <%}%>
        </div></td>
      <td class="thinborder"><%if(iAccessLevel== 2 ){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>",
	  																						"<%=(String)vRetResult.elementAt(i+1)%>")'> 
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
<%} // end vRetResult != null %>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="prepareToEdit">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="donot_call_close_wnd" value="0">
<input type="hidden" name="page_action" value="">
</form>
</body>
</html>

