<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
a:link {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:visited {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:active {
	color: #FFFFFF;
	text-decoration:none;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
	}
a:hover {
	color:#f00;
	font-weight:700;
	}
.tabFont {
	color:#444444;
	font-weight:700;
	font-size:12px;
	font-family:"lucida grande", "trebuchet ms", sans;
}
</style>
</head>
<script src="../../../jscript/common.js"></script>
<script src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function SavePayment(iIndex) {
	document.form_.page_action.value = "1";
	document.form_.index_.value = iIndex;
}
function focusID() {
	document.form_.user_id.focus();
}
function PrintReceipt(strReceiptCode) {
	var loadPg = "./fine_pmt_receipt.jsp?code_no="+strReceiptCode;
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=500,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrintReceipt2() {
	//get receipt # and call printReceipt
	var strReceiptCode = prompt("Please enter Payment Receipt #", "");
	if(strReceiptCode == null || strReceiptCode.length == 0) {
		alert("To Print payment receipt, please enter receipt Number.");
		return;
	}
	return PrintReceipt(strReceiptCode);
}
function NewFine(strUserIndex) {
	if(strUserIndex.length == 0) {
		alert("Please enter Patron's ID and click proceed.");
		return;
	}
	var loadPg = "./fine_post.jsp?user_i="+strUserIndex;
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=500,top=45,left=45,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PayBalance(strUserIndex) {
	if(strUserIndex.length == 0) {
		alert("Please enter Patron's ID and click proceed.");
		return;
	}
	var loadPg = "./fine_paybalance.jsp?user_i="+strUserIndex;
	var win=window.open(loadPg,"myfile",'dependent=no,width=600,height=300,top=200,left=200,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FullLedger(strUserIndex) {
	if(strUserIndex.length == 0) {
		alert("Please enter Patron's ID and click proceed.");
		return;
	}
	var bolIsPrint = "";
	if(confirm("Do you want to print?"))
		bolIsPrint = "1";
	var loadPg = "./full_ledger.jsp?user_i="+strUserIndex+"&print_="+bolIsPrint;
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=600,top=50,left=50,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
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
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation-Patrons Fine".toUpperCase()),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation".toUpperCase()),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Circulation-FineMgmt","fine_main_page.jsp");
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
	boolean bolIsBasic  = false;
	String[] astrSchoolYrInfo = dbOP.getCurSchYr();
	Vector vLibUserInfo = null; Vector vFineOutstanding = null;
	LmsUtil lUtil    = new LmsUtil();
//// get user information.
	if(WI.fillTextValue("user_id").length() > 0) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null) {
			strErrMsg = "ID : "+WI.fillTextValue("user_id")+" does not exist in system.";
		}
		else {
			lms.FineManagement fineMgmt = new lms.FineManagement();
			///if page action = 1, i must save fine.
			if(WI.fillTextValue("page_action").equals("1")) {
				strTemp = fineMgmt.payFineSingle(dbOP, strUserIndex, request);
				if(strTemp != null)
					strErrMsg = "Fine Payment successful. Payment Receipt # is "+
						"<a href='javascript:PrintReceipt("+strTemp+
						");'><font size=3>"+strTemp+"</font></a>. Click on Receipt # to print receipt";
				else
					strErrMsg = fineMgmt.getErrMsg();
			}
			vFineOutstanding = fineMgmt.getOutstandingFine(dbOP, strUserIndex);

			vLibUserInfo = lUtil.getLibraryUserInfoBasic(dbOP, strUserIndex);
			if(vLibUserInfo == null)
				strErrMsg = lUtil.getErrMsg();
			else 
				bolIsBasic = lUtil.bolIsBasic();
		}
	}


	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A", "1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};



%>
<body bgcolor="#D0E19D" onLoad="focusID();">
<form action="./fine_main_page.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>::::
        FINE MANAGEMENT MAIN PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
</table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td background="../../images/tableft_selected.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#a9b9d1" align="center" class="tabFont">Summary</td>
        <td background="../../images/tabright_selected.gif" width="10">&nbsp;</td>
        <td width="2">&nbsp;</td>
        <td background="../../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="70" bgcolor="#000000" align="center"><a href="javascript:NewFine('<%=WI.getStrValue(strUserIndex)%>');">New Fine</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
        <td width="2">&nbsp;</td>
        <td background="../../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="90" bgcolor="#000000" align="center"><a href="javascript:PayBalance('<%=WI.getStrValue(strUserIndex)%>');">Pay Balance</a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
        <td width="2">&nbsp;</td>
        <td background="../../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="100" bgcolor="#000000" align="center"><a href="javascript:FullLedger('<%=WI.getStrValue(strUserIndex)%>');">View Full Ledger </a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
        <td width="2">&nbsp;</td>
        <td background="../../images/tableft.gif" height="28" width="10">&nbsp;</td>
        <td width="90" bgcolor="#000000" align="center"><a href="javascript:PrintReceipt2();">Print Receipt </a></td>
        <td background="../../images/tabright.gif" width="10">&nbsp;</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td height="10" colspan="12" valign="top" class="thinborderTOP">&nbsp;</td>
      </tr>
	</table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="10%"><font size="1">Patron ID</font></td>
        <td width="13%"><input type="text" name="user_id" value="<%=WI.fillTextValue("user_id")%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AjaxMapName();"
		onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
        <td width="14%">&nbsp;&nbsp;&nbsp;
          <input type="submit" name="Proceed" value="Proceed >>"></td>
        <td width="63%"><label id="coa_info" style="position:absolute; width:500px;"></label></td>
      </tr>
      <%if(strErrMsg != null){%>
      <tr>
        <td colspan="4"><font size="3" color="#666633"><b><%=strErrMsg%></b></font></td>
      </tr>
      <%}%>
      <tr>
        <td colspan="4"><hr size="1"></td>
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
      <td width="63%"><font size="1"><strong>
	  <%=WebInterface.formatName((String)vLibUserInfo.elementAt(2),(String)vLibUserInfo.elementAt(3),(String)vLibUserInfo.elementAt(4),4)%> (Lastname, Firstname mi.)</strong></font></td>
	  <%
		if(bolIsBasic)
			strTemp = "rowspan='4'";
		else	
			strTemp = "rowspan='6'";
		%>
      <td width="25%" <%=strTemp%> valign="top"><img src="../../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>"
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
	  	<a href="javascript:ShowSchedule();"><img src="../../images/schedule_circulation.gif" width="40" height="20" border="0"></a>
        </strong>click to view schedule of students</font></td>
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
      <td height="20" colspan="2" style="font-size:11px;">
	  Total Book Issued : <%=vLibUserInfo.elementAt(12)%>, Total OverDue (# due today): <%=vLibUserInfo.elementAt(13)%>
	  <br>
	  Total Reservation : <%=vLibUserInfo.elementAt(14)%>, Total Reservation Ready : <%=vLibUserInfo.elementAt(15)%>
	  <br>
	  Total Fine : <strong><%=vLibUserInfo.elementAt(16)%></strong>	  </td>
    </tr>
    <tr>
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%}//show only if vLibUserInfo is not null
if(vFineOutstanding != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="20" colspan="7" bgcolor="#9FC081" class="thinborder" align="center">
		  <font size="1"><strong>:::: FINE OUTSTANDING DETAILS ::::</strong></font></td>
    </tr>
    <tr>
      <td width="10%" height="25" class="thinborder"><div align="center"><strong><font size="1">ACCESSION # </font></strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong><font size="1">TITLE</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">FINE TYPE </font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">FINE BALANCE </font></strong></div></td>
      <td colspan="3" align="center" class="thinborder"><font size="1"><strong>PAYMENT</strong></font></td>
    </tr>
<%for(int i =0,j=0; i < vFineOutstanding.size(); i += 6,++j){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(vFineOutstanding.elementAt(i))%></td>
      <td class="thinborder"><%=WI.getStrValue(vFineOutstanding.elementAt(i + 1))%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=vFineOutstanding.elementAt(i + 2)%>&nbsp;</td>
      <td class="thinborder" align="right"><%=vFineOutstanding.elementAt(i + 4)%>&nbsp;</td>
      <td width="17%" align="center" class="thinborder">&nbsp;<font size="1">PMT:</font>
	  <input type="text" class="textbox" style="font-size:10px;"
	  		value="<%=vFineOutstanding.elementAt(i + 4)%>" size="6" name="pmt_<%=j%>">
	  </td>
      <td width="17%" align="center" class="thinborder">&nbsp;<font size="1">WAIVE:</font>
	  <input type="text" class="textbox" style="font-size:10px;" value="0.0" size="6" name="waive_<%=j%>">
	  </td>
      <td width="11%" align="center" class="thinborder">
	  <input type="submit" name="1" value="Save Pmt" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	   onClick="SavePayment('<%=j%>');"></td>
    </tr>
<input type="hidden" name="fine_index_<%=j%>" value="<%=vFineOutstanding.elementAt(i + 5)%>">
<%}%>
</table>
<%}//if vFineOutstanding is not null.. %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#77A251">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>

<%if(astrSchoolYrInfo != null) {%>
	<input type="hidden" name="sy_from" value="<%=astrSchoolYrInfo[0]%>">
	<input type="hidden" name="sy_to" value="<%=astrSchoolYrInfo[1]%>">
	<input type="hidden" name="offering_sem" value="<%=astrSchoolYrInfo[2]%>">
<%}%>
<input type="hidden" name="page_action">
<input type="hidden" name="index_"><!-- to save index -->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
