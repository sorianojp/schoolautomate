<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TABLE.thinborderALL{
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function OpenSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location = "./tor_manual_encode.jsp?stud_id="+ document.form_.stud_id.value;
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function EditRecord(strInfoIndex){
	document.form_.page_action.value = "2";
	document.form_.print_page.value = "";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.print_page.value = "";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce('form_');
}

function ViewRecord(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.view_record.value = "1";
	this.SubmitOnce('form_');
	
}

-->
</script>

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.OfflineAdmission,enrollment.RegTOREncoding" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
//add security here.

try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"ADMIN STAFF-Registrar Management-TOR Encoding","stud_acad.jsp");
}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","TOR Encoding",request.getRemoteAddr(), 
														"stud_acad.jsp");	
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
OfflineAdmission offlineAdm = new OfflineAdmission();
Vector vStudBasicInfo = null;
Vector vRetResult = null;
Vector vEditInfo = null;
RegTOREncoding OTREnc = new RegTOREncoding();
String strPageAction = WI.fillTextValue("page_action");
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strMainIndex = null;

if (WI.fillTextValue("stud_id").length() > 0){
	vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, request.getParameter("stud_id"));
	if (vStudBasicInfo == null){
		strErrMsg = offlineAdm.getErrMsg();
	}else{
		vRetResult =  OTREnc.operateOnManualEncoding(dbOP,request,4);
		if (vRetResult == null && strErrMsg == null)
			strErrMsg = OTREnc.getErrMsg();
	
		if(vRetResult != null){
			strMainIndex = (String)vRetResult.elementAt(0);

		if (strPageAction.compareTo("0") == 0){
			vEditInfo = OTREnc.operateOnGradeEncoding(dbOP,request,0,strMainIndex);
			if (vEditInfo != null)
				strErrMsg = " TOR removed successfully";
			else strErrMsg = OTREnc.getErrMsg();
			
		}else if (strPageAction.compareTo("1") == 0){
			vEditInfo = OTREnc.operateOnGradeEncoding(dbOP,request,1,strMainIndex);
			if (vEditInfo != null)
				strErrMsg = " TOR saved successfully";
			else strErrMsg = OTREnc.getErrMsg();
		}else if (strPageAction.compareTo("2") == 0){
			vEditInfo = OTREnc.operateOnGradeEncoding(dbOP,request,2,strMainIndex);
			if (vEditInfo != null){
				strErrMsg = " TOR edited successfully";
				vEditInfo = null;
			}else strErrMsg = OTREnc.getErrMsg();
		}

		if (WI.fillTextValue("view_record").length() > 0){
			OTREnc.viewRecord(dbOP,request,WI.fillTextValue("content2"),strMainIndex);
		}
		vEditInfo = OTREnc.operateOnGradeEncoding(dbOP,request,4,strMainIndex);
		if (vEditInfo == null && strErrMsg == null)
			strErrMsg = OTREnc.getErrMsg();
		}
	}
}
%>
<body bgcolor="#D2AE72">
<form action="./tor_manual_encode.jsp" method="post" name="form_" id="form_">
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A49A6A" > 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>:::: 
          ENCODING OF GRADES TAKEN FROM OTHER SCHOOL ::::</strong></font></strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg,"<font size = \"3\" color=\"#FF0000\"><strong>","</strong></font>","")%> </td>
    </tr>
    <tr > 
      <td width="1%" height="18">&nbsp;</td>
      <td width="30%">Student ID : 
	 <input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	 onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("stud_id")%>" size="16" maxlength="16"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="63%" height="18" colspan="2"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a> 
      </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td width="1%">&nbsp;</td>
      <td width="10%">SY / TERM : </td>
      <td width="89%" height="25"> 
        <%
	  if (vEditInfo!=null) {
	  	strTemp = (String)vEditInfo.elementAt(2);
	 }else{ 
		if (WI.fillTextValue("sy_from").length() == 0){
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		}else{
			strTemp = WI.fillTextValue("sy_from");
		}
	}
