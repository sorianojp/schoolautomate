<%
long lTime = new java.util.Date().getTime();
String strTemp = "../error.jsp";
if(request.getParameter("redirectURL") != null && request.getParameter("redirectURL").indexOf(".jsp") != -1){
	strTemp = response.encodeRedirectURL(request.getParameter("redirectURL"));
	//System.out.println(strTemp);

%>
	<jsp:forward page="<%=strTemp%>" />

<%}%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function Disable(strDisable) {
	document.subm.disable_pr.value = strDisable;
	this.SubmitOnce('subm');
}
function PrintPg()
{
	var strSubCodeFrom = "";
	var strSubCodeTo   = "";
	if(document.subm.subcode_from.selectedIndex >=0)
		strSubCodeFrom = document.subm.subcode_from[document.subm.subcode_from.selectedIndex].text;
	if(document.subm.subcode_to.selectedIndex >=0)
		strSubCodeTo = document.subm.subcode_to[document.subm.subcode_to.selectedIndex].text;

	var printPgURL = "./curriculum_subject_list_print.jsp?subcode_from="+strSubCodeFrom+"&subcode_to="+strSubCodeTo+"&print_pg=1&starts_with="+
		document.subm.starts_with.value;
		
	if(document.subm.inc_course_desc && document.subm.inc_course_desc.checked)
		printPgURL += "&inc_=1";

	var win=window.open(printPgURL,"PrintWindow",'width=800,height=600,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();


}
function ReloadPage()
{
	goToNextSearchPage();
}
function goToNextSearchPage()
{
	document.subm.editRecord.value = 0;
	document.subm.deleteRecord.value = 0;
	document.subm.addRecord.value = 0;
	document.subm.prepareToEdit.value = 0;

	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="";
	this.SubmitOnce('subm');
}
function CancelRecord()
{
	location="./curriculum_subject.jsp";
}

function PrepareToEdit(strInfoIndex)
{
	document.subm.editRecord.value = 0;
	document.subm.deleteRecord.value = 0;
	document.subm.addRecord.value = 0;
	document.subm.prepareToEdit.value = 1;

	document.subm.info_index.value = strInfoIndex;

	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="";
	this.SubmitOnce('subm');
}
function AddRecord()
{
	if(document.subm.prepareToEdit.value == 1)
	{
		EditRecord(document.subm.info_index.value);
		return;
	}
	document.subm.editRecord.value = 0;
	document.subm.deleteRecord.value = 0;
	document.subm.addRecord.value = 1;

	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="";
	this.SubmitOnce('subm');
}
function EditRecord(strTargetIndex)
{
	document.subm.editRecord.value = 1;
	document.subm.deleteRecord.value = 0;
	document.subm.addRecord.value = 0;

	document.subm.info_index.value = strTargetIndex;
	
	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="";
	this.SubmitOnce('subm');
}

function DeleteRecord(strTargetIndex)
{
	document.subm.editRecord.value = 0;
	document.subm.deleteRecord.value = 1;
	document.subm.addRecord.value = 0;

	document.subm.info_index.value = strTargetIndex;
	document.subm.prepareToEdit.value == 0;

	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="";
	this.SubmitOnce('subm');
}

function UpdatePreRequisite()
{
	//enter subject code, subject name, subject category to update pre-requisite.
	var sCode = document.subm.sub_code.value;
	var sName = document.subm.sub_name.value;
	var sCatgIndex = document.subm.catg_index[document.subm.catg_index.selectedIndex].value;
	var sCatg = document.subm.catg_index[document.subm.catg_index.selectedIndex].text;

	if(sCode.length == 0 || sName.length == 0)
	{
		alert("Subject code/ subject name can't be blank. Please enter existing subject code/ subject name and corresponding subject category.");
		return;
	}

	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="./curriculum_subject_pre.jsp?catg_name="+escape(sCatg)+"&hist=curriculum_subject.jsp";
	this.SubmitOnce('subm');
}
function UpdateElective()
{
	//enter subject code, subject name, subject category to update pre-requisite.
	var sCode = document.subm.sub_code.value;
	var sName = document.subm.sub_name.value;
	var sCatgIndex = document.subm.catg_index[document.subm.catg_index.selectedIndex].value;
	var sCatg = document.subm.catg_index[document.subm.catg_index.selectedIndex].text;

	if(sCode.length == 0 || sName.length == 0)
	{
		alert("Subject code/ subject name can't be blank. Please enter existing subject code/ subject name and corresponding subject category.");
		return;
	}

	document.subm.disable_pr.value = "";
	document.subm.redirectURL.value="./curriculum_subject_elective.jsp?catg_name="+escape(sCatg)+"&hist=curriculum_subject.jsp";
	this.SubmitOnce('subm');
}
</script>


<body bgcolor="#D2AE72" onLoad="document.subm.sub_code.focus();">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	boolean bolIsPRDisabled = false;//if pre-requisite is disabled, I will show an icon to enable all the pre-requisite.


	String strErrMsg = "";
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subjects Maintenance","curriculum_subject.jsp");
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
														"Registrar Management","CURRICULUM-Subjects Maintenance",request.getRemoteAddr(),
														"curriculum_subject.jsp");
