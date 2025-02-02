<%@ page language="java" import="utility.*,enrollment.FAPaymentUtil,enrollment.FAStudentLedger,enrollment.EnrlAddDropSubject,java.util.Vector,java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

//forward the page here.
if(WI.fillTextValue("show_all").compareTo("1") ==0){
	response.sendRedirect("./student_ledger_viewall.jsp?stud_id="+WI.fillTextValue("id_in_url"));
	return;
}

	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	String[] astrConvertTerm = 	{"Summer","1st Semester","2nd Semester","3rd Semester"};

	boolean bolProceed = true;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Student ledger","student_ledger.jsp");
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
														"Fee Assessment & Payments","STUDENT LEDGER",request.getRemoteAddr(),
														"student_ledger.jsp");
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


Vector vBasicInfo = null;
Vector vLedgerInfo = null;

Vector vTimeSch = null;
Vector vAdjustment = null;
Vector vRefund = null;
Vector vDorm = null;
Vector vOthSchFine = null;
Vector vPayment = null;
Vector vAddedSub = null;
Vector vDroppedSub = null;



Vector vTuitionFeeDetail = null;


FAPaymentUtil paymentUtil = new FAPaymentUtil();
FAStudentLedger faStudLedg = new FAStudentLedger();
EnrlAddDropSubject eADS = new EnrlAddDropSubject();

String strSemestralLedgerRemark = null;
///added to show multiple remarks..
//remarks should be in format.. : Remark Show on top<br>56. Remark to show on line 56 <br>60. Remark to show on line 60<br>This is to be printed at bottom of page.
	String strSemestralLedgerRemarkBOTTOM = null; 
	Vector vMultipleRemarks = new Vector();
    String strLineNumber = "";
    String strNumbers = "0123456789";
    String strLineNumberTemp = null;
///end.. 
int iIndexOf = 0;

boolean bolIsBasic = false;
strTemp = null;
if(WI.fillTextValue("stud_id").length() > 0)
	strTemp = dbOP.mapUIDToUIndex(request.getParameter("stud_id"));
if(strTemp != null) {
	strTemp = "select course_index,sem_remark from stud_curriculum_hist where user_index = "+strTemp+" and is_valid = 1 and sy_from = "+
					request.getParameter("sy_from")+" and semester = "+request.getParameter("semester");
	java.sql.ResultSet rs2 = dbOP.executeQuery(strTemp);
	if(rs2.next()) {
		strTemp = rs2.getString(1);
		strSemestralLedgerRemark = rs2.getString(2);
		if(strSemestralLedgerRemark != null && strSemestralLedgerRemark.length() > 0){
			iIndexOf = strSemestralLedgerRemark.indexOf("<br>") ;
			if(iIndexOf > -1) {
				strSemestralLedgerRemarkBOTTOM = strSemestralLedgerRemark.substring(iIndexOf+ 4).trim();
				strSemestralLedgerRemark = strSemestralLedgerRemark.substring(0, iIndexOf);
				
				/** split remark here as per line number.. **/
				  while(true) {
					while(true) {
					  strLineNumberTemp = String.valueOf(strSemestralLedgerRemarkBOTTOM.charAt(0));
					  if(strLineNumberTemp.equals(".")) {
						strSemestralLedgerRemarkBOTTOM = strSemestralLedgerRemarkBOTTOM.substring(1).trim();
						break;
					  }
					  else if(strNumbers.indexOf(strLineNumberTemp) == -1)
						break;
					  strLineNumber = strLineNumber + strLineNumberTemp;
					  strSemestralLedgerRemarkBOTTOM = strSemestralLedgerRemarkBOTTOM.substring(1);
					}    
					if(strLineNumber.length() > 0)
					  vMultipleRemarks.addElement(strLineNumber);
					strLineNumber = "";
					
					iIndexOf = strSemestralLedgerRemarkBOTTOM.indexOf("<br>") ;
					if(iIndexOf == -1) {
					  if(vMultipleRemarks.size() %2 == 1) {
						vMultipleRemarks.addElement(strSemestralLedgerRemarkBOTTOM);
						strSemestralLedgerRemarkBOTTOM = null;
					  }
					  break;
					}
					vMultipleRemarks.addElement(strSemestralLedgerRemarkBOTTOM.substring(0, iIndexOf));
					strSemestralLedgerRemarkBOTTOM = strSemestralLedgerRemarkBOTTOM.substring(iIndexOf+ 4).trim();
				  }
				/** end here **/
				
				
				
				
				
				
				
			}
		}
		
	}
	rs2.close();
	
	if(strTemp != null && strTemp.equals("0"))
		bolIsBasic = true;
}
if(bolIsBasic)
	astrConvertTerm[1] = "Regular";

paymentUtil.setIsBasic(bolIsBasic);//System.out.println(bolIsBasic);


if(WI.fillTextValue("stud_id").length() > 0)
{
	vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"),
	request.getParameter("sy_from"),request.getParameter("sy_to"),request.getParameter("semester"));
	if(vBasicInfo == null)
		vBasicInfo = paymentUtil.getStudBasicInfoOLD(dbOP, request.getParameter("stud_id"));
	if(vBasicInfo == null) //may be it is the teacher/staff
		strErrMsg = paymentUtil.getErrMsg();
	else//check if this student is called for old ledger information.
	{
		int iDisplayType = faStudLedg.isOldLedgerInformation(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
											request.getParameter("sy_to"),request.getParameter("semester"));
		if(iDisplayType ==-1) //Error.
		{
			%>
			<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=faStudLedg.getErrMsg()%></font></p>
			<%
			dbOP.cleanUP();
			return;
		}
		if(iDisplayType ==1)//this is called for old ledger information.
		{
			dbOP.cleanUP();
			response.sendRedirect(response.encodeRedirectURL("./old_student_ledger_view.jsp?stud_id="+request.getParameter("stud_id")+"&sy_from="+
				request.getParameter("sy_from")+"&sy_to="+request.getParameter("sy_to")+"&semester="+request.getParameter("semester")));
			return;
		}
	}
	//check if the applicant is having reservation already, if so - take directly to the print page,
	if(vBasicInfo != null && vBasicInfo.size() > 0)
	{//long lTime = new java.util.Date().getTime();
		boolean bolShowOnlyDroppedSub = false;
		if(WI.fillTextValue("show_dropped_only").length() > 0)
			bolShowOnlyDroppedSub = true;
		vLedgerInfo = faStudLedg.viewLedgerTuition(dbOP, (String)vBasicInfo.elementAt(0),request.getParameter("sy_from"),
			request.getParameter("sy_to"),null,request.getParameter("semester"), bolShowOnlyDroppedSub);
		if(vLedgerInfo == null)
			strErrMsg = faStudLedg.getErrMsg();
		else
		{//System.out.println( (new java.util.Date().getTime() - lTime)/1000);
			vTimeSch 			= (Vector)vLedgerInfo.elementAt(0);
			vTuitionFeeDetail	= (Vector)vLedgerInfo.elementAt(1);
			vAdjustment			= (Vector)vLedgerInfo.elementAt(2);
			vRefund				= (Vector)vLedgerInfo.elementAt(3);
			vDorm 				= (Vector)vLedgerInfo.elementAt(4);
			vOthSchFine			= (Vector)vLedgerInfo.elementAt(5);//System.out.println(vOthSchFine);
			vPayment			= (Vector)vLedgerInfo.elementAt(6);
			if(vTimeSch == null || vTimeSch.size() ==0)
				strErrMsg = faStudLedg.getErrMsg();

		}

	}
}
else
	strErrMsg = "Please enter student ID";

//System.out.println(vDroppedSub);

boolean bolShowLabel = false;
//startLine..
int iStartLine = Integer.parseInt(WI.getStrValue(WI.fillTextValue("start_line"),"0"));
if(iStartLine > 0)
	iStartLine += 7;


int iCurrentLineNo = 1;

%>

<html>
<head>
<title>STUDENT LEDGER</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
<!--
 /* Style Definitions */
h1
	{
	text-align:center;
	font-size:10.0pt;
	font-family:"Times New Roman";}

/** My code below.. code above is generated by word - given by AUF **/
body {
	font-size:12px;
	font-family:"Times New Roman";}
}

td {
	font-size:12px;
	font-family:"Times New Roman";}
}

th {
	font-size:12px;
	font-family:"Times New Roman";}
}

.bodystyle {
	font-size:12px;
	font-family:"Times New Roman";}
}

.nav {
     color: #000000;
     background-color: #FFFFFF;
}
.nav-highlight {
     color: #000000;
     background-color: #0099FF;
}

-->
</style>
</head>
<script src="../../../jscript/td.js"></script>
<script src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
//this is to remove the header upto the balance forward, this is because of continous printing..
function RemoveHeader() {
	hideLayer("row_1");
	hideLayer("row_2");
	hideLayer("row_3");
	hideLayer("row_4");
}
//strORNumber is passed only if it is a payment.
function printRow(rowID, strORNumber) {
	//if checkbox is called, return.
	if(document.form_.donot_print.value == '1') {
		document.form_.donot_print.value = "";
		return;
	}

	//I have to remove the line number in printing..
	var rowIDName = "";
	var iMaxRow = eval(document.form_.max_rows.value);
	var objChkBox;
/**
	for(var i = 5; i <= iMaxRow; ++i) {
		//else hide rows.
		rowIDName = 'l_'+i;
		obj = document.getElementById(rowIDName);
		if(obj)
			obj.innerHTML = "";
	}
**/

	if(document.form_.print_clicked.value == "1") {
		this.showAll();
		document.form_.print_clicked.value = "";
		return;
	}
	document.form_.print_clicked.value = "1";

	if(rowID < 11) {///print all upto tuition fee.
		for(var i = 11; i <= iMaxRow; ++i) {
			rowIDName = 'row_'+i;
			//else hide rows.
			if(document.getElementById(rowIDName))
				hideLayer(rowIDName);
		}
		//this is clicked to print the balance forward and onward, not the hearder, as AUF is printing more than 1 sem per page.
		/**
		if(rowID == -1) {//delete header.
			var obj = document.getElementById('myADTable1');
			obj.deleteRow(0);
			obj.deleteRow(0);
			obj.deleteRow(0);
			obj.deleteRow(0);
			obj.deleteRow(0);
			obj.deleteRow(0);
			obj.deleteRow(0);			
		}**/
		
		
		window.print();
		
		if(strORNumber != null) {
			this.ajaxUpdatePrintedBy(strORNumber);
		}
		
		return;
	}
	for(var i = 0; i <= iMaxRow; ++i) {
		if(i == rowID)
			continue;
		//check if checkbox is there..
		eval('objChkBox=document.form_._'+i+';');
		if(objChkBox && objChkBox.checked)
			continue;
		//continue;
		//else hide rows.
		rowIDName = 'row_'+i;
		if(document.getElementById(rowIDName))
			hideLayer(rowIDName);
		if(i == 0 && document.getElementById("row_00"))
			hideLayer("row_00");
	}

	//hide all check box..
	for(var i = 0; i <= iMaxRow; ++i) {
		//else hide rows.
		rowIDName = 'sel_'+i;
		obj = document.getElementById(rowIDName);
		if(obj)
			obj.innerHTML = "";
	}
	
	//actual table row = 10 where rowID = 5	-- if printing in 2nd page, i have to delete the rows, instead of hiding.
	var iMaxLineFirstPage = document.form_.max_line_firstpage.value;
	if(iMaxLineFirstPage == '')
		iMaxLineFirstPage = 0;
	//alert("rowID: "+rowID+" ;;iMaxLineFirstPage: "+iMaxLineFirstPage); 	
	
	if(eval(rowID) > eval(iMaxLineFirstPage) ) {//start deleting.. 
		var obj = document.getElementById('myADTable1');
		for(var i = 10; i < eval(iMaxLineFirstPage) + 2; ++i)
			obj.deleteRow(10);
	}

	if(strORNumber != null) {
		this.ajaxUpdatePrintedBy(strORNumber);
	}
	window.print();
}
function showAll() {
	var iMaxRow = eval(document.form_.max_rows.value);
	for(var i = 0; i <= iMaxRow; ++i) {
		rowIDName = 'row_'+i;
		//else hide rows.
		if(document.getElementById(rowIDName))
			showLayer(rowIDName);
	}
}
function hideHeader() {
	var strBalance = prompt('Please enter amount to balance forward and click OK.','');
	if(strBalance == null || strBalance.length == 0) {
		document.getElementById('1000').innerHTML="&nbsp;";
		document.getElementById('1001').innerHTML="&nbsp;";
		document.getElementById('1002').innerHTML="&nbsp;";
		return;
	}

	document.getElementById('1003').innerHTML=strBalance;


	var iMaxRow = eval(document.form_.max_rows.value);
	for(var i = 0; i <= iMaxRow; ++i) {
		if(i == 1 || i == 2 || i == 3 || i == 4)
			continue;
		rowIDName = 'row_'+i;
		if(document.getElementById(rowIDName))
			hideLayer(rowIDName);
		if(i == 0 && document.getElementById("row_00"))
			hideLayer("row_00");
	}
	window.print();
}
function balanceForward(strBalance, strLineNumber,strORNumber) {
	if(!confirm('Click Ok to forward balance : '+strBalance+ ' to next page.'))
		return;
	
	ajaxUpdateLineNumber("",strLineNumber,strORNumber);

	document.getElementById('1003').innerHTML=strBalance;

	var iMaxRow = eval(document.form_.max_rows.value);
	for(var i = 0; i <= iMaxRow; ++i) {
		if(i == 1 || i == 2 || i == 3 || i == 4)
			continue;
		rowIDName = 'row_'+i;
		if(document.getElementById(rowIDName))
			hideLayer(rowIDName);
		if(i == 0 && document.getElementById("row_00"))
			hideLayer("row_00");
	}
	document.form_.print_clicked.value = '1';
	window.print();
}
/*** this ajax is called to record semestral remarks **/
function ajaxUpdateLineNumber(strCurLine, strLastLine,strORNumber) {
	var strParam = "stud_ref=<%=(String)vBasicInfo.elementAt(0)%>&sy_from=<%=WI.fillTextValue("sy_from")%>&semester=<%=WI.fillTextValue("semester")%>"+
					"&last_line="+strLastLine+"&cur_line="+strCurLine;
	if(strORNumber != null && strORNumber.length > 0)
		strParam += "&or_num="+strORNumber;
	
	var objCOAInput = document.form_.max_line_firstpage;
	this.InitXmlHttpObject(objCOAInput, 1);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=118&"+strParam;
	this.processRequest(strURL);
}
/*** this ajax is called to record printed by and date. **/
function ajaxUpdatePrintedBy(strORNumber) {
	var strParam = "stud_ref=<%=(String)vBasicInfo.elementAt(0)%>&sy_from=<%=WI.fillTextValue("sy_from")%>&semester=<%=WI.fillTextValue("semester")%>"+
					"&or_num="+strORNumber;
	
	var objCOAInput = document.form_.max_line_firstpage;
	this.InitXmlHttpObject(objCOAInput, 1);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=118&"+strParam;
	this.processRequest(strURL);
}

</script>

<body <%if(strErrMsg == null && false){%> onLoad="window.print();"<%}//no printing on load.%> topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0">

<%if(strErrMsg != null) {%>
<p style="font-size:16px; color:#FF0000; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"><%=strErrMsg%></p>
<%return;}%>
<form name="form_">

<table cellpadding="0" cellspacing="0">
<%for(int i = 0;i < iStartLine; ++i) {%>
	<tr><td height="18">&nbsp;</td></tr>
<%}%>
</table>

  <table border=0 cellspacing=0 cellpadding=0 width="100%" id="myADTable1">
<%if(iStartLine == 0) {//show only if it is start of ledger..%>
    <tr id="row_1">
      <td colspan=4 valign=top><%//=(String)vBasicInfo.elementAt(1)%></td>
      <td valign=top></td>
      <td colspan=2 valign=top> <label id="1000" onClick="hideHeader();"><%=request.getParameter("stud_id")%></label></td>
    </tr>
    <tr>
      <td colspan=4 valign=top height="25"><%if(bolShowLabel){%>NAME<%}%>&nbsp;</td>
      <td valign=top></td>
      <td colspan=2 valign=top><%if(bolShowLabel){%>STUDENT NUMBER<%}%>&nbsp;</td>
    </tr>
    <tr id="row_2">
      <td colspan=4 valign=top onDblClick="RemoveHeader();">
	  <%
	  strTemp = (String)vBasicInfo.elementAt(14);
	  String strAddrLine2 = null;String strAddrLine1 = strTemp;
	  if(strTemp != null && strTemp.length() > 50) {
	  	iIndexOf = strTemp.indexOf(" ", 42);
		if(iIndexOf == -1)
			iIndexOf = strTemp.indexOf(",",42);
		if(iIndexOf > -1) {
	  		strAddrLine1 = strTemp.substring(0,iIndexOf);
			strAddrLine2 = strTemp.substring(iIndexOf + 1);
		}
	  }//address is removed.%>
	  <%//=WI.getStrValue(strAddrLine1)%><label id="1001"><%=(String)vBasicInfo.elementAt(1)%></label>	  </td>
      <td valign=top></td>
      <td colspan=2 valign=top><label id="1002">
	 <%if(bolIsBasic) {%>
	 	<%=dbOP.getBasicEducationLevel(Integer.parseInt((String)vBasicInfo.elementAt(4)), false)%>
	 <%}else{%>
	 	<%=(String)vBasicInfo.elementAt(2)%><%=WI.getStrValue((String)vBasicInfo.elementAt(12), "-", "", "")%>
	 <%}%>
	 </label>
	 </td>
    </tr>
    <tr>
      <td colspan=4 valign=top><%if(bolShowLabel){%>ADDRESS<%}%></td>
      <td valign=top></td>
      <td colspan=2 valign=top><%if(bolShowLabel){%>COURSE<%}%></td>
    </tr>
    <tr id="row_3">
      <td colspan=4 valign=top>
	  <%if(strAddrLine2 != null){%><%//=strAddrLine2%><%}%>	  </td>
      <td valign=top></td>
      <td colspan=2 valign=top>&nbsp;
<!--
	<%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to").substring(2)%>
-->	 </td>
    </tr>
    <tr>
      <td colspan=7 valign=top height="50"><h1><%if(bolShowLabel){%>STUDENT LEDGER<%}%>&nbsp;</h1></td>
    </tr>
    <tr>
      <td></td>
      <td><%if(bolShowLabel){%>DATE<%}%>&nbsp;</td>
      <td><%if(bolShowLabel){%>REFERENCE<%}%>&nbsp;</td>
      <td><%if(bolShowLabel){%>CHARGES&nbsp;<%}%></td>
      <td><%if(bolShowLabel){%>PAYMENTS<%}%>&nbsp;</td>
      <td><%if(bolShowLabel){%>BALANCE<%}%>&nbsp;</td>
      <td><%if(bolShowLabel){%>ACCTG<br>CLERK<%}else{%>&nbsp;<br>&nbsp;<%}%></td>
    </tr>
<%}//do not show if start line number is > 0

//start of loop..
int iRunningLineNo = 10;
if(vTimeSch != null && vTimeSch.size() > 0){
	double dBalance = ((Double)vTuitionFeeDetail.elementAt(0)).doubleValue();
	double dCredit = 0d;
	double dDebit = 0d;
	String strTransDate = null;
	int iIndex = 0;

	int iLineNumber = 1;
%>

    <tr id="row_4" onClick="printRow(-1);">
      <td colspan=3 valign=top>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%if(iStartLine > 0){%>BALANCE FORWARDED<%}%></td>
      <td colspan=2 valign=top></td>
      <td align="right" style="font-size:12px;"><label id="1003"><%=CommonUtil.formatFloat(dBalance,true)%></label></td>
      <td  align="right" style="font-size:12px;">&nbsp;</td>
    </tr>
<%if(strSemestralLedgerRemark != null && strSemestralLedgerRemark.length() > 0) {%>
     <tr id="row_00">
		<td colspan="7" style="font-size:12px; font-family: 'Times New Roman', Times, serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=strSemestralLedgerRemark%></strong> </td>
    </tr>
<%}%>
   <tr id="row_0">
		<td colspan="7" style="font-size:12px; font-family: 'Times New Roman', Times, serif">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=astrConvertTerm[Integer.parseInt((String)vBasicInfo.elementAt(5))]%>, <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%>		</td>
        <!--
      <td colspan=3 valign=top style='width:163.25pt; border-top:none;padding:0in 5.4pt 0in 5.4pt'>&nbsp;</td>
      <td colspan=2 valign=top style='width:48.15pt; padding:0in 5.4pt 0in 5.4pt'>&nbsp;</td>
      <td colspan=3 align="right" style="font-size:12px;">&nbsp;</td>
      <td  align="right" style="font-size:12px;">&nbsp;</td>
-->
    </tr>
<%
for(int i=0; i<vTimeSch.size(); ++i){
	strTransDate = ConversionTable.convertMMDDYYYY((Date)vTimeSch.elementAt(i));
	strTransDate = strTransDate.substring(0,strTransDate.length() - 4)+strTransDate.substring(strTransDate.length() -2);
	if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){
		dDebit = ((Double)vTuitionFeeDetail.elementAt(1)).doubleValue();
		dBalance += dDebit;
%>
   <tr id="row_5">
      <td align="right" style="font-size:12px" width="8%"><label id="l_5"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;" width="11%"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;" width="20%">TF</td>
      <td valign="top" style="font-size:12px;" align="right" width="14%"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right" width="18%">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right" width="21%"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;" width="8%"></td>
    </tr>
<%
	dDebit = ((Double)vTuitionFeeDetail.elementAt(2)).doubleValue();
	dBalance += dDebit;
%>
   <tr id="row_6" onClick="printRow(6);" class="nav" onMouseOver="navRollOver('row_6', 'on')" onMouseOut="navRollOver('row_6', 'off')">
      <td align="right" style="font-size:12px"><label id="l_6"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;">MISC</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;"></td>
    </tr>
<%
dDebit = ((Double)vTuitionFeeDetail.elementAt(7)).doubleValue();
if(dDebit > 0d){
	dBalance += dDebit;%>

   <tr id="row_7" onClick="printRow(7);" class="nav" onMouseOver="navRollOver('row_7', 'on')" onMouseOut="navRollOver('row_7', 'off')">
      <td align="right" style="font-size:12px"><label id="l_7"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;">OC</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;"></td>
    </tr>
    <%}
dDebit = ((Double)vTuitionFeeDetail.elementAt(3)).doubleValue();
if(dDebit > 0d){
	dBalance += dDebit;%>
   <tr id="row_8" onClick="printRow(8);" class="nav" onMouseOver="navRollOver('row_8', 'on')" onMouseOut="navRollOver('row_8', 'off')">
      <td align="right" style="font-size:12px"><label id="l_8"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label>&nbsp;&nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;">Hands on</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;"></td>
    </tr>
    <%}
//show this if there is any discounts.
if(vTuitionFeeDetail.elementAt(5) != null){
	double dTemp = ((Double)vTuitionFeeDetail.elementAt(5)).doubleValue();
	if(dTemp > 0d)
		dCredit = dTemp;
	else
		dDebit  =  -1 * dTemp;
	dBalance -= dTemp;

	strTemp  = (String)vTuitionFeeDetail.elementAt(6);
	//System.out.println(strTemp);
	if(strTemp.trim().startsWith("Full payment discount"))
		strTemp = "Full pmt Disc";


	%>
   <tr id="row_9" onClick="printRow(9);" class="nav" onMouseOver="navRollOver('row_9', 'on')" onMouseOut="navRollOver('row_9', 'off')">
      <td align="right" style="font-size:12px"><label id="l_9"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;"><%=strTemp%></td>
      <td valign="top" style="font-size:12px;" align="right"><%if(dDebit > 0f){%><%=CommonUtil.formatFloat(dDebit,true)%><%}%> </td>
      <td valign="top" style="font-size:12px;" align="right"><%if(dCredit > 0f){%><%=CommonUtil.formatFloat(dCredit,true)%><%}%></td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;">&nbsp;</td>
    </tr>
  <%}if(vTuitionFeeDetail.elementAt(8) != null){%>
   <tr id="row_10" onClick="printRow(10);" class="nav" onMouseOver="navRollOver('row_10', 'on')" onMouseOut="navRollOver('row_10', 'off')">
      <td align="right" style="font-size:12px"><label id="l_10"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td colspan=6 valign="top" style="font-size:12px;">NOTE : <%=(String)vTuitionFeeDetail.elementAt(8)%></td>
    </tr>
    <%
	}
} //if(vTuitionFeeDetail.contains((Date)vTimeSch.elementAt(i))){.

//adjustment here
//System.out.println(vAdjustment);
String strDiscName = null;
while( (iIndex = vAdjustment.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
	dCredit = Double.parseDouble((String)vAdjustment.elementAt(iIndex-3));
	dBalance -= dCredit;
	strDiscName = (String)vAdjustment.elementAt(iIndex + 2);
	if(strDiscName != null) {
		String strMapName = null;
		String strDiscPercent = null;
		strDiscName = "select main_type_name, sub_type_name1, sub_type_name2, sub_type_name3, sub_type_name4, sub_type_name5, discount,discount_unit from fa_fee_adjustment where fa_fa_index="+strDiscName;
		java.sql.ResultSet rs = dbOP.executeQuery(strDiscName);
		if(rs.next()) {
			strDiscName = rs.getString(1);
			if(rs.getString(2) != null)
				strDiscName = rs.getString(2);
			if(rs.getString(3) != null)
				strDiscName = rs.getString(3);
			if(rs.getString(4) != null)
				strDiscName = rs.getString(4);
			if(rs.getString(5) != null)
				strDiscName = rs.getString(5);
			if(rs.getString(6) != null)
				strDiscName = rs.getString(6);
			strDiscPercent = CommonUtil.formatFloat(rs.getDouble(7), false);
			if(rs.getInt(8) == 1)
				strDiscPercent += "%";
			else if(rs.getInt(8) == 0)
				strDiscPercent += " amt";
			else
				strDiscPercent += " units";
			rs.close();
			strDiscName = "select map_name from FA_FEE_ADJUSTMENT_MAP where discount_name = "+WI.getInsertValueForDB(strDiscName, true, null);
			rs = dbOP.executeQuery(strDiscName);
			if(rs.next())
				strMapName = rs.getString(1);
		}
		rs.close();
		if(strMapName != null)
			strDiscName = strMapName + "-"+strDiscPercent;
		else
			strDiscName = null;
	}

%>
   <tr id="row_<%=++iRunningLineNo%>" onClick="printRow(<%=iRunningLineNo%>);" class="nav" onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px"><label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;"><%=WI.getStrValue(strDiscName, "", "", "DISC")%></td>
      <td valign="top" style="font-size:12px;" align="right">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dCredit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;">&nbsp;</td>
    </tr>
    <%
	//remove the element here.
	vAdjustment.removeElementAt(iIndex);vAdjustment.removeElementAt(iIndex-1);vAdjustment.removeElementAt(iIndex-2);
	vAdjustment.removeElementAt(iIndex-3);vAdjustment.removeElementAt(iIndex-4);
}

//Refund here
while( (iIndex = vRefund.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
	dDebit = Double.parseDouble((String)vRefund.elementAt(iIndex-1));
	dBalance += dDebit;
%>
   <tr id="row_<%=++iRunningLineNo%>" onClick="printRow(<%=iRunningLineNo%>);" class="nav" onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px"><label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;"><%if(vRefund.elementAt(iIndex - 2) != null){%><%=(String)vRefund.elementAt(iIndex-2)%><%}else{%>
        <%=(String)vRefund.elementAt(iIndex-3)%>(Refund)
        <%}%></td>
      <td valign="top" style="font-size:12px;" align="right"><%if(dDebit >= 0f){%> <%=CommonUtil.formatFloat(dDebit,true)%><%}%></td>
      <td valign="top" style="font-size:12px;" align="right"><%if(dDebit < 0f){%>
        <%=CommonUtil.formatFloat(dDebit,true)%>
      <%}%></td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;">&nbsp;</td>
    </tr>
    <%
	//remove the element here.
	vRefund.removeElementAt(iIndex);vRefund.removeElementAt(iIndex-1);vRefund.removeElementAt(iIndex-2);
	vRefund.removeElementAt(iIndex-3);
}
//dormitory charges
while( (iIndex = vDorm.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
	dDebit = Double.parseDouble((String)vDorm.elementAt(iIndex-1));
	dBalance += dDebit;
%>
   <tr id="row_<%=++iRunningLineNo%>" onClick="printRow(<%=iRunningLineNo%>);" class="nav" onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px"><label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;"><%=(String)vDorm.elementAt(iIndex-2)%></td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;">&nbsp;</td>
    </tr>
    <%
	//remove the element here.
	vDorm.removeElementAt(iIndex);vDorm.removeElementAt(iIndex-1);vDorm.removeElementAt(iIndex-2);
}

//Other school fees/fine/school facility fee charges(except dormitory)
//System.out.println(vOthSchFine);
while( (iIndex = vOthSchFine.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
	dDebit = Double.parseDouble((String)vOthSchFine.elementAt(iIndex-1));
	dBalance += dDebit;
	strTemp = (String)vOthSchFine.elementAt(iIndex-2);
	//System.out.println(strTemp);
	if(strTemp.startsWith("Credit Card"))
		strTemp = "CC"+strTemp.substring(11);

iIndexOf = vMultipleRemarks.indexOf(Integer.toString(iLineNumber));
if(iIndexOf > -1) {
vMultipleRemarks.remove(iIndexOf);%>
	<tr id="row_<%=++iRunningLineNo%>" class="nav"
   		onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px" onClick="printRow(<%=iRunningLineNo%>);"><label id="sel_<%=iRunningLineNo%>"><input type="checkbox" name="_<%=iRunningLineNo%>" onClick="document.form_.donot_print.value='1'"></label>
	  <label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;" onClick="printRow(<%=iRunningLineNo%>);" colspan="6"><%=vMultipleRemarks.remove(iIndexOf)%></td>
    </tr>
<%}%>
   <tr id="row_<%=++iRunningLineNo%>" class="nav" onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px" onClick="printRow(<%=iRunningLineNo%>);">
	  <label id="sel_<%=iRunningLineNo%>"><input type="checkbox" name="_<%=iRunningLineNo%>" onClick="document.form_.donot_print.value='1'"></label>
	  <label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;" onClick="printRow(<%=iRunningLineNo%>);"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;" onClick="printRow(<%=iRunningLineNo%>);"><!--OC--><%=strTemp%></td>
      <td valign="top" style="font-size:12px;" align="right" onClick="printRow(<%=iRunningLineNo%>);"><%=CommonUtil.formatFloat(dDebit,true)%></td>
      <td valign="top" style="font-size:12px;" align="right" onClick="printRow(<%=iRunningLineNo%>);">&nbsp;</td>
      <td valign="top" style="font-size:12px;" align="right" onClick="balanceForward('<%=CommonUtil.formatFloat(dBalance,true)%>', '<%=iRunningLineNo%>');"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;">&nbsp;</td>
    </tr>
    <%
	//remove the element here.
	vOthSchFine.removeElementAt(iIndex);vOthSchFine.removeElementAt(iIndex-1);vOthSchFine.removeElementAt(iIndex-2);
}

//vPayment goes here, ;-)
while( (iIndex = vPayment.indexOf((Date)vTimeSch.elementAt(i))) != -1) {
	dCredit = Double.parseDouble((String)vPayment.elementAt(iIndex-2));
	dBalance -= dCredit;
strTemp = WI.getStrValue(vPayment.elementAt(iIndex+1));
iIndexOf = strTemp.indexOf(" Enrollment/downpayment");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf) + " - DP";
iIndexOf =  strTemp.indexOf(" - Cash");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" - Check");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" - SD");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" Refunded");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf =  strTemp.indexOf(" Refund Transfered");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf);
iIndexOf = strTemp.indexOf("Tuition");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf) + "TF";
iIndexOf = strTemp.indexOf("Oth sch fee");
if(iIndexOf != -1)
	strTemp = strTemp.substring(0,iIndexOf)+" OC";

//if(dCredit < 0d)
//	strTemp = "DM";
//else if(vPayment.elementAt(iIndex-1) == null) //credit memo
//	strTemp = "CM";

//print here remarks having line number. 
iIndexOf = vMultipleRemarks.indexOf(Integer.toString(iLineNumber));
if(iIndexOf > -1) {
vMultipleRemarks.remove(iIndexOf);%>
	<tr id="row_<%=++iRunningLineNo%>" class="nav"
   		onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px" onClick="printRow(<%=iRunningLineNo%>);"><label id="sel_<%=iRunningLineNo%>"><input type="checkbox" name="_<%=iRunningLineNo%>" onClick="document.form_.donot_print.value='1'"></label>
	  <label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;" onClick="printRow(<%=iRunningLineNo%>);" colspan="6"><%=vMultipleRemarks.remove(iIndexOf)%></td>
    </tr>
<%}%>

   <tr id="row_<%=++iRunningLineNo%>" class="nav"
   		onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px" onClick="printRow('<%=iRunningLineNo%>','<%=vPayment.elementAt(iIndex-1)%>');"><label id="sel_<%=iRunningLineNo%>"><input type="checkbox" name="_<%=iRunningLineNo%>" onClick="document.form_.donot_print.value='1'"></label>
	  <label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;" onClick="printRow('<%=iRunningLineNo%>','<%=vPayment.elementAt(iIndex-1)%>');"><%=strTransDate%></td>
      <td valign=top style="font-size:12px;" onClick="printRow('<%=iRunningLineNo%>','<%=vPayment.elementAt(iIndex-1)%>');"><%=WI.getStrValue(vPayment.elementAt(iIndex-1))%> <%=strTemp%></td>
      <td valign="top" style="font-size:12px;" align="right" onClick="printRow('<%=iRunningLineNo%>','<%=vPayment.elementAt(iIndex-1)%>');">
	  <%//show only the refunds in debit column.
	  if(dCredit < 0d || (vPayment.elementAt(iIndex+1) != null && ((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
	  <%=CommonUtil.formatFloat(-1 * dCredit,true)%><%}%>	  </td>
      <td valign="top" style="font-size:12px;" align="right" onClick="printRow('<%=iRunningLineNo%>','<%=vPayment.elementAt(iIndex-1)%>');"><%if(dCredit >= 0d && (vPayment.elementAt(iIndex+1) == null || !((String)vPayment.elementAt(iIndex+1)).startsWith(" Refunded")) ){%>
        <%=CommonUtil.formatFloat(dCredit,true)%>
      <%}%></td>
      <td valign="top" style="font-size:12px;" align="right" onClick="balanceForward('<%=CommonUtil.formatFloat(dBalance,true)%>', '<%=iRunningLineNo%>','<%=vPayment.elementAt(iIndex-1)%>');"><%=CommonUtil.formatFloat(dBalance,true)%></td>
      <td valign="top" style="font-size:12px;" align="right"><%=(String)vPayment.elementAt(iIndex + 3)%></td>
    </tr>
    <%
//remove the element here.
vPayment.removeElementAt(iIndex+3);
vPayment.removeElementAt(iIndex+2);
vPayment.removeElementAt(iIndex+1);
vPayment.removeElementAt(iIndex);
vPayment.removeElementAt(iIndex-1);
vPayment.removeElementAt(iIndex-2);
}%>

<%
}//end of for loop.%>




<!--2002-1157-->





<%if(strSemestralLedgerRemarkBOTTOM != null && strSemestralLedgerRemarkBOTTOM.length() > 0){%>   
	<tr id="row_<%=++iRunningLineNo%>" class="nav"
   		onMouseOver="navRollOver('row_<%=iRunningLineNo%>', 'on')" onMouseOut="navRollOver('row_<%=iRunningLineNo%>', 'off')">
      <td align="right" style="font-size:12px" onClick="printRow(<%=iRunningLineNo%>);"><label id="sel_<%=iRunningLineNo%>"><input type="checkbox" name="_<%=iRunningLineNo%>" onClick="document.form_.donot_print.value='1'"></label>
	  <label id="l_<%=iRunningLineNo%>"><%if(true || bolShowLabel){%><%=iLineNumber++%>.<%}%></label> &nbsp;</td>
      <td valign=top style="font-size:12px;" onClick="printRow(<%=iRunningLineNo%>);" colspan="6"><%=strSemestralLedgerRemarkBOTTOM%></td>
    </tr>
<%}%>


<%//end of for loop..
}///end of if(vTimeSch != null && vTimeSch.size() > 0){
%>

<!--
    <tr height=0>
      <td width=69 style='border:none'></td>
      <td width=95 style='border:none'></td>
      <td width=108 style='border:none'></td>
      <td width=62 style='border:none'></td>
      <td width=19 style='border:none'></td>
      <td width=29 style='border:none'></td>
      <td width=61 style='border:none'></td>
      <td width=82 style='border:none'></td>
      <td width=78 style='border:none'></td>
    </tr>
-->


  </table>
<input type="hidden" name="print_clicked">
<input type="hidden" name="max_rows" value="<%=iRunningLineNo%>">

<!-- if double clicked, do not hide it.. -->
<input type="hidden" name="donot_print" value="">

<%
strTemp = "select MAX_LINE_FIRST_PAGE from FA_STUD_LEDG_PRINT_INFO where STUD_INDEX = "+vBasicInfo.elementAt(0)+
	" and SY_FROM = "+WI.fillTextValue("sy_from")+" and SEMESTER = "+WI.fillTextValue("semester");
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
%>
<input type="hidden" name="max_line_firstpage" value="<%=WI.getStrValue(strTemp)%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