%>
      <input name="sy_from" type="text" class="textbox" id="sy_from" onKeyUp="DisplaySYTo('form_','sy_from','sy_to');"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
        - 
        <%	if (vEditInfo!=null) {
	  	strTemp = (String)vEditInfo.elementAt(3);
	 }else{ 
		if (WI.fillTextValue("sy_to").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		}else{
		strTemp = WI.fillTextValue("sy_to");
	}
}%>
        <input name="sy_to" type="text" class="textbox" id="sy_to"  readonly="yes" value="<%=strTemp%>" size="4" maxlength="4">
        <%	if (vEditInfo!=null) {
	  	strTemp = (String)vEditInfo.elementAt(4);
	 }else{ 
		if (WI.fillTextValue("semester").length() == 0){
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
		}else{
		strTemp = WI.fillTextValue("semester");
	}
}%>
        <select name="semester">
          <option value="1">1st Sem</option>
          <%
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select>
      </td>
    </tr>
  </table>
  <% if (vStudBasicInfo != null) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2">&nbsp; </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="45%" height="25"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong>STUDENT NAME</font> :<strong> <%=WI.formatName((String)vStudBasicInfo.elementAt(0),(String)vStudBasicInfo.elementAt(1),(String)vStudBasicInfo.elementAt(2),4)%></strong></td>
      <td width="55%" valign="top">COURSE : <strong><%=(String)vStudBasicInfo.elementAt(7)%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" valign="top"><font face="Verdana, Arial, Helvetica, sans-serif"><strong>&nbsp; 
        </strong></font>YEAR LEVEL : <strong><%=(String)vStudBasicInfo.elementAt(14)%></strong></td>
      <td valign="top">MAJOR : <strong><%=WI.getStrValue((String)vStudBasicInfo.elementAt(8),"&nbsp")%></strong></td>
    </tr>
  </table>
<% if (vRetResult != null && WI.fillTextValue("sy_from").length() > 0 && 
		WI.fillTextValue("semester").length() > 0) {%> 
  <input type="hidden" name="main_index" value="<%=WI.getStrValue((String)vRetResult.elementAt(0),"")%>"> 
  <input type="hidden" name="num_columns" value="<%=WI.getStrValue((String)vRetResult.elementAt(4),"0")%>"> 
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="3"><hr size="1" noshade> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="15">&nbsp;</td>
      <td height="15" colspan="2">Type in Transcript of Record of Student in the 
        box provided. Separate columns by semicolon (;)</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="13%" height="15">&nbsp;</td>
      <td width="87%" height="15" colspan="2">Number of Columns Required Per Line 
        : <font color="#FF0000" size="2"><strong><%=WI.getStrValue((String)vRetResult.elementAt(4),"0")%></strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <% 
	if (vEditInfo != null) strTemp = (String)vEditInfo.elementAt(6);
	else strTemp = WI.fillTextValue("content2");
	
%> <textarea style="font-size:11px" name="content2" cols="88" rows="24" wrap="OFF" class="textbox" id="content2"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
      </td>
    </tr>
    <tr valign="bottom" bgcolor="#FFFFFF"> 
      <td height="35" colspan="3"><div align="center"></div>
        <div align="center"> 
          <% if (iAccessLevel > 1){
	if(vEditInfo == null) {%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          <font size="1">click to save entries&nbsp;<a href='javascript:CancelRecord("<%=request.getParameter("stud_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel and clear entries</font></font> 
          <%}else{%>
          <a href="javascript:EditRecord('<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../images/edit.gif" border="0"></a> 
          <font size="1">click to save changes</font> 
          <%if (iAccessLevel == 2) {%>
          <a href="javascript:DeleteRecord('<%=(String)vEditInfo.elementAt(0)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
          <font size="1">click to delete record</font> 
          <%} if (vRetResult != null) {%>
          <a href="javascript:ViewRecord('<%=(String)vEditInfo.elementAt(0)%>');"><img src="../../../images/view.gif" width="40" height="31" border="0"></a> 
          <font size="1">click to view record</font> 
          <%}}}%>
        </div></td>
    </tr>
  </table>
<%} // end vRetResult != null
} // end vStudInfo != null %>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="page_action">
  <input type="hidden" name="print_page">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="view_record" value="">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>