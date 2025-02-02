<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script src="../../jscript/common.js"></script>
<script src="../../Ajax/ajax.js"></script>
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
	if(strReceiptCode.length == 0) {
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
	var strURL = "../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.user_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";	
	
}
function UpdateName(strFName, strMName, strLName) {
	document.form_.submit();
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

	boolean bolShowIDInput = true;
	if(WI.fillTextValue("myhome").length() > 0)
		bolShowIDInput = false;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Circulation".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
		bolShowIDInput = false;

//end of authenticaion code.

	try
	{
		dbOP = new DBOperation();
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

	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");

	Vector vLibUserInfo = null; //Vector vFineOutstanding = null;
	Vector vRetResult   = null; Vector vEditInfo = null;
	LmsUtil lUtil    = new LmsUtil();
	boolean bolIsBasic  = false;
	String strUserID = WI.fillTextValue("user_id");
	if(bolShowIDInput && strUserID.length() > 0 ) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null)
			strErrMsg = "ID : "+WI.fillTextValue("user_id")+" does not exist in system.";
	}
	else if(!bolShowIDInput) {
		strUserID = (String)request.getSession(false).getAttribute("userId");
		strUserIndex = (String)request.getSession(false).getAttribute("userIndex");
	}
//// get user information.
	if(strUserIndex != null ) {
		vLibUserInfo = lUtil.getLibraryUserInfoBasic(dbOP, strUserIndex);
		if(vLibUserInfo == null)
			strErrMsg = lUtil.getErrMsg();
		else{
			bolIsBasic = lUtil.bolIsBasic();
		}

		lms.PatronInformation pInfo = new lms.PatronInformation();
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0) {
			if(pInfo.operateOnCirculationMsg(dbOP, request, Integer.parseInt(strTemp), strUserIndex) == null)
				strErrMsg = pInfo.getErrMsg();
			else {
				if(strTemp.equals("0"))
					strErrMsg = "Message removed successfully.";
				else if(strTemp.equals("1"))
					strErrMsg = "Message added successfully.";
				else
					strErrMsg = "Message edited successfull.";
			}
		}
		if(strPreparedToEdit.equals("1"))
			vEditInfo = pInfo.operateOnCirculationMsg(dbOP, request, 3, strUserIndex);
		vRetResult = pInfo.operateOnCirculationMsg(dbOP, request, 4, strUserIndex);
		if(strErrMsg == null && vRetResult == null)
			strErrMsg = pInfo.getErrMsg();
}




	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A", "1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};

String strMyHome = WI.fillTextValue("myhome");
%>
<body bgcolor="#D0E19D">
<form action="./patron_msg.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#77A251"><div align="center"><font color="#FFFFFF" ><strong>::::
        PATRON INFORMATION MAIN PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
</table>
<jsp:include page="./inc.jsp?pgIndex=5&user_id=<%=strUserID%>&myhome=<%=strMyHome%>"></jsp:include>

    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="10%"><font size="1">Patron ID</font></td>
        <td width="13%">
<%if(bolShowIDInput){%>
		<input type="text" name="user_id" value="<%=WI.fillTextValue("user_id")%>"
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'"  onKeyUp="AjaxMapName();"
		onBlur="style.backgroundColor='white'" size="20" maxlength="32">
<%}else{%>
		<%=strUserID%>
<%}%>		</td>
        <td width="17%">&nbsp;&nbsp;&nbsp;
         <%if(bolShowIDInput){%><input type="submit" name="Proceed" value="Proceed >>"><%}%>		</td>
        <td width="60%">
		  		<label id="coa_info" style="position:absolute; width:500px;"></label>
		  </td>
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
      <td width="25%" <%=strTemp%>  valign="top"><img src="../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>"
	  width="100" height="100" border="1"></td>
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
      <td valign="top"><font size="1"><strong><%=strTemp%></strong>&nbsp;&nbsp; 
	  <!--<a href="javascript:ShowSchedule();"><img src="../images/schedule_circulation.gif" width="40" height="20" border="0"></a>
        click to view schedule of student--></font></td>
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
      <td height="19" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(bolShowIDInput){//do not show if called from home page.%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="12%" style="font-size:11px;">Message</td>
    <td width="88%">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("message");
%>	<textarea name="message" cols="50" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
  </tr>
  <tr>
    <td style="font-size:11px;">Msg. Target </td>
    <td style="font-size:11px;">
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else
	strTemp = WI.fillTextValue("target_0");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>	<input type="checkbox" name="target_0" value="1"<%=strTemp%>> Show in Book Issue
<%
if(vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("target_1");
if(strTemp.equals("1"))
	strTemp = " checked";
else
	strTemp = "";
%>	<input type="checkbox" name="target_1" value="1"<%=strTemp%>> Show in Book Return	</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td style="font-size:11px;" align="center">
<%if(strPreparedToEdit.equals("1")){%>
	<input name="submit1" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=2;document.form_.preparedToEdit.value='';document.form_.info_index.value='<%=WI.fillTextValue("info_index")%>'" value="Edit Message >>">
<%}else{%>
	<input name="submit2" type="submit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value=1;document.form_.preparedToEdit.value=''" value="Save Message >>">
<%}%></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td style="font-size:11px;" align="center">&nbsp;</td>
  </tr>

</table>
<%}//do not show if called from home page. --> bolShowIDInput = true,
}//show only if vLibUserInfo is not null
if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#9FcFFF">
    <td width="55%" height="20" class="thinborder" align="center"><strong>Message</strong></td>
    <td width="15%" class="thinborder" align="center"><strong>In Book Issue </strong></td>
    <td width="15%" class="thinborder" align="center"><strong>In Book Return </strong></td>
<%if(bolShowIDInput){%>
    <td width="7%" class="thinborder" align="center"><strong>Edit</strong></td>
    <td width="8%" class="thinborder" align="center"><strong>Delete</strong></td>
    <%}%>
  </tr>
<%for(int i =0; i < vRetResult.size(); i += 7){%>
  <tr>
    <td height="20" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
    <td class="thinborder" align="center">
	<%if(vRetResult.elementAt(i + 2).equals("1")){%><img src="../../images/tick.gif" border="1"><%}else{%>
	<img src="../../images/x_small.gif" border="1"><%}%>
	</td>
    <td class="thinborder" align="center">
	<%if(vRetResult.elementAt(i + 3).equals("1")){%><img src="../../images/tick.gif" border="1"><%}else{%>
	<img src="../../images/x_small.gif" border="1"><%}%>
	</td>
<%if(bolShowIDInput){%>
    <td class="thinborder" align="center">
		<input name="submit" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='1';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>';" value="&nbsp;Edit&nbsp;">
	</td>
    <td class="thinborder" align="center">
	<input name="submit2" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='0';document.form_.preparedToEdit.value='';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>';" value="Delete"></td>
<%}%>
  </tr>
<%}%>
</table>
<%}//if vRetResult is not null%>

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

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">

<input type="hidden" name="myhome" value="<%=WI.fillTextValue("myhome")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
