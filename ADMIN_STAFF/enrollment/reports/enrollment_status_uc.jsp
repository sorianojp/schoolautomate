<%@ page language="java" import="utility.*,enrollment.EnrollmentStatusUC,java.util.Vector" %>
<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Enrollment Status</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>



<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<script language="JavaScript">


function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	
	var obj = document.getElementById('myTable4');
	obj.deleteRow(0);
	obj.deleteRow(0);	
	
	window.print();

}

function AddEntry(){
	var strContactNo = document.form_.contact_no.value;
	var strEmailAdd = document.form_.email_address.value;
	
	if(strContactNo.length == 0 && strEmailAdd.length == 0){
		alert('Please provide Contact Number/Email Address');
		return ;
	}
	
		var pgLoc = "./additional_entry.jsp?contact_no="+strContactNo+"&email_add = "+strEmailAdd;			
		var win=window.open(pgLoc,"PrintPg",'width=800,height=550,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	
}

var calledRef;
var strCalledCount;
function AjaxMapName(strCount) {
	//calledRef = strRef;
	var strCompleteName;
	strCalledCount = strCount
	strCompleteName = eval('document.form_.stud_name_'+strCount+'.value');
	if(strCompleteName.length <3)
		return;

	
	/// this is the point i must check if i should call ajax or not..
	if(this.bolReturnStrEmpty && this.startsWith(this.strPrevEntry,strCompleteName, false) == 0)
		return;
	this.strPrevEntry = strCompleteName;
	
	var objCOAInput;
	objCOAInput = document.getElementById("coa_info_"+strCount);
	//objCOAInput = eval('document.form_.coa_info_'+strCount);
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&name_format=5&complete_name="+escape(strCompleteName);
	

	this.processRequest(strURL);
	//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}

function UpdateID(strID, strUserIndex) {		
		var strTemp = eval('document.form_.stud_name_'+strCalledCount);		
		strTemp.value = strID;	
		document.getElementById("coa_info_"+strCalledCount).innerHTML = "";
		this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
	/**if(calledRef == "1") {
		document.form_.payee_name.value = strName;
		document.getElementById("coa_info").innerHTML = "";
	}*/
}


function ReloadPage() {
	//document.form_.searchStudent.value = "";
	//document.form_.print_pg.value = "";
	document.form_.submit();
}


function Search(){
	document.form_.search_.value = '1';
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0')
		if(!confirm('Do you want to delete this id '+strInfoIndex+' in this account? '))
			return;
			
	document.form_.page_action.value = strAction;
	
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.submit();

}
</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-UC Enrollment Status","enrollment_status_uc.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;

Vector vRetResult = new Vector();

Vector vCollegeInfo = new Vector();
Vector vConfirmed   = new Vector();
Vector vReserved    = new Vector();

EnrollmentStatusUC enrlStatus = new EnrollmentStatusUC();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlStatus.viewEnrollmentStatus(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlStatus.getErrMsg();
}

String[] astrConvertSem = {"SUMMER", "FIRST TRIMESTER", "SECOND TRIMESTER", "THIRD TRIMESTER", "FOURTH TRIMESTER"};
%>
<form action="./enrollment_status_uc.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          ENROLLMENT STATUS ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF">
		<td height="25" width="3%">&nbsp;</td>
		<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
  	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY/Term:</td>
		<%
			strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
		%>
		<td width="80%">
			<select name="offering_sem">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes"></td>
	</tr>
	
	<tr >
		<td height="25" >&nbsp;</td>
		<td>Date: </td>
		<%
			strTemp = WI.fillTextValue("search_date");
			if(strTemp.length() == 0) 
				strTemp = WI.getTodaysDate(1);
		%>
		<td>
			<input name="search_date" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
				class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
			&nbsp; 
			<a href="javascript:show_calendar('form_.search_date');" title="Click to select date" 
				onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
			<img src="../../../images/calendar_new.gif" border="0"></a></td>
	</tr>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="">
		<a href="javascript:Search();">
		<img src="../../../images/form_proceed.gif" border="0">
		</a>
		</td>
	</tr>
  </table>
  
  
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0){
	vCollegeInfo = (Vector)vRetResult.remove(0);
	vConfirmed = (Vector)vRetResult.remove(0);
	vReserved = (Vector)vRetResult.remove(0);
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
	<tr><td colspan="3" align="right">
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	</td></tr>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr><td colspan="3" align="center"><font size="+3" color="#00CC33"><strong>University of the Cordilleras</strong></font></td></tr>

	<tr>
	  <td colspan="3" align="center" style="font-weight:bold; font-size:11px;">Management Information System </td>
    </tr>
    	<tr>
    		  <td colspan="3" align="center" style="font-weight:bold; font-size:17px;">&nbsp;</td>
    	</tr>
	<tr>
	  <td colspan="3" align="center" style="font-weight:bold; font-size:17px;">Enrollment Profile</td>
    </tr>

	<tr>
		<td height="20" width="30%"><font size="1">As of: <%=WI.fillTextValue("search_date")%></font></td>
		<td align="center"><font size="1"><strong>
			<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem")))]%> 
			<%=WI.getStrValue(WI.fillTextValue("sy_from"))%>-<%=WI.getStrValue(WI.fillTextValue("sy_to"))%></strong></font></td>
		<td width="30%" align="right"><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font></td>
	</tr>
</table>
 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td width="" height="25" align="center" valign="bottom" rowspan="2" class="thinborder"><strong>DEPARTMENT</strong></td>
    <%
		for(int i = 1; i < 6; i++){
			if(i == 1)
				strTemp = "1st Year";
			else if(i==2)
				strTemp = "2nd Year";
			else if(i==3)
				strTemp = "3rd Year";
			else if(i==4)
				strTemp = "4th Year";
			else if(i==5)
				strTemp = "5th Year";
			
		%>
    <td class="thinborder" align="center" colspan="2"><strong><%=strTemp%></strong></td>
    <%}%>
    <td colspan="2" align="center" class="thinborder"><strong>Total</strong></td>
    <td rowspan="2" align="center" class="thinborder"><strong>Resvered + Enrolled</strong></td>
  </tr>
  <tr>
    <%
		for(int i = 1; i < 6; i++){			
		%>
    <td class="thinborder" align="center">Reserved</td>
    <td class="thinborder" align="center">Enrolled</td>
    <%}%>
    <td class="thinborder" align="center">Reserved</td>
    <td class="thinborder" align="center">Enrolled</td>
  </tr>
  <%
	int iCount = 1;
	String strConfirmed = null;
	String strReserved = null;
	int[] aiTotals = {0,0,0,0,0,0,0,0,0,0,0};
	
	for(int i = 0; i < vCollegeInfo.size() ; i+=2){
		int iReservedTot = 0;
		int iConfirmedTot = 0;
	%>
  <tr>
    <td class="thinborder" width="12%"><%=WI.getStrValue((String)vCollegeInfo.elementAt(i+1))%></td>
    <%
		for(int q = 1; q < 6; q++ ){
			for(int x = 0; x < vConfirmed.size(); x += 4){
				if(((String)vConfirmed.elementAt(x + 2)).equals(q+"") && ((String)vConfirmed.elementAt(x + 1)).equals((String)vCollegeInfo.elementAt(i)) ){
					strConfirmed = (String)vConfirmed.elementAt(x + 3);
					break;
				}else{
					strConfirmed = "";
					continue;
				}
			}
			for(int y = 0; y < vReserved.size(); y += 4){
				//if(((String)vReserved.elementAt(y + 2)).equals(q+""))
				if(((String)vReserved.elementAt(y + 2)).equals(q+"") && ((String)vReserved.elementAt(y + 1)).equals((String)vCollegeInfo.elementAt(i)) ){
					strReserved = (String)vReserved.elementAt(y + 3);
					break;
				}else{
					strReserved = "";
					continue;
				}
			}
			
			iReservedTot += Integer.parseInt(WI.getStrValue(strReserved,"0"));
			iConfirmedTot += Integer.parseInt(WI.getStrValue(strConfirmed,"0"));
			
			aiTotals[q * 2 - 2] += Integer.parseInt(WI.getStrValue(strReserved,"0"));
			aiTotals[q * 2 - 2 + 1] += Integer.parseInt(WI.getStrValue(strConfirmed,"0"));
		%>
    <td class="thinborder" align="right" width="6%"><%=WI.getStrValue(strReserved, "&nbsp;")%></td>
    <td class="thinborder" align="right" width="6%"><%=WI.getStrValue(strConfirmed, "&nbsp;")%></td>
    <%}%>
    <td class="thinborder" align="right" width="6%"><%=WI.getStrValue(Integer.toString(iReservedTot), "&nbsp;")%></td>
    <td class="thinborder" align="right" width="6%"><%=WI.getStrValue(Integer.toString(iConfirmedTot), "&nbsp;")%></td>
    <td class="thinborder" align="right" width="6%"><%=WI.getStrValue(Integer.toString(iReservedTot + iConfirmedTot), "&nbsp;")%></td>
  </tr>
  <%}%>
  <tr>
    <td rowspan="2" class="thinborder" style="font-weight:bold">Totals: </td>
    <%
		for(int q = 1; q < 6; q++ ){%>
    <td height="20" align="right" class="thinborder"><%=aiTotals[q * 2 - 2]%></td>
    <td class="thinborder" align="right"><%=aiTotals[q * 2 - 2 + 1]%></td>
    <%}%>
    <td rowspan="2" align="right" class="thinborder"><strong><font color="#990000"><%=(String)vRetResult.elementAt(1)%></font></strong></td>
    <td rowspan="2" align="right" class="thinborder"><strong><font color="#990000"><%=(String)vRetResult.elementAt(2)%></font></strong></td>
    <td rowspan="2" align="right" class="thinborder"><strong><font color="#990000"><%=(String)vRetResult.elementAt(0)%></font></strong></td>
  </tr>
  <tr>
    <%
		for(int q = 1; q < 6; q++ ){%>
    <td height="20" colspan="2" align="right" class="thinborder"><%=aiTotals[q * 2 - 2] + aiTotals[q * 2 - 2 + 1]%></td>
    <%}%>
    </tr>
</table>
<%}%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable4">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>