<%
/**
	boolean bolAllowPrevSY = false;

	if((new ReadPropertyFile().getImageFileExtn("issue_book_allow_prev_sy","0")).equals("1"))
		bolAllowPrevSY = true;
	
	String strPreSY = null;	
	if(bolAllowPrevSY){
		strPreSY = (String)new ReadPropertyFile().getImageFileExtn("issue_book_prev_sy","0");
	}
**/	
	
		
%>
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
<script language="JavaScript">
function ReloadPage() {
	document.form_.page_action.value = "";
}

function ViewBorrowingHistory(strUserId){
	var loadPg = "borrowing_history_dbtc.jsp?user_id="+strUserId+"&view_all=1";
	var win=window.open(loadPg,"ViewBorrowingHistory",'dependent=no,width=900,height=655,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function focusID() {
	///I have to focus the barcodes if barcode is shown.. otherwise only ID.. 
	
	var obj = document.form_.ACCESSION_NO0;
	if(!obj) {
		document.form_.user_id.focus();
		return;
	}
	if(obj.value.length == 0) {
		obj.focus();
		return;
	}
	var iCount = 1;
	while(true) {
		eval('obj=document.form_.ACCESSION_NO'+iCount);
		if(!obj) {
			--iCount;
			eval('obj=document.form_.ACCESSION_NO'+iCount);
			obj.focus();
			return;
		}
		if(obj.value.length == 0) {
			obj.focus();
			return;
		}
		++iCount;
	}
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
function ResetPrevAction() {
	document.form_.page_action.value = "";
/**
	var iMaxHiddenRow = document.form_.max_to_issue.value;
	for(var i = 0; i < iMaxHiddenRow; ++i) {
		eval('document.form_.hidden_row'+i+'.value = ""');
	}
**/	document.form_.submit();
}
//iIndex = i in jsp.
function delTD(iTD, iIndex) {
	//I have to remove 4 rows, iTD = accession no - leave 2 rows.
	eval('document.form_.hidden_row'+iIndex+'.value = 1');
	for(var i = 0; i < iIndex; ++i) {
		if(eval('document.form_.hidden_row'+i+'.value.length > 0') )
			iTD = eval(iTD) - 4; 
	}//alert(iTD);
	this.deleteTableRow(iTD);
	this.deleteTableRow(iTD);
	this.deleteTableRow(iTD);
	this.deleteTableRow(iTD);
	
}
function PrintIssueReceipt(strIssueCode) {
	var loadPg = "./issue_return_receipt.jsp?is_issue=1&code_no="+strIssueCode;
	var win=window.open(loadPg,"myfile",'dependent=no,width=700,height=500,top=5,left=5,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function RenewMsg(iIndex,strMsg) {
	var chkboxObj;
	eval('chkboxObj = document.form_.issue_index'+iIndex);
	if(!chkboxObj.checked)
		return;
	if(strMsg == 'null')
		return;
	if(confirm("Renew not allowed. Message : "+strMsg+". Do you still want to allow renew ?"))
		return;
	chkboxObj.checked=false;
}


///////////////////////////////////////// used to collapse and expand filter ////////////////////
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else if(objBranch.display=="none")
		objBranch.display="block";
	else	
		objBranch.display="none";	
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
///////////////////////////////////////// End of collapse and expand filter ////////////////////

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
	var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+
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




	String strSchCode = dbOP.getSchoolIndex();
	if(strSchCode == null)
		strSchCode = "";	
	boolean bolIsDBTC = strSchCode.startsWith("DBTC");

	String strTemp         = null;
	LmsUtil lUtil          = new LmsUtil();
	lms.BookIssue bIssue   = new lms.BookIssue();
	Vector vLibUserInfo    = null;
	
	Vector vBookInfo       = null;
	Vector vBookRenewInfo  = null;//BOOK RENEW INFORMATION.
	Vector vCirculationMsg = null;///circulation message set in patron mgmt.
	
	String[] astrBookStat  = null;
	String strBookIndex    = null;//get from accession number. 
	
	String strPatronTypeIndex = null;
	String strIssueCode       = null; boolean bolIssueSuccess = false;
	
	
	Vector vBPInfo         = null;//this gives if user is allowed to issue / renew a book- borrowing parameter information. 
	//if so, how many books is he allowed to issue.
	Vector vBookIssueInfo  = null;//book issue information.
	//Vector vTempInfo       = null;//temp vector to store adhoc data.
	int iMaxToIssue        = 0;//max number of book can be issued to this user.
	
	//frist get patron's information. if status is not active, do not issue/renew book.
	if(WI.fillTextValue("user_id").length() > 0 && strErrMsg == null) {
		strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("user_id"));
		if(strUserIndex == null) {
			strErrMsg = "Patron ID : "+WI.fillTextValue("user_id")+" does not exist.";
		}
		else {
		
			//if sy-term is 2013-2014 first sem, but the student is enrolled in summer then astrSchoolYrInfo will get 2012-2013 summer
			//this is only if first sem		
			
			vLibUserInfo = lUtil.getLibraryUserInfo(dbOP, strUserIndex, astrSchoolYrInfo[0], astrSchoolYrInfo[1], astrSchoolYrInfo[2]);
			if(vLibUserInfo == null) {//may be enrolled in preve sy-term.. 			
				String strSQLQuery = "select prop_val from read_property_file where prop_name = 'issue_book_allow_prev_sy'";
				strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery,0);
				if(strSQLQuery != null && strSQLQuery.equals("1")) {
					if(astrSchoolYrInfo[2].equals("1")) {
						astrSchoolYrInfo[0] = Integer.toString(Integer.parseInt(astrSchoolYrInfo[0]) - 1);
						astrSchoolYrInfo[1] = Integer.toString(Integer.parseInt(astrSchoolYrInfo[1]) - 1);
						astrSchoolYrInfo[2] = "0";
					}
					else if(astrSchoolYrInfo[2].equals("0")) {
						astrSchoolYrInfo[2] = "2";
					}
					else {
						astrSchoolYrInfo[2] = Integer.toString(Integer.parseInt(astrSchoolYrInfo[2]) - 1);
					}
					vLibUserInfo = lUtil.getLibraryUserInfo(dbOP, strUserIndex, astrSchoolYrInfo[0], astrSchoolYrInfo[1], astrSchoolYrInfo[2]);
					//System.out.println();
					if(vLibUserInfo == null)
						strErrMsg = lUtil.getErrMsg();
				}				
			}
			else {
				if(lUtil.bolIsBasic()) {
					if(!astrSchoolYrInfo[2].equals("1"))
						astrSchoolYrInfo[2] = "1";
				}
			}
		}				
	}
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		//issue or renew here.
		strIssueCode = bIssue.issueBookNew(dbOP, request);
		if(strIssueCode == null)
			strErrMsg = bIssue.getErrMsg();
		else {
			strErrMsg = bIssue.getErrMsg()+". Receipt # is "+
				"<a href='javascript:PrintIssueReceipt("+strIssueCode+
				");'>"+strIssueCode+"</a>. Click on Receipt # to print receipt";
			bolIssueSuccess = true;
		}
		
		///////////////////////////// FORWARD here the page ///////////////////
		
	}

boolean bolIssueAllowed = true;

	//I have to now get borrowing parameter information her.e 
	if(vLibUserInfo != null && vLibUserInfo.size() > 0 && vLibUserInfo.elementAt(15) == null ) {//if active user.
		vBPInfo = lUtil.getUserBorrowInfo(dbOP, strUserIndex);
		if(vBPInfo == null) 
			strErrMsg = lUtil.getErrMsg();
		else {
			strPatronTypeIndex = (String)vBPInfo.elementAt(1);
			if(vBPInfo.elementAt(12).equals("0"))
				bolIssueAllowed = false;
		}
	}
	//i have to get book issue information here.  and circulation message.
	

	
	if(vLibUserInfo != null && vBPInfo != null) {
		vBookIssueInfo = lUtil.getUserBookIssueInfo(dbOP, strUserIndex);
		
		request.setAttribute("target_0", "1");
		vCirculationMsg = new lms.PatronInformation().operateOnCirculationMsg(dbOP, request, 4, strUserIndex);
	}


	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	String[] astrConvertYrLevel = {"N/A", "1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};

	String[] astrTime     = {"8","9","10","11","12","13","14","15","16","17","18","19","20","21"};
	String[] astrTimeDisp = {"8AM","9AM","10AM","11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM","9PM"};
	
/// true only if any accession number is entered
boolean bolReadyToIssue = false;
boolean bolRenewAvailable = false;

%>
<body bgcolor="#D0E19D" onLoad="focusID();">
<form action="./issue.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CIRCULATION : ISSUE PAGE ::::</strong></font></div></td>
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
		onBlur="style.backgroundColor='white'" size="20" maxlength="32" onKeyUp="AjaxMapName();"></td>
      <td width="10%">&nbsp;</td>
      <td width="67%"><a href="javascript:ResetPrevAction();" tabindex="-1"><img src="../../images/form_proceed.gif" border="0"></a><strong>
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
if(vLibUserInfo != null && vLibUserInfo.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="12%" height="20"><font size="1">Patron Name</font></td>
      <td width="45%"><font size="1"><strong><%=WebInterface.formatName((String)vLibUserInfo.elementAt(2),(String)vLibUserInfo.elementAt(3),
	  		(String)vLibUserInfo.elementAt(4),4)%> (Lastname, Firstname mi.)</strong></font></td>
	  <%if(true){%>
	  <td rowspan="2" valign="top">
	  <a href="javascript:ViewBorrowingHistory('<%=WI.fillTextValue("user_id")%>');">
	  <img src="../../images/form_proceed.gif" border="0"></a>
	  <br><font size="1">Click to view borrowing history</font>
	   &nbsp; &nbsp; &nbsp; </td>
	   <%}%>
      <td width="25%" rowspan="6" valign="top"><img src="../../../upload_img/<%=WI.fillTextValue("user_id").toUpperCase() + "."+(String)request.getSession(false).getAttribute("image_extn")%>" 
	  width="125" height="125" border="1"></td>
    </tr>
    <tr> 
      <td height="20"><font size="1">Patron Type</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(5),"<font color=red>NOT ASSIGNED</font>")%> ::: 
        <%if(vLibUserInfo.elementAt(15) == null){%>
        ACTIVE 
        <%}else{%>
        <font size="2" color="#FF0000">BLOCKED</font> (Can't issue/renew) 
        <%}%>
        </strong></font></td>
    </tr>
    <%
if( ((String)vLibUserInfo.elementAt(0)).compareTo("1") == 0) {//student %>
    <tr> 
      <td height="20"><font size="1">Course/Major</font></td>
      <td><font size="1"><strong><%=(String)vLibUserInfo.elementAt(6)%><%=WI.getStrValue((String)vLibUserInfo.elementAt(7),"/","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="20"><font size="1">Year Level</font></td>
      <td valign="top"><font size="1"><strong><%=astrConvertYrLevel[Integer.parseInt(WI.getStrValue(vLibUserInfo.elementAt(8),"0"))]%>&nbsp;&nbsp; 
	 
	  <a href="javascript:ShowSchedule();" tabindex="-1"><img src="../../images/schedule_circulation.gif" width="40" height="20" border="0"></a>
	  
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
      <td height="20"><font size="1">Contact Addr.</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(12),"Not Set")%></strong></font></td>
    </tr>
    <tr> 
      <td height="20"><font size="1">Contact Nos.</font></td>
      <td><font size="1"><strong><%=WI.getStrValue(vLibUserInfo.elementAt(13),"Not Set")%></strong></font></td>
    </tr>
<%if(vCirculationMsg != null && vCirculationMsg.size() > 0) {%>
    <tr> 
      <td height="19" style="font-size:9px; color:#FF0000; font-weight:bold" valign="top">Circulation Msg</td>
      <td colspan="3" class="thinborderALL" bgcolor="#CCCCCC">
		<%for(int i = 0,j=1; i < vCirculationMsg.size(); i += 7) {%>	  
			<%=j++%>.<%=vCirculationMsg.elementAt(i + 1)%><br>
	  	<%}%>	  </td>
    </tr>
<%}%>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
 <%
 if(vBookIssueInfo != null && vBookIssueInfo.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="20" colspan="7" bgcolor="#9FC081" class="thinborder"><div align="center"><font size="1"><strong>ISSUE 
          DETAILS</strong></font> (Red color books have reached max renew #) </div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" class="thinborder"><div align="center"><strong><font size="1">ACCESSION # </font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">TITLE</font></strong></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1">ISSUE DATE </font></strong></div></td>
      <td width="13%" class="thinborder"><div align="center"><strong><font size="1">DUE DATE</font></strong></div></td>
      <td width="15%" class="thinborder" align="center"><strong><font size="1">FINE</font></strong></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">RESERVED BY </font></strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>
	  	<font size="1"><u>&nbsp;&nbsp;&nbsp;&nbsp;RENEW&nbsp;&nbsp;&nbsp;&nbsp;</u> <br>SPECIAL DUE DATE/TIME</font></strong></div></td>
    </tr>
<%
String strRenewCol = null; String strOverDueCol = null; int j = 0;
boolean bolCanRenew = false;
//System.out.println(vBookIssueInfo);
for(int i = 1; i < vBookIssueInfo.size(); i += 21, ++j){bolRenewAvailable = true;
	//vTempInfo = bIssue.getBookToIssueInfo(dbOP,null,strUserIndex,(String)vBookIssueInfo.elementAt(i));
	vBookRenewInfo = bIssue.getBookToRenewInfo(dbOP, (String)vBookIssueInfo.elementAt(i), strUserIndex);
	if(vBookRenewInfo == null) {
		bolCanRenew	= false;
		strErrMsg = bIssue.getErrMsg();
	}
	else {
		bolCanRenew = true;
		strErrMsg   = null;
	}
		 
	if(vBookIssueInfo.elementAt(i + 11) == null)
		strRenewCol = " color=black";
	else	
		strRenewCol = " color=red";
	if( ((String)vBookIssueInfo.elementAt(i + 1)).equals("1"))
		strOverDueCol = "#cccccc";
	else	
		strOverDueCol = "";%>
    <tr bgcolor="<%=strOverDueCol%>"> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vBookIssueInfo.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vBookIssueInfo.elementAt(i + 3)%></td>
      <td class="thinborder">&nbsp;<%=(String)vBookIssueInfo.elementAt(i + 4)%> @ <%=(String)vBookIssueInfo.elementAt(i + 5)%></td>
      <td class="thinborder">&nbsp;<%=(String)vBookIssueInfo.elementAt(i + 6)%><%=WI.getStrValue((String)vBookIssueInfo.elementAt(i + 7)," @ ","","")%></td>
      <td class="thinborder">&nbsp;<%=(String)vBookIssueInfo.elementAt(i + 10)%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="center">
<%if(bolCanRenew){%>
	  <input type="checkbox" name="issue_index<%=j%>" value="<%=(String)vBookIssueInfo.elementAt(i + 13)%>" 
	  onClick="RenewMsg('<%=j%>','<%=vBookIssueInfo.elementAt(i + 11)%>');" tabindex="-1"><br>
	  <!-- Print here special date and time for issue.. ---->
	  
<%
strTemp = request.getParameter("BORROWING_DUE_R"+j);//due date.
if(strTemp == null) {
	strTemp = (String)vBookRenewInfo.elementAt(0);
	strErrMsg = bIssue.getReturnDateAfterRemovingClosedDays(dbOP, strTemp);
	if(strErrMsg != null)
		strTemp = strErrMsg;
}
%>   
        <input name="BORROWING_DUE_R<%=j%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.getStrValue(strTemp)%>" tabindex="-1">
        <a href="javascript:show_calendar('form_.BORROWING_DUE_R<%=j%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"><img src="../../../images/calendar_new.gif" border="0"></a></font>
		<select name="BORROWING_DUE_TIME_R<%=j%>" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;" tabindex="-1">
		<option value="">N/A</option>
		<%
		strTemp = request.getParameter("BORROWING_DUE_TIME_R"+i);
		if(strTemp == null) 
			strTemp = (String)vBookRenewInfo.elementAt(1);
		if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.compareTo(astrTime[p]) == 0){%>
			<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
		<%}else{%>
			<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
		<%}//end of else.
		}//end of for%>
		</select>
	  
	  
	  
<%}else{%>Can't Renew<%}%>
	 </td>
    </tr>
    <tr>
      <td height="25" colspan="7" class="thinborder">&nbsp; <font <%=strRenewCol%>>Renew Message : 
	  <%=(String)vBookIssueInfo.elementAt(i + 12)%>
	  <%=WI.getStrValue(strErrMsg,"<br>Can't Renew Msg :","","")%></font></td>
    </tr>
<%if(bolCanRenew){%>
<input type="hidden" name="FINE_INCR_R<%=j%>" value="<%=(String)vBookRenewInfo.elementAt(3)%>">
<input type="hidden" name="FINE_UNIT_R<%=j%>" value="<%=(String)vBookRenewInfo.elementAt(4)%>">
<input type="hidden" name="FINE_MAX_R<%=j%>" value="<%=(String)vBookRenewInfo.elementAt(5)%>">
<input type="hidden" name="FINE_GRACE_R<%=j%>" value="<%=(String)vBookRenewInfo.elementAt(6)%>">
<input type="hidden" name="MAX_RENEW_R<%=j%>" value="<%=(String)vBookRenewInfo.elementAt(7)%>">
<%}%>

<input type="hidden" name="book_i<%=j%>" value="<%=(String)vBookIssueInfo.elementAt(i)%>">
<input type="hidden" name="renew_i<%=j%>" value="<%=(String)vBookIssueInfo.elementAt(i + 14)%>">
<%if(!((String)vBookIssueInfo.elementAt(i + 10)).equals("0")) {%>
<input type="hidden" name="fine_a<%=j%>" value="<%=((Double)vBookIssueInfo.elementAt(i + 15)).toString()%>">
<%}///record hidden field only if fine > 0
}%>
<input type="hidden" name="max_renew_list" value="<%=vBookIssueInfo.size()/16%>">
  </table>
<%}//show if book issue information is not null - vBookIssueInfo






















if(vBPInfo != null && vBPInfo.size() > 0) {	
if(!bolIssueAllowed) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td style="font-size:14px; color:#FF0000">Can't Issue ::: System Message :<%=vBPInfo.elementAt(13)%></td>
		<td></td>
	</tr>

  	<tr>
		<td>To Override system setting and allow book issue check here : 
<%
if(WI.fillTextValue("force_issue").length() > 0) {
	strTemp = " checked";
	bolIssueAllowed = true;
}
else	
	strTemp = "";
%>	    <input type="checkbox" name="force_issue" value="1"<%=strTemp%> onClick="document.form_.submit();" tabindex="-1">
	    (allow book issue) </td>
		<td></td>
	</tr>
  </table>
<%}%>  



  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <%
if(bolIssueAllowed || bolRenewAvailable){//is allowed to issue
iMaxToIssue = Integer.parseInt((String)vBPInfo.elementAt(3)) - Integer.parseInt((String)vBPInfo.elementAt(10));



if(iMaxToIssue <=0 && bolIssueAllowed) /// because force_issue is clicked.
	iMaxToIssue = 1;
for(int i = 0; i < iMaxToIssue; ++i){  
strErrMsg = null;vBookIssueInfo = null;
strTemp = WI.fillTextValue("ACCESSION_NO"+i);
if(strTemp.length() > 0) {
	if(!bolIssueSuccess)
		vBookIssueInfo = bIssue.getBookToIssueInfo(dbOP,strTemp,strUserIndex);
 	if(vBookIssueInfo == null) {
 		strErrMsg = bIssue.getErrMsg();
		strTemp = "";
	}
	else {
		if(!vBookIssueInfo.elementAt(20).equals("Available"))
			strErrMsg = "Book Status is :"+vBookIssueInfo.elementAt(20)+". Book can't be issued.";
			//strTemp = "";
	}
}		
if(bolIssueAllowed){%>
		<tr> 
		  <td width="22%" height="25"><font size="1">Accession / Barcode. 
		  <input type="hidden" name="hidden_row<%=i%>" value="<%=WI.fillTextValue("hidden_row"+i)%>">
	 <%if(strErrMsg == null && vBookIssueInfo != null){%>
		  <br>
		  <div class="trigger" onClick="showBranch('branch<%=i%>');swapFolder('folder<%=i%>')">
			<img src="../../../images/box_with_minus.gif" width="7" height="7" border="0" id="folder<%=i%>">
			&nbsp;&nbsp; <b><u>Book Detail</u></b></div> 
	 <%}%></font></td>
		  <td width="21%"><input type="text" name="ACCESSION_NO<%=i%>" value="<%=strTemp%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="20" maxlength="32"></td>
		  <td width="22%"><a href="javascript:OpenSearch(<%=i%>);" tabindex="-1"><img src="../../images/search_book_circulation.gif" border="0"></a></td>
		  <td width="35%"> <%
		  if(i == (iMaxToIssue - 1)){%> <input type="image" src="../../images/form_proceed.gif" onClick="ReloadPage();" tabindex="-1"> 
			<%}%> </td>
		</tr>
<%}//show only if isse is allowed.
if(strErrMsg != null) {%>
    <tr> 
      <td height="25" colspan="4"><font size="1"><strong><%=strErrMsg%></strong></font></td>
    </tr>
<%}else if(vBookIssueInfo != null && vBookIssueInfo.size() > 0){bolReadyToIssue = true;%>
    <tr> 
      <td height="25" colspan="4">

<span class="branch" id="branch<%=i%>">
  		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr bgcolor="#aaaaaa">
			  <td colspan="2" style="font-size:11px">Overdue Fine Setting : 
                <%
strTemp = (String)vBookIssueInfo.elementAt(21);
if(strTemp == null){%>
	<font color="#0000FF"><strong>Not found in system. Patron will not be charged any fine.</strong></font>
    <%}else{%>
	Fine Increment : <%=strTemp%> 
<%
strTemp = (String)vBookIssueInfo.elementAt(22);
if(strTemp != null && strTemp.equals("0"))
	strTemp = " day";
else if(strTemp != null)
	strTemp = " hour";
%>	<%="per "+strTemp%>; Max Fine : <%=WI.getStrValue(vBookIssueInfo.elementAt(23),"Not defined")%>
	; Grace Period : <%=WI.getStrValue((String)vBookIssueInfo.elementAt(24),"", strTemp, "None")%>

<input type="hidden" name="FINE_INCR<%=i%>" value="<%=(String)vBookIssueInfo.elementAt(21)%>">
<input type="hidden" name="FINE_UNIT<%=i%>" value="<%=(String)vBookIssueInfo.elementAt(22)%>">
<input type="hidden" name="FINE_MAX<%=i%>" value="<%=(String)vBookIssueInfo.elementAt(23)%>">
<input type="hidden" name="FINE_GRACE<%=i%>" value="<%=(String)vBookIssueInfo.elementAt(24)%>">
<input type="hidden" name="MAX_RENEW<%=i%>" value="<%=(String)vBookIssueInfo.elementAt(18)%>">

<%}%>				  
			  </td>
		  </tr>
			<tr>
			<td width="43%"><font size="1">Due date in system setting : <%=WI.getStrValue(vBookIssueInfo.elementAt(17))%></font></td>
            <td width="57%"><font size="1">Special due date/time :
<%
strTemp = request.getParameter("BORROWING_DUE"+i);//due date.
if(strTemp == null) {
	strTemp = (String)vBookIssueInfo.elementAt(15);//System.out.println(strTemp);
	if(WI.getStrValue((String)vBookIssueInfo.elementAt(22)).equals("0") ){
		strErrMsg = bIssue.getReturnDateAfterRemovingClosedDays(dbOP, strTemp);
		if(strErrMsg != null)
			strTemp = strErrMsg;
	}
}
//System.out.println(vBPInfo);
//System.out.println(vBookIssueInfo);

%>   
        <input name="BORROWING_DUE<%=i%>" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" size="10" readonly value="<%=WI.getStrValue(strTemp)%>" tabindex="-1">
        <a href="javascript:show_calendar('form_.BORROWING_DUE<%=i%>');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;" tabindex="-1"><img src="../../../images/calendar_new.gif" border="0"></a></font>
		<select name="BORROWING_DUE_TIME<%=i%>" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;" tabindex="-1">
		<option value="">N/A</option>
		<%
		strTemp = request.getParameter("BORROWING_DUE_TIME"+i);
		if(strTemp == null) 
			strTemp = (String)vBookIssueInfo.elementAt(16);
		if(strTemp == null) strTemp = "";
			for(int p =0; p < astrTime.length; ++p){
				if(strTemp.compareTo(astrTime[p]) == 0){%>
			<option value="<%=astrTime[p]%>" selected><%=astrTimeDisp[p]%></option>
		<%}else{%>
			<option value="<%=astrTime[p]%>"><%=astrTimeDisp[p]%></option>
		<%}//end of else.
		}//end of for%>
		</select></td>
            </tr>
 <%//if(WI.fillTextValue("hidden_row"+i).length() == 0)%>
    <tr> 
      <td height="20"><font size="1">Title : <strong><%=(String)vBookIssueInfo.elementAt(3)%> <%=WI.getStrValue((String)vBookIssueInfo.elementAt(4),"::: ","","")%></strong></font></td>
      <td><font size="1">Author :<strong> <%=(String)vBookIssueInfo.elementAt(5)%></strong></font></td>
    </tr>
    <tr> 
      <td height="20"><font size="1">Material Type : <strong><%=(String)vBookIssueInfo.elementAt(6)%></strong></font></td>
      <td><font size="1">Edition :<strong><%=WI.getStrValue(vBookIssueInfo.elementAt(7))%> <%=WI.getStrValue((String)vBookIssueInfo.elementAt(8),"::: ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td height="20"><font size="1">Call No. : <strong><%=(String)vBookIssueInfo.elementAt(9)%></strong></font></td>
      <td><font size="1">No. of Copies (available) : <strong><%=(String)vBookIssueInfo.elementAt(11)%> (<%=(String)vBookIssueInfo.elementAt(12)%>)</strong></font></td>
    </tr>
    <tr>
      <td height="20"><font size="1">Accession/Barcode :<strong><%=(String)vBookIssueInfo.elementAt(1)%> ::: <%=(String)vBookIssueInfo.elementAt(2)%></strong></font></td>
      <td>
	<%if(false){//to come in future.%>
		  <font size="1">Reservation information. :&lt;reserve by&gt; 
			:: priority.</font>
	<%}//if false.%></td>
    </tr>
<%if(bIssue.getErrMsg() != null){%>
    <tr>
      <td height="20" colspan="2"><font size="3" color="#FF0000">Not Allowed to Issue (<%=(String)vBookIssueInfo.elementAt(1)%>):: 
	  				<b><%=bIssue.getErrMsg()%></b></font></td>
    </tr>
<%}//show only if there is error msg in issuing a book.%>
<%////show if hidden row is not clicked.%>
</table>
  		</span></td></tr>
<%
	}//else if(vBookIssueInfo != null && vBookIssueInfo.size() > 0)
}//for(int i = 0; i < iMaxToIssue; ++i) end of for loop to display book to issue.%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
<%
if(bolReadyToIssue || bolRenewAvailable){%>
    <tr> 
      <td height="25"><div align="center">
	  <input type="submit" name="Save" value="<%if(bolIssueAllowed){%>Issue<%}if(bolRenewAvailable){%>/Renew<%}%> Book(s)" id="issue_clicked" onClick="document.form_.page_action.value=1;">
      </div></td>
      <td>&nbsp;</td>
    </tr>
<%}//show issue button if bolReadyToIssue
	
	}//only if allowed to isse.
else {//show error msg why the user is not allowed to issue.%>
    <tr> 
      <td height="25" colspan="2"><font size="3" color="#FF0000">
	  <%=(String)vBPInfo.elementAt(13)%></font>
      </td>
    </tr>
    <%}//reason why the user is not allowed to issue book.
%>
  </table>
<%}//ifvBPInfo is not null

}//only if vLibUserInfo not null.

if(astrSchoolYrInfo != null) {%>
	<input type="hidden" name="sy_from" value="<%=astrSchoolYrInfo[0]%>">
	<input type="hidden" name="sy_to" value="<%=astrSchoolYrInfo[1]%>">
	<input type="hidden" name="offering_sem" value="<%=astrSchoolYrInfo[2]%>">
<%}%>

<input type="hidden" name="page_action">
<input type="hidden" name="max_to_issue" value="<%=iMaxToIssue%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>