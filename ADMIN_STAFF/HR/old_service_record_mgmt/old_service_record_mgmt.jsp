<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
</head>
<script language="JavaScript">
function FocusID() {
	document.form_.emp_id.focus();
}
function PageAction(strAction, strInfoIndex) {
	document.form_.print_page.value = "";
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}
function PrintPage(){
	document.form_.print_page.value = "1";
	this.SubmitOnce("form_");
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector, hr.OldServiceRecord, enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	String strSubCode = "";
	String strRecIndex = null;
	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./summary_faculty_load_print.jsp" />
	<%	return;
	}

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OLD SERVICE RECORD MGMT","old_service_record_mgmt.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","OLD SERVICE RECORD MGMT",request.getRemoteAddr(),
														"old_service_record_mgmt.jsp");
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

Vector vEmpRec = null;
Vector vServiceRecord = null;
Vector vLoad = null;
boolean bolClear = false;

String strInfoIndex = request.getParameter("info_index");
Authentication auth = new Authentication();
strTemp = WI.fillTextValue("emp_id");

if (!strTemp.equals(WI.fillTextValue("cur_id"))){
	bolClear = true;
}

if (strTemp.length()> 0){

	enrollment.Authentication authentication = new enrollment.Authentication();
  
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
}
if (vEmpRec!=null){
	OldServiceRecord oSR = new OldServiceRecord();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(oSR.operateOnOldServiceRecord(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
		}else
			strErrMsg = oSR.getErrMsg();
	}

	vServiceRecord = oSR.operateOnOldServiceRecord(dbOP, request, 4);
	if (vServiceRecord!=null){
		strRecIndex  = (String)vServiceRecord.elementAt(0);
		request.setAttribute("rec_index",strRecIndex);
		vLoad = oSR.operateOnOldServiceRecord (dbOP, request, 7);
			if (vLoad ==null)
				strErrMsg = oSR.getErrMsg();
	}
	else
		strErrMsg = oSR.getErrMsg();
}
%>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<form action="./old_service_record_mgmt.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          HR : OLD SERVICE RECORD MGMT PAGE ::::</strong></font></div></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25" colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25">Employee ID</td>
      <td width="23%" height="25">
      <%strTemp = WI.fillTextValue("emp_id");%>
      <input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="6%"><div align="right"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></div></td>
      <td width="51%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
			<label id="coa_info"></label>
			</td>
    </tr>
  </table>
 
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr>
        <td width="3%" height="25">&nbsp;</td>
        <td width="17%" height="25">School Year / Term</td>
        <td width="80%" height="25" colspan="2"><% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
            <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
          to
          <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
          <input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
          /
          <select name="semester">
            <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
            <option value="0" selected>Summer</option>
            <%}else{%>
            <option value="0">Summer</option>
            <%}if(strTemp.compareTo("1") ==0){%>
            <option value="1" selected>1st Semester</option>
            <%}else{%>
            <option value="1">1st Semester</option>
            <%}if(strTemp.compareTo("2") == 0){%>
            <option value="2" selected>2nd Semester</option>
            <%}else{%>
            <option value="2">2nd Semester</option>
            <%}if(strTemp.compareTo("3") == 0){%>
            <option value="3" selected>3rd Semester</option>
            <%}else{%>
            <option value="3">3rd Semester</option>
            <%}%>
          </select></td>
      </tr>
      <tr>
        <td height="10" colspan="4"><hr size="1"></td>
      </tr>
      <tr>
        <td height="10" colspan="4">&nbsp;</td>
      </tr>
    </table>
    <% if (vEmpRec != null && vEmpRec.size() > 0) {%>

        `
        <%}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<%if (vEmpRec != null && vEmpRec.size() > 0){%>
    <tr> 
      <td width="7%" height="25">&nbsp;</td>
      <td width="16%" height="25">Total Load Units</td>
      <%
      if (vServiceRecord != null && vServiceRecord.size()>0)
      		strTemp = (String)vServiceRecord.elementAt(5);
   		else
			if (!bolClear) 
	      		strTemp = WI.fillTextValue("total_load");
			else
				strTemp= "";
       %>
      <td width="10%" height="25">
      <input name="total_load" type="text" id="amount" size="4" maxlength="4" class="textbox"
        onKeyUp= 'AllowOnlyFloat("form_","total_load")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","total_load");style.backgroundColor="white"' value="<%=strTemp%>"></td>
      <td width="67%" colspan="2">&nbsp;&nbsp;
	  <%if(vServiceRecord == null || vServiceRecord.elementAt(5) == null) {%>
	  <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
	  <%}else{//show edit.%>
	  <a href='javascript:PageAction(1,"");'><img src="../../../images/edit.gif" border="0" name="hide_save"></a>
	  <%}%>
	   <font size="1">Click to update entry</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Service Credits </td>
      <%
      if (vServiceRecord != null && vServiceRecord.size()>0)
      		strTemp = (String)vServiceRecord.elementAt(6);
   		else if (!bolClear) 
	     	strTemp = WI.fillTextValue("service_credit");
		else
			strTemp= "";
       %>
	  
      <td height="25"><input name="service_credit" type="text" size="4" maxlength="8" class="textbox"
        onKeyUp= 'AllowOnlyFloat("form_","service_credit")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyFloat("form_","service_credit");style.backgroundColor="white"' value="<%=strTemp%>"></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
 <%}if (vServiceRecord != null && vServiceRecord.size()>0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><u>Subjects Handled</u></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Subject </td>
      <td height="25" colspan="2">		<input type="text" name="filter_sub" value='<%=WI.fillTextValue("filter_sub")%>' class="textbox" 
			onKeyUp="AutoScrollListSubject('filter_sub','sub_code',true,'form_');">
        (scroll subject) <div align="right"></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
      <select name="sub_code" style="font-size:10px">
          <%=dbOP.loadCombo("sub_index","sub_code+'&nbsp;&nbsp; ('+sub_name+')' as sub_list"," from subject where IS_DEL=0 order by sub_list asc", WI.fillTextValue("sub_code"), false)%> 
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">
      <%strTemp = WI.fillTextValue("sub_index");%>
      <input name="sub_index" type="text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'" value="<%=strTemp%>">
        <font size="1">(type subject code if not found in the list)</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><div align="center"><font size="1">&nbsp;&nbsp;<a href='javascript:PageAction(5,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to save subject</font></div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
          to print old service record</font></div></td>
    </tr>
    <%}%>
</table>  
<%if (vLoad!=null && vLoad.size()>0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#97ABC1"> 
      <td height="25" colspan="4"><div align="center"><strong><font color="#FFFFFF">OLD 
          SERVICE RECORD ENTRIES</font></strong></div></td>
    </tr>
    <tr> 
      <td width="25%" height="25">&nbsp;</td>
      <td width="25%"><div align="center"><strong>SUBJECTS 
          HANDLED</strong></div></td>
      <td width="25%"><div align="center"><strong>OPTIONS</strong></div></td>
      <td width="25%">&nbsp;</td>
    </tr>
<%for (int i = 0; i< vLoad.size(); i+=10){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td><%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%></td>
      <td><div align="center"><font size="1">
			<% if(iAccessLevel ==2){
				if (!((String)vLoad.elementAt(i)).equals("-1")){
			%>
			<a href='javascript:PageAction("0","<%=(String)vLoad.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
			<%} // faculty loaded using SB.. delete through enrollment faculty loading
			}else{%>
			Not authorized to delete 
			<%}%>
			</font></div></td>
      <td><font size="1">&nbsp;</font></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="4" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="rec_index" value="<%=strRecIndex%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="print_page">
  <input type="hidden" name="cur_id" value="<%=WI.fillTextValue("emp_id")%>">
<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
