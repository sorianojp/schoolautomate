<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script src="../../../Ajax/ajax.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>
<script src="../../../jscript/td.js"></script>
<script language="JavaScript">
function focusID() {
	document.form_.user_id.focus();
}
function OpenSearch(strIndex) {
	var pgLoc = eval('\"../../search/search_simple.jsp?book_status=1&opner_info=form_.ACCESSION_NO'+strIndex+'\"');
	var win=window.open(pgLoc,"PrintWindow",'width=950,height=650,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ShowSchedule() {
	var loadPg = "../../../ADMIN_STAFF/enrollment/reports/student_sched.jsp?offering_sem="+document.form_.offering_sem.value+
		"&sy_from="+document.form_.sy_from.value+"&sy_to="+
		document.form_.sy_to.value+"&stud_id="+
		escape(document.form_.user_id.value)+"&show_instructor=1&reloadPage=1";

	var win=window.open(loadPg,"myfile",'dependent=no,width=900,height=655,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

function PrintReturnReceipt(strReturnCode ) {
	var loadPg = "../issue/issue_return_receipt.jsp?code_no="+strReturnCode ;
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=500,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function IncrReturnCount(chkboxObj) {
	var chkCount = document.form_.return_clicked.value;
	if(chkboxObj.checked)
		chkCount = eval(chkCount) + 1;
	else
		chkCount = eval(chkCount) - 1;
	document.form_.return_clicked.value = chkCount;
}
function ReloadPage() {
	if(document.form_.page_action.value.length == 0)
		return;
	var NoOfReturn = document.form_.return_clicked.value;
	if(NoOfReturn == "0") {
		alert("Please select atleast one book to return.");
		document.form_.page_action.value = "";
		return;
	}
	if(!confirm("Do you want to return "+NoOfReturn+" # of books")) {
		document.form_.page_action.value = "";
	}
}
function ShowHide(iIndex) {
	var vObj = "";
	eval('vObj = document.form_.book_stat'+iIndex);
	if(vObj.selectedIndex > 0)
		eval("showLayer('show_hide"+iIndex+"')");
	else
		eval("hideLayer('show_hide"+iIndex+"')");

}
//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.user_id.value;
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
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_id.value = strID;
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
<%@ page language="java" import="utility.*,lms.LmsUtil,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strUserIndex  = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation-ISSUE/RENEW","issue.jsp");
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
														"LIB_Circulation","ISSUE/RENEW",request.getRemoteAddr(),
														"issue.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
String[] astrSchoolYrInfo = dbOP.getCurSchYr();
if(astrSchoolYrInfo == null) {
	strErrMsg = "School year not set";
}


	String strTemp         = null;
	LmsUtil lUtil          = new LmsUtil();
	lms.BookIssue bIssue   = new lms.BookIssue();
	Vector vLibUserInfo    = null;
	Vector vCirculationMsg = null;///circulation message set in patron mgmt.

	String strReturnCode       = null;
	
	boolean bolIsBasic     = false;


	Vector vBookIssueInfo  = null;//book issue information.
	boolean bolReturnSuccess = false;

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		//issue or renew here.
		strReturnCode  = bIssue.returnBookNew(dbOP, request);
		if(strReturnCode  == null)
			strErrMsg = bIssue.getErrMsg();
		else {
			strErrMsg = "Return is successful. Receipt # is "+
				"<a href='javascript:PrintReturnReceipt("+strReturnCode +
				");'>"+strReturnCode +"</a>. Click on Receipt # to print receipt";
			bolReturnSuccess = true;
		}
		///////////////////////////// FORWARD here the page ///////////////////
	}

	//frist get patron's information. if status is not active, do not issue/renew book.
	if(WI.fillTextValue("user_id").length() > 0 && strErrMsg == null) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null) {
			strErrMsg = "Patron ID : "+WI.fillTextValue("user_id")+" does not exist.";
		}
		else {		
			vLibUserInfo = lUtil.getLibraryUserInfoBasic(dbOP, strUserIndex);
			if(vLibUserInfo == null)
				strErrMsg = lUtil.getErrMsg();
			else
				bolIsBasic     = lUtil.bolIsBasic();
		}
	}


	//i have to get book issue information here. and get circulation message.
	if(vLibUserInfo != null) {
		vBookIssueInfo = lUtil.getUserBookIssueInfo(dbOP, strUserIndex);
		if(vBookIssueInfo == null && !bolReturnSuccess)
			strErrMsg = lUtil.getErrMsg();

		request.setAttribute("target_1", "1");
		vCirculationMsg = new lms.PatronInformation().operateOnCirculationMsg(dbOP, request, 4, strUserIndex);
	}


	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A", "1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};


%>
<body bgcolor="#D0E19D" onLoad="focusID();">
<form action="return.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);ReloadPage();">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251">
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>::::
          CIRCULATION : RETURN PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong>
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr>
      <td width="10%" height="23"><font size="1">Patron ID</font> </td>
      <td width="13%">
<%
strTemp = WI.fillTextValue("user_id");
if(dbOP.strBarcodeID != null)
	strTemp = dbOP.strBarcodeID;
%>	  
	  <input type="text" name="user_id" value="<%=strTemp%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" size="20" maxlength="32" onKeyUp="AjaxMapName(1);"></td>
      <td width="10%">&nbsp;</td>
      <td width="67%">
        <input type="submit" name="Proceed" value="Proceed >>" onClick="document.form_.page_action.value=''">
      <strong>
	  <font size="3">&nbsp;&nbsp;&nbsp;AY: <%=astrSchoolYrInfo[0]%> - <%=astrSchoolYrInfo[1]%>,
	  <%=astrConvertSem[Integer.parseInt(astrSchoolYrInfo[2])]%></font></strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="3"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="19" colspan="4"><div align="right">
          <hr size="1">
        </div></td>
    </tr>
  </table>
<%
if(vLibUserInfo != null && vLibUserInfo.size() > 0){
	boolean bolIsStud = false;
	if(vLibUserInfo.elementAt(0).equals("1"))
		bolIsStud = true;
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="12%" height="20"><font size="1">Patron Name</font></td>
    <td width="63%"><font size="1"><strong> <%=WebInterface.formatName((String)vLibUserInfo.elementAt(2),(String)vLibUserInfo.elementAt(3),(String)vLibUserInfo.elementAt(4),4)%> (Lastname, Firstname mi.)</strong></font></td>
    <td width="25%" rowspan="6" valign="top"><img src="../../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>"
	  width="125" height="125" border="1"></td>
  </tr>
  <tr>
    <td height="20"><font size="1">Patron Type</font></td>
    <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(5),"<font color=red>NOT ASSIGNED</font>")%> :::
      <%if(vLibUserInfo.elementAt(11) != null){%>
            <font size="2" color="#FF0000">BLOCKED STATUS</font>
            <%}%>
      </strong>
          <%if(bolIsStud) {%>
      Last SY-Term : <%=(String)vLibUserInfo.elementAt(8)%>
      <%}else if(vLibUserInfo.elementAt(8) != null){%>
      Date Resigned : <%=(String)vLibUserInfo.elementAt(8)%>
      <%}%>
    </font></td>
  </tr>
  <%if(bolIsStud) {//student 
  	if(!bolIsBasic){
  %>
  <tr>
    <td height="20"><font size="1">Course/Major</font></td>
    <td><font size="1"><strong><%=(String)vLibUserInfo.elementAt(6)%></strong></font></td>
  </tr>
  <%}%>
  <tr>
    <td height="20"><font size="1">Year Level</font></td>
	 <%
	 if(bolIsBasic)
	 	strTemp = WI.getStrValue(vLibUserInfo.elementAt(7),"&nbsp;");
	else
		strTemp = astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vLibUserInfo.elementAt(7),"0"))];
	 %>
    <td valign="top"><font size="1"><strong><%=strTemp%>&nbsp;&nbsp; 
	<%if(iAccessLevel > 0 && iAccessLevel < 4 ){%>
	<a href="javascript:ShowSchedule();"><img src="../../images/schedule_circulation.gif" width="40" height="20" border="0"></a> </strong>click to view schedule of students</font>
	<%}%>
	</td>
	
  </tr>
  <%}else{//employee%>
  <tr>
    <td height="20"><font size="1">College/Dept</font></td>
    <td><font size="1"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(6),"N/A")%></strong></font></td>
  </tr>
  <tr>
    <td height="20"><font size="1">Office</font></td>
    <td><font size="1"><strong><%=WI.getStrValue((String)vLibUserInfo.elementAt(7),"N/A")%></strong></font></td>
  </tr>
  <%}//faculty dept/stud course info.%>
  <tr>
    <td height="20" valign="top"><font size="1">Contact Addr.</font></td>
    <td valign="top"><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(10),"Not Set")%></strong></font></td>
  </tr>
  <tr>
    <td height="20" colspan="2" style="font-size:11px;"> Total Book Issued : <%=vLibUserInfo.elementAt(12)%>, Total OverDue (# due today): <%=vLibUserInfo.elementAt(13)%> <br>
      Total Reservation : <%=vLibUserInfo.elementAt(14)%>, Total Reservation Ready : <%=vLibUserInfo.elementAt(15)%> <br>
      Total Fine : <strong><%=vLibUserInfo.elementAt(16)%></strong> </td>
  </tr>
<%if(vCirculationMsg != null && vCirculationMsg.size() > 0) {%>
    <tr>
      <td height="19" style="font-size:9px; color:#FF0000; font-weight:bold" valign="top">Circulation Msg</td>
      <td colspan="2" class="thinborderALL" bgcolor="#CCCCCC">
		<%for(int i = 0,j=1; i < vCirculationMsg.size(); i += 7) {%>
			<%=j++%>.<%=vCirculationMsg.elementAt(i + 1)%><br>
	  	<%}%>
	  </td>
    </tr>
<%}%>
  <tr>
    <td height="19" colspan="3"><hr size="1"></td>
  </tr>
</table>
<%
 if(vBookIssueInfo != null && vBookIssueInfo.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="20" colspan="8" bgcolor="#9FC081" class="thinborder"><div align="center"><font size="1"><strong>ISSUE
          DETAILS</strong></font></div></td>
    </tr>
    <tr>
      <td width="15%" height="25" class="thinborder"><div align="center"><strong><font size="1">Accession#</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">Book Title </font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Issue Date </font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Due Date </font></strong></div></td>
      <td width="15%" class="thinborder" align="center"><strong><font size="1">Fine</font></strong></td>
      <td width="10%" class="thinborder" align="center"><strong><font size="1">Book Price</font></strong></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Book Return Status </font></strong></div></td>
      <td width="10%" class="thinborder" align="center"><strong><font size="1">Apply Fine</font></strong></td>
    </tr>
<%
String strOverDueCol = null; int j = 0;
//System.out.println(vBookIssueInfo);
for(int i = 1; i < vBookIssueInfo.size(); i += 21, ++j){
	if( ((String)vBookIssueInfo.elementAt(i + 1)).equals("1"))
		strOverDueCol = "#cccccc";
	else
		strOverDueCol = "";%>
    <tr bgcolor="<%=strOverDueCol%>">
      <td height="25" class="thinborder">
 	  <input type="checkbox" name="issue_index<%=j%>" value="<%=(String)vBookIssueInfo.elementAt(i + 13)%>" onClick="IncrReturnCount(document.form_.issue_index<%=j%>);">
	  <%=(String)vBookIssueInfo.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vBookIssueInfo.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vBookIssueInfo.elementAt(i + 4)%> @ <%=(String)vBookIssueInfo.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vBookIssueInfo.elementAt(i + 6)%><%=WI.getStrValue((String)vBookIssueInfo.elementAt(i + 7)," @ ","","")%></td>
      <td class="thinborder" align="right">
	  <%if(!((String)vBookIssueInfo.elementAt(i + 10)).equals("0")) {%>
		<input type="text" class="textbox" style="font-size:10px;" size="6" name="fine_a<%=j%>" value="<%=((Double)vBookIssueInfo.elementAt(i + 15)).toString()%>"><br>
		<%}///record hidden field only if fine > 0
		else {%>
		<input type="text" class="textbox" style="font-size:10px;" size="6" name="fine_a<%=j%>" value="0"><br>
		<%}%>

	  <%=(String)vBookIssueInfo.elementAt(i + 10)%>&nbsp;</td>
      <td class="thinborder" align="right"><%=WI.getStrValue(vBookIssueInfo.elementAt(i + 16),"Not set")%>&nbsp;</td>
      <td class="thinborder"><select name="book_stat<%=j%>" style="font-size:11px;" onChange="ShowHide(<%=j%>)">
	  	<option value="">OK</option>
<%
strTemp = WI.fillTextValue("book_stat");
if(strTemp.equals("Damaged"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>		<option value="Damaged">Damaged</option>
<%
if(strTemp.equals("Lost"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>		<option value="Lost">Lost</option>
	  </select>	  </td>
      <td class="thinborder" align="center"><input type="text" class="textbox" style="font-size:10px;"
	  		value="" size="6" name="fine_<%=j%>" id="show_hide<%=j%>"></td>
    </tr>
<script language="javascript">
	this.ShowHide(<%=j%>);
</script>
<input type="hidden" name="book_i<%=j%>" value="<%=(String)vBookIssueInfo.elementAt(i)%>">
<%}%>
<input type="hidden" name="max_to_return" value="<%=vBookIssueInfo.size()/16%>">
  </table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"><div align="center">
	  <input type="submit" name="Save" value="Return Books >>>" onClick="document.form_.page_action.value=1;">
      </div></td>
      <td>&nbsp;</td>
    </tr>

  </table>
<%}//show if book issue information is not null - vBookIssueInfo
}//only if vLibUserInfo not null.

if(astrSchoolYrInfo != null) {%>
	<input type="hidden" name="sy_from" value="<%=astrSchoolYrInfo[0]%>">
	<input type="hidden" name="sy_to" value="<%=astrSchoolYrInfo[1]%>">
	<input type="hidden" name="offering_sem" value="<%=astrSchoolYrInfo[2]%>">
<%}%>

<input type="hidden" name="page_action">
<input type="hidden" name="return_clicked" value="0">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