if(WI.fillTextValue("search_").compareTo("1") ==0)
	iAccessLevel = 1;

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

//end of authenticaion code.

CurriculumSM SM = new CurriculumSM();

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(SM.add(dbOP,request))
	{
		strErrMsg = "Subject added successfully.";
	}
	else
	{
		dbOP.cleanUP();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=SM.getErrMsg()%></font></p>
		<%
		return;
	}
}
else//either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(SM.edit(dbOP,request))
		{
			strPrepareToEdit="0";
			strErrMsg = "Subject edited successfully.";
		}
		else
		{
			dbOP.cleanUP();
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
			<%=SM.getErrMsg()%></font></p>
			<%
			return;
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";

			if(SM.delete(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
			{
				strErrMsg = "Subject deleted successfully.";
			}
			else
			{
				dbOP.cleanUP();
				%>
				<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
				<%=SM.getErrMsg()%></font></p>
				<%
				return;
			}
		}
	}
}
//System.out.println("Printing 1 : "+Long.toString(new java.util.Date().getTime() - lTime));
int iSearchResult = 0;
//get all levels created.
Vector vRetResult = new Vector();
vRetResult = SM.viewAll(dbOP,request);
iSearchResult = SM.iSearchResult;
//System.out.println("Printing 1 : "+Long.toString(new java.util.Date().getTime() - lTime));

if(vRetResult ==null)
{%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="+2">
	<%=SM.getErrMsg()%></font></p>
	<%
	dbOP.cleanUP();
	return;
}
Vector vEditInfo = new Vector();
if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
	vEditInfo = SM.view(dbOP,request.getParameter("info_index"));

String[] strConvertAlphabet =
		{"0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};


if(WI.fillTextValue("disable_pr").length() > 0) {
	boolean bolEnable = false;
	if(WI.fillTextValue("disable_pr").compareTo("0") ==0)
		bolEnable = true;
	SM.enableDisablePreq(dbOP, null,bolEnable);
	strErrMsg = SM.getErrMsg();
}

bolIsPRDisabled = SM.checkIfSubPreqIsDisabled(dbOP, null);//to check any of the subjects having pre-requisite 
	
	
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";	

boolean bolShowEnablePreReq = true;
if(strSchCode.startsWith("EAC") || strSchCode.startsWith("NEU") ) {
	bolShowEnablePreReq = comUtil.IsSuperUser(dbOP,(String)request.getSession(false).getAttribute("userId"));
}

%>

<form name="subm" method="post" action="./curriculum_subject.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SUBJECTS MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>
<%
///do not show this if called for search.
if(WI.fillTextValue("search_").length() == 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="1%" height="25">&nbsp;</td>
      <td width="50%" height="25">Subject code 
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("sub_code");
	if(strTemp == null) strTemp = "";
	%> &nbsp; <input tabindex="1" name="sub_code" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
      <td width="49%" height="25">Subject Title 
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("sub_name");
	if(strTemp == null) strTemp = "";
	%> &nbsp; <input tabindex="2" name="sub_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="bottom">Subject category<a href="./curriculum_subject_catg.jsp" target="_self"><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">Update category list</font></td>
      <td height="25" valign="bottom">Subject group <a href="./curriculum_subject_group.jsp" target="_self"><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">Update group list</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><select tabindex="4" name="catg_index" style="font-size:11px;">
          <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("catg_index");
	if(strTemp == null) strTemp = "";//System.out.println(strTemp);
%>
      <%=dbOP.loadCombo("catg_index","catg_name"," from subject_catg where IS_DEL=0 and MULTIPLE_OC_MAP=0 order by catg_name asc", strTemp, false)%> </select>
      
	  <%if(vEditInfo != null && vEditInfo.size() > 1 && false){%>
	  	NOTE: to edit subject category, please go to "update subject category" link
	  <%}%>
	  
	  
	  </td>
      <td height="25"><select name="group_name" style="font-size:11px;">
          <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = WI.fillTextValue("group_name");
%>
        <%=dbOP.loadCombo("group_index","group_name"," from subject_group where IS_DEL=0 order by group_name asc", strTemp, true)%> </select></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Minimum students : 
        <%
        if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("min_req_stud");
	if(strTemp == null) strTemp = "";%> <input tabindex="3" name="min_req_stud" type="text" size="3" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
      <td height="30">Max students per class: 
        <%
        if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = request.getParameter("max_stud");
	if(strTemp == null) strTemp = "";%> <input tabindex="3" name="max_stud" type="text" size="3" maxlength="3" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">Gender Specific (if applicable) : 
        <select name="gender"
		style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;font-weight:bold">
          <option value="">Not Applicable</option>
<%

if(vEditInfo != null && vEditInfo.size() > 1)
	strTemp = (String)vEditInfo.elementAt(8);
else
	strTemp = request.getParameter("gender");
strTemp = WI.getStrValue(strTemp);
if(strTemp.compareTo("0") == 0){%>
          <option value="0" selected>Male</option>
<%}else{%>
          <option value="0">Male</option>
<%}if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>Female</option>
<%}else{%>
          <option value="1">Female</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td colspan="3" height="25"><hr size="1"></td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25"> <a href="javascript:UpdateElective();"><img src="../../../images/update.gif" border="0"></a> 
        <font size="1">click to update list of elective subject options</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25"> <%
	if(strPrepareToEdit.compareTo("0") == 0)
	{%> <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to save entry</font> <a href="javascript:UpdatePreRequisite();"> <img src="../../../images/prerequisite.gif" width="65" height="21" border="0"></a><font size="1">click 
        to update pre-requisite subject list</font> <%}else{%> <a href="javascript:UpdatePreRequisite();"> <img src="../../../images/prerequisite.gif" width="65" height="21" border="0"></a><font size="1">click 
        to update pre-requisite subject list</font> <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click 
        to cancel &amp; clear entries</font> <%}%> </td>
    </tr>
    <%}//if iAccessLevel > 1
    if(strErrMsg != null)
    {%>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td colspan="2"><strong><font size="3"><%=strErrMsg%></font></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="98%">Display subjects with subject code starts with 
        <select name="subcode_from" onChange="ReloadPage();">
          <option></option>
          <%
 strTemp = WI.fillTextValue("subcode_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<36; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to 
        <select name="subcode_to" onChange="ReloadPage();">
          <option></option>
          <%
 strTemp = WI.fillTextValue("subcode_to");

 for(int i=++j; i<36; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select></td>
    </tr>
    <%
if(WI.fillTextValue("subcode_from").length() > 0){%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td width="98%">Second digit of subject code starts with 
        <select name="subcode_from_2nd" onChange="ReloadPage();">
          <option></option>
          <%
 strTemp = WI.fillTextValue("subcode_from_2nd");
 for(int i=0; i<36; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 %>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        (Optional to select)</td>
    </tr>
    <%
	}//only if subcode_from is selected.
}//if strErrMsg is not null
if(bolShowEnablePreReq){%>
    <tr> 
      <td width="2%">&nbsp;</td>
      <td align="right"><strong></strong> 
        <%
if(bolIsPRDisabled){%>
        <a href="javascript:Disable(0);"><img src="../../../images/enable.gif" border="0"></a> 
        <font color="#0000FF" size="1">click to enable pre-requisites</font> 
        <%}else{%>
        <a href="javascript:Disable(1);"><img src="../../../images/disable.gif" border="0"></a> 
        <font color="#0000FF" size="1">click to disable pre-requisites</font> 
<%}%>
      &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
<%}%>	
  </table>

<%}//if(WI.fillTextValue("search_").compareTo("1") ==0)
/// do not show information above if called for search.
%>  
  
<table width=100% border=0 bgcolor="#FFFFFF">

    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" bgcolor="#B9B292"><div align="center">LIST
          OF EXISTING SUBJECTS BY SUBJECT TYPE</div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() >0)//6 in one set ;-)
{%>

  <table width="100%" border="0" bgcolor="#FFFFFF">
    <tr>
      <td >To filter SUBJECT display enter subject code/name starts with 
        <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="6" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        and click REFRESH to reload the page <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a> 
      </td>
      <td style="font-size:10px"><div align="right">
	  <%if(strSchCode.startsWith("UDMC")){%>
	  	<input type="checkbox" name="inc_course_desc">Include Course Desc &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <%}%>
	  
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click
          to print list</div></td>
    </tr>
    <tr>
      <td width="66%" ><b> Total Subjects : <%=iSearchResult%> - Showing(<%=SM.strDispRange%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/SM.defSearchSize;
		if(iSearchResult % SM.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="goToNextSearchPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Subject Code </strong></font></div></td>
      <td width="22%" class="thinborder"><div align="center"><font size="1"><strong>Subject Name </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>Subject Category </strong></font></div></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">Subject Group </font></strong></td>
      <td width="10%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Encoded By </td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>Min Stud </strong></font></div></td>
      <td width="5%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Max Stud</td>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">Gender</font></strong></td>
      <td width="5%" align="center" class="thinborder"><font size="1"><strong>Edit</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>Delete</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size(); ++i) {%>
    <tr> 
      <td class="thinborder" height="22"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
      <td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
      <td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <td align="center" class="thinborder">&nbsp;
	  <%if(vRetResult.elementAt(i + 8) != null) {
	  	if(((String)vRetResult.elementAt(i + 8)).compareTo("0") == 0){%>Male<%}else{%>Female<%} }%></td>
      <td align="center" class="thinborder"> <%if(iAccessLevel > 1){%> <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%> </td>
      <td align="center" class="thinborder"> <%if(iAccessLevel ==2 ){%> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>
        NA 
        <%}%> </td>
    </tr>
    <%
i = i+9;
}//end of loop %>
  </table>

<%}//end of displaying %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print list</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

 <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">
<input type="hidden" name="hist" value="./curriculum_subject.jsp">
<input type="hidden" name="redirectURL"><!-- incase of url redirecting -- set the value to the url to redirect ;-) -->

<input type="hidden" name="disable_pr">
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>