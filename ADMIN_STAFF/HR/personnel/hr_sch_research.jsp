<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoScholarship" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value=index;
	this.ReloadPage();
}

function AddRecord()
{
	document.staff_profile.page_action.value="1";
	this.ReloadPage();
}

function EditRecord()
{
	document.staff_profile.page_action.value="2";
	this.ReloadPage();
}

function DeleteRecord(index)
{
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value= index;
	this.ReloadPage();
}

function ReloadPage()
{
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}


function CancelEdit(){
	document.staff_profile.specification.value = "";
	document.staff_profile.prepareToEdit.value = "0";
	document.staff_profile.page_action.value="";
	document.staff_profile.info_index.value= "";
	this.ReloadPage();
}

function CloseWindow()
{
	document.staff_profile.close_wnd_called.value = "1";

	window.opener.document.staff_profile.rw.selectedIndex = document.staff_profile.work_type_index.selectedIndex;
	window.opener.document.staff_profile.spec[window.opener.document.staff_profile.spec.selectedIndex].value = document.staff_profile.last_index.value;
	window.opener.document.staff_profile.submit();
	window.opener.focus();
	self.close();
}
function ReloadParentWnd() {
	if(document.staff_profile.donot_call_close_wnd.value.length >0)
		return;
	if(document.staff_profile.close_wnd_called.value == "0") {
		window.opener.document.staff_profile.rw.selectedIndex = document.staff_profile.work_type_index.selectedIndex;
		window.opener.document.staff_profile.spec[window.opener.document.staff_profile.spec.selectedIndex].value = document.staff_profile.last_index.value;
		window.opener.document.staff_profile.submit();
		window.opener.focus();
	}
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	String strTemp2 = null;

	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-School Year Holidays",
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
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"hr_updateschlist.jsp");
if(iAccessLevel < 1) {//All employees are allowed to use this, because this is a common file.
strTemp = (String)request.getSession(false).getAttribute("authTypeIndex");
int iAuthTypeIndex = Integer.parseInt(WI.getStrValue(strTemp,"-1"));//System.out.println(iAuthTypeIndex);
	if(iAuthTypeIndex != -1) {
		if(iAuthTypeIndex != 4 || iAuthTypeIndex != 6)//no access to parent / student
			iAccessLevel = 2;
	}
}							
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

	Vector vRetEdit = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strInfoIndex = WI.fillTextValue("info_index");
	
	HRInfoScholarship  hrList = new HRInfoScholarship();
	String strLastEntry  = WI.fillTextValue("last_index");

	if (WI.fillTextValue("page_action").compareTo("0") == 0){
		if (hrList.operateOnWorkTypesSpec(dbOP,request,0) != null)
			strErrMsg = " Research/Scholarship Specification removed successfully";
			
		else strErrMsg  = hrList.getErrMsg();
	}else if (WI.fillTextValue("page_action").compareTo("1")==0){
		vRetResult = hrList.operateOnWorkTypesSpec(dbOP,request,1);
		if ( vRetResult != null){
			strErrMsg = " Research/Scholarship Specification added successfully";
			if (vRetResult.size() > 0) strLastEntry = (String)vRetResult.elementAt(0);
		}else strErrMsg  = hrList.getErrMsg();
	}else if (WI.fillTextValue("page_action").compareTo("2")==0){
		vRetResult = hrList.operateOnWorkTypesSpec(dbOP,request,2);	
		if (vRetResult != null){
			strErrMsg = " Research/Scholarship Specification updated successfully";
			strPrepareToEdit = "";
			if (vRetResult.size() > 0) strLastEntry = (String)vRetResult.elementAt(0);
		}else strErrMsg  = hrList.getErrMsg();
	}

	if (strPrepareToEdit.compareTo("1") == 0){
		vRetEdit = hrList.operateOnWorkTypesSpec(dbOP,request,3);

		if (vRetEdit == null && strErrMsg == null)
			strErrMsg = hrList.getErrMsg();
	}
	
	vRetResult = hrList.operateOnWorkTypesSpec(dbOP,request,4);
%>
<body bgcolor="#663300" onUnload="ReloadParentWnd();" class="bgDynamic">
<form action="./hr_sch_research.jsp" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          RESEARCH/SCHOLARSHIP TYPE RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=3 color=#FF0000>","</font></strong>","")%><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" align="center" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
      <td valign="middle">TYPE OF WORK : </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td valign="middle"><select name="work_type_index" onChange="ReloadPage()">
                <option value="">Not applicable</option>
	 <% if (vRetEdit != null) strTemp = (String)vRetEdit.elementAt(2);
	   else strTemp = WI.fillTextValue("work_type_index"); %>
                <%=dbOP.loadCombo("WORK_TYPE_INDEX","WORK_TYPE_NAME"," FROM HR_PRELOAD_WORK_TYPE",strTemp,false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td valign="middle">SPECIFICATIONS:</td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
	<% if (vRetEdit != null)  strTemp = WI.getStrValue((String)vRetEdit.elementAt(1));
	  else strTemp = WI.fillTextValue("specification"); %>
      <td width="99%" valign="middle"> <textarea name="specification" cols="48" rows="3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea> 
      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td> 
	  <%  if (strPrepareToEdit.compareTo("1") == 0){%> <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <%}else{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"> </a>
        <font size="1">click to add entry</font> 
		<%}%><a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">click 
        to cancel edit</font>
		 </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
 <% if (vRetResult !=null && vRetResult.size() > 0){ %>  
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborderBOTTOM">
    <tr> 
      <td height="25" colspan="5" bgcolor="#666666" class="thinborder"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF <strong>RESEARCH/SCHOLARSHIP TYPE</strong></font></strong></div></td>
    </tr>
    <tr> 
      <td class="thinborder">&nbsp;</td>
      <td height="25" class="thinborderBOTTOM">TYPE OF WORK </td>
      <td class="thinborder">SPECIFICATION</td>
      <td class="thinborder">EDIT</td>
      <td class="thinborder">DELETE</td>
    </tr>
    <% for (int i =0; i < vRetResult.size() ; i+=4){ %>
    <tr> 
      <td width="2%" class="thinborder">&nbsp;</td>
      <td width="39%" class="thinborderBOTTOM"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%></td>
      <td width="41%" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%> </td>
      <td width="6%" class="thinborder"><div align="center"> 
          <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/edit.gif" border="0"></a>
        </div></td>
      <td width="8%" class="thinborder"><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%} //  end for loop%>
  </table>
<%} %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="last_index" value="<%=WI.getStrValue(strLastEntry)%>">

<!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
</form>
</body>
</html>

