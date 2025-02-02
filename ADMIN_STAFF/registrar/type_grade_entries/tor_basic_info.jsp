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

function UpdateList() {
	var pgLoc = "./tor_column_list.jsp?stud_id="+ document.form_.stud_id.value +"&num_column="+
	document.form_.num_column.value+"&main_index="+ document.form_.main_index.value;
	
	var win=window.open(pgLoc,"ListWindow",'width=700,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EncodeGrade(){
	location = "./tor_manual_encode.jsp?stud_id="+document.form_.stud_id.value;
}

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CancelEdit(){
	location = "./stud_non_acad.jsp?stud_id="+ document.form_.stud_id.value;
}

function ReloadSection(){
	document.form_.subject.value="";
	ReloadPage();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce('form_');
}

-->
</script>

<%@ page language="java" import="utility.*,java.util.Vector,enrollment.OfflineAdmission,enrollment.RegTOREncoding" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
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
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
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
	String[] astrConvSem = {", Summer", ", 1st Semester",", 2nd Semester",",3rd Semester", ", 4th Semester"};

	
	if (WI.fillTextValue("stud_id").length() > 0){
		vStudBasicInfo = offlineAdm.getStudentBasicInfo(dbOP, request.getParameter("stud_id"));
		if (vStudBasicInfo == null){
			strErrMsg = offlineAdm.getErrMsg();
		}		
		if (strPageAction.compareTo("0") == 0){
			vRetResult = OTREnc.operateOnManualEncoding(dbOP,request,0);
			if (vRetResult != null)
				strErrMsg = " TOR Encoding basic information removed successfully";
			else
				strErrMsg = OTREnc.getErrMsg();
		}else if (strPageAction.compareTo("1") == 0){
			vRetResult = OTREnc.operateOnManualEncoding(dbOP,request,1);
			if (vRetResult != null)
				strErrMsg = " TOR Encoding basic information saved successfully";
			else
				strErrMsg = OTREnc.getErrMsg();
		}
	}
if ( vStudBasicInfo != null) {
	vRetResult =  OTREnc.operateOnManualEncoding(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null){
		strErrMsg = OTREnc.getErrMsg();
	}
}

%>
<body bgcolor="#D2AE72">
<form action="./tor_basic_info.jsp" method="post" name="form_" id="form_">
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
        <% if (vEditInfo !=null) strTemp = "";
	  	else strTemp = WI.fillTextValue("stud_id");
	  %> <input name="stud_id" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" maxlength="16"></td>
      <td width="6%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="63%" height="18" colspan="2"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a> 
      </td>
    </tr>
  </table>
<% if (vStudBasicInfo != null) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <!--DWLayoutTable-->
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
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2"><hr size="1" noshade> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="9%">&nbsp;</td>
      <td width="91%" height="25"> Number of Columns 
        <% if(vRetResult != null) strTemp = (String)vRetResult.elementAt(4);
	else strTemp = WI.fillTextValue("num_column"); %> <input name="num_column" type="text" size="2" maxlength="1"  class="textbox" value="<%=strTemp%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > 
        <input type="hidden" name="course_index" value="<%=WI.getStrValue((String)vStudBasicInfo.elementAt(5),"")%>"> 
        <% if(vRetResult != null) strTemp = (String)vRetResult.elementAt(0);
	else strTemp = WI.fillTextValue("main_index"); %> 
        <input type="hidden" name="main_index" value="<%=WI.getStrValue(strTemp,"0")%>"> 
      </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"> Check if entries should be mixed with current school TOR 
        <input name="separate" type="checkbox" id="separate" value="checkbox"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">
	 <% if (iAccessLevel > 1) {%>
	  <a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a><font size="1">click 
        to save</font> <%if (vRetResult != null){  if ( vRetResult.size()<6){%>
		<a href="javascript:UpdateList();"><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">click 
        to update list of columns</font> <%}%>
		<a href="javascript:EncodeGrade()"><img src="../../../images/assign.gif" width="41" height="18" border="0"></a><font size="1"> click to encode grade of student</font>
<%}}%> </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() >6) {%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" class="thinborder">&nbsp;</td>
      <td class="thinborderBottom"><strong>ORDER</strong></td>
      <td class="thinborder"><strong>COLUMN NAME</strong></td>
      <td height="25" class="thinborder"><strong>COLUMN WIDTH</strong></td>
    </tr>
    <% for (int i = 5; i < vRetResult.size() ; i+=3) {%>
    <tr bgcolor="#FFFFFF"> 
      <td width="10%" height="25" class="thinborder">&nbsp; </td>
      <td width="15%" class="thinborderBottom"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td width="45%" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td width="30%" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4" class="thinborder"> <div align="center"><a href="javascript:UpdateList();"><img src="../../../images/update.gif" width="60" height="26" border="0"></a><font size="1">click 
          to update list of columns</font> </div></td>
    </tr>
  </table>
  <%} // end vRetResult.element(5) != null
  }%>
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
  <input type="hidden" name="prepareToEdit" value="<%//=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>