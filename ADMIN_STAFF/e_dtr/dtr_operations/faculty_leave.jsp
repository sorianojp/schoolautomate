<%@ page language="java" import="utility.*,java.util.Vector, eDTR.FacultyDTR" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>eDTR Manual Entry</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.dtr_op.prepareToEdit.value = 0;
  }

	function PrepareToEdit(index){
 		document.dtr_op.prepareToEdit.value = 1;
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

	function AddRecord(){
		document.dtr_op.page_action.value = 1;
		document.dtr_op.submit();
	}

	function EditRecord(){
		document.dtr_op.page_action.value = 2;
		document.dtr_op.submit();
	}

	function CancelRecord(){
		location = "./faculty_leave.jsp?emp_id=" + document.dtr_op.emp_id.value + 
			"&leave_date="+document.dtr_op.leave_date.value;
	} 
	
	function DeleteRecord(index){
		document.dtr_op.page_action.value = "0";
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

	function focusID() {
		document.dtr_op.emp_id.focus();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"SearchID",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
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
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function showNextday(){	
	if(document.dtr_op.strStatus2){
		if (document.dtr_op.strStatus2.value == '0'){
			document.dtr_op.nextday_logout.disabled = true;
		}else{
			document.dtr_op.nextday_logout.disabled = false;
		}
	}
}

function gotoDate(strNewDate){
	document.dtr_op.leave_date.value = strNewDate;
	clearFields();
	document.dtr_op.submit();
}

function clearFields(){
	document.dtr_op.lec_.value = "";
	document.dtr_op.lab_.value = "";
	document.dtr_op.rle_.value = "";
	document.dtr_op.nstp_.value = "";
	document.dtr_op.grad_.value = "";
}

function checkVal(strFieldName){
	var strMax = eval('document.dtr_op.'+strFieldName+'max.value');
	var strVal = eval('document.dtr_op.'+strFieldName+'.value');
	var lblNote = document.getElementById(strFieldName+"note");
	if(eval(strVal) > eval(strMax)){
		alert("Entered value is greater than the max allowed for the day.");
		lblNote.innerHTML = "<font color='#FF0000' sixe='3'>*</font>";
		eval('document.dtr_op.'+strFieldName+'.value ='+strMax);
		return;
	}else{
		lblNote.innerHTML = "";
	}
}

-->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();showNextday();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = 
				WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","faculty_leave.jsp");

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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"faculty_leave.jsp");
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

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////

Vector vPersonalDetails = null;
Vector vRetResult =  null;
Vector vSchedule = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
Vector vEditInfo = null;
String[] astrConverAMPM = {"AM", "PM"};
FacultyDTR facDtr = new FacultyDTR();
String[] astrSubjType = {"Lec", "Lab", "RLE", "NSTP","GRAD"};
double[] adSubjTotal = new double[5];
double dDuration = 0d;
String strSubjType = "0";

int iPageAction  = 0;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	iPageAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
	vRetResult = facDtr.operateOnFacultyLeave(dbOP, request, iPageAction);
 	if(vRetResult == null)
		strErrMsg = facDtr.getErrMsg();
	else
		strErrMsg = "Operation Successful";
}

if(WI.fillTextValue("prepareToEdit").length() > 0){
	vEditInfo = facDtr.operateOnFacultyLeave(dbOP, request, 3);
}

//	System.out.println("1- " + ConversionTable.compareDate("9/11/2009", "9/12/2009"));
//	System.out.println("2- " + ConversionTable.compareDate("9/11/2009", "9/11/2009"));
//	System.out.println("3- " + ConversionTable.compareDate("9/12/2009", "9/11/2009"));

if (WI.fillTextValue("leave_date").length() > 0) { 
	vRetResult = facDtr.operateOnFacultyLeave(dbOP, request, 4);
 	vSchedule = facDtr.getEmpDailySchedule(dbOP, request, WI.fillTextValue("leave_date"));	
}
%>
<form action="./faculty_leave.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - EDIT TIME-IN TIME-OUT PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23">Employee ID </td>
      <td width="21%" height="23">
        <input name="emp_id" type="text" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16"
	   onKeyUp="AjaxMapName(1);">
        &nbsp; </td>
      <td width="19%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
      <td width="63%" rowspan="4" valign="top">
<% if (WI.fillTextValue("emp_id").length() > 0) {

    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vPersonalDetails!=null){
%>
        <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
          <tr>
            <td> <table width="100%" border="0" cellspacing="0" cellpadding="3">
                <tr>
                  <td width="27%" rowspan="4">
                    <%strTemp = "<img src=\"../../../upload_img/" + WI.fillTextValue("emp_id").toUpperCase() + 
								"."+strImgFileExt+"\" width=100 height=100>";%>
								
                    <%=strTemp%> </td>
					<% strTemp = WI.formatName((String)vPersonalDetails.elementAt(1), 
												(String)vPersonalDetails.elementAt(2),
												(String)vPersonalDetails.elementAt(3), 4); %>
												
                  <td width="73%" height="25"><strong><font size=1>Name : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr>
                  <td height="25"><strong><font size=1>Position: <%=WI.getStrValue((String)vPersonalDetails.elementAt(15))%></font></strong></td>
                </tr>
                <tr>
							 <%
							 if((String)vPersonalDetails.elementAt(13) == null)
								strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
							 else {
									strTemp =WI.getStrValue((String)vPersonalDetails.elementAt(13));
									if((String)vPersonalDetails.elementAt(14) != null)
									 strTemp += "/" + WI.getStrValue((String)vPersonalDetails.elementAt(14));
								}
								%>
                  <td height="25"><strong><font size=1>Office/College: <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr>
                  <td height="25"><strong><font size=1>Status: <%=WI.getStrValue((String)vPersonalDetails.elementAt(16))%></font></strong></td>
                </tr>
              </table></td>
          </tr>
        </table>
        <%}else{%>
	<font size=2><strong><%=authentication.getErrMsg()%></strong></font>
<%}}%>	</td>
    </tr>
		<%
		strTemp = WI.fillTextValue("leave_date");
		if(strTemp.length() == 0)
			strTemp = WI.getTodaysDate(1);
		%>		
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="2">
			<label id="coa_info" style="position:absolute;"></label>
			<%
			if(strTemp != null && strTemp.length() > 0){
				strTemp2 = ConversionTable.addMMDDYYYY(strTemp, -1, 0, 0);
 				if(strTemp2 != null && strTemp2.length() > 0){
 			%>
			<a href="javascript:gotoDate('<%=strTemp2%>');">&lt;&lt;Prev Date</a>
			<%
			}
				strTemp2 = ConversionTable.addMMDDYYYY(strTemp, 1, 0, 0);				
				if(strTemp2 != null && strTemp2.length() > 0){
			%>
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<a href="javascript:gotoDate('<%=strTemp2%>');">Next Date&gt;&gt;</a>
			<%}
			}%>
			</td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td>Date</td>
      <td colspan="2"><input name="leave_date" type="text" size="12" maxlength="12" value="<%=strTemp%>"
	    onfocus="style.backgroundColor='#D3EBFF'" class="textbox" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','leave_date','/');"
			onKeyUp = "AllowOnlyIntegerExtn('dtr_op','leave_date','/')">
      <a href="javascript:show_calendar('dtr_op.leave_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr>
      <td width="3%" height="35">&nbsp;</td>
      <td width="13%" height="25">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ViewRecords()"  src="../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
  </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="852%" height="15" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="20" colspan="4">
		<%if(vSchedule != null && vSchedule.size() > 0){%>
		<table  bgcolor="#FFFFFF" width="85%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="4" align="center" bgcolor="#B9B292" class="thinborder">LIST OF 
      CURRENT WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%></td>
    </tr>
    <tr> 
      <td width="50%" height="26" align="center" class="thinborder"><strong>TIME</strong></td>
	    <td width="25%" align="center" class="thinborder"><strong>DURATION</strong></td>
	    <td width="25%" align="center" class="thinborder"><strong>ROOM NO</strong></td>
      <td width="25%" align="center" class="thinborder"><strong>SUBJECT TYPE </strong></td>
    </tr>
<%
 for(int i = 0; i < vSchedule.size(); i += 35){%>
   <tr> 
      <%
			strTemp = (String)vSchedule.elementAt(i + 4);
			strTemp2 = WI.getStrValue((String)vSchedule.elementAt(i+5),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" +astrConverAMPM[Integer.parseInt((String)vSchedule.elementAt(i+6))];
			
			// time to here
			strTemp += " - " + (String)vSchedule.elementAt(i + 8);
			strTemp2 = WI.getStrValue((String)vSchedule.elementAt(i+9),"0");
			if (strTemp2.length() < 2)
				strTemp += ":0" + strTemp2;
			else
				strTemp += ":" + strTemp2;
				
			strTemp += "&nbsp;" + astrConverAMPM[Integer.parseInt((String)vSchedule.elementAt(i+10))];
			%>
      <td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strSubjType = WI.getStrValue((String)vSchedule.elementAt(i + 24),"0");
				
				dDuration = Double.parseDouble((String)vSchedule.elementAt(i + 7)) - Double.parseDouble((String)vSchedule.elementAt(i + 3));
				dDuration = dDuration/3600000;
				adSubjTotal[Integer.parseInt(strSubjType)] += dDuration;
			%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dDuration, false)%> hrs&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vSchedule.elementAt(i + 27),"&nbsp;")%></td>
			<%
			strTemp = astrSubjType[Integer.parseInt(strSubjType)];
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
   </tr>
<%}%>
  </table>
		<%}%>		</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td>&nbsp;</td>
          <td>Max Credited Leave per day </td>
          <td colspan="3"><input name="max_leave" type="text" class="textbox_noborder" value="4.8" 
				  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					size="5" style="text-align:right" readonly>
            hrs</td>
        </tr>
        <tr>
          <td width="2%">&nbsp;</td>
          <td width="15%">Lecture</td>
					<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.fillTextValue("lec_");
						
					strTemp = WI.getStrValue(strTemp, "0");
					if(Double.parseDouble(strTemp) == 0)
						strTemp = "";
					%>
          <td width="13%">
<input name="lec_" type="text" class="textbox" value="<%=strTemp%>" 
				  onFocus="style.backgroundColor='#D3EBFF'" size="5" style="text-align:right" 
					onBlur="style.backgroundColor='white'; AllowOnlyFloat('dtr_op','lec_');checkVal('lec_');" 
					onKeyUp="AllowOnlyFloat('dtr_op','lec_');">	hrs<label id="lec_note"></label></td>
					<%
					strTemp = "";
					if(adSubjTotal[0] > 0)
						strTemp = CommonUtil.formatFloat(adSubjTotal[0], false);
					%>					
					<input type="hidden" name="lec_max" value="<%=WI.getStrValue(strTemp, "0")%>">
          <td width="9%" align="right"><strong><%=WI.getStrValue(strTemp, ""," hrs","")%></strong>&nbsp; </td>
          <td width="61%">&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
					<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.fillTextValue("lab_");
						
					strTemp = WI.getStrValue(strTemp, "0");
					if(Double.parseDouble(strTemp) == 0)
						strTemp = "";
					%>
          <td>Laboratory</td>
          <td><input name="lab_" type="text" class="textbox" value="<%=strTemp%>" 
				  onfocus="style.backgroundColor='#D3EBFF'" size="5" style="text-align:right" 
					onBlur="style.backgroundColor='white'; AllowOnlyFloat('dtr_op','lab_');checkVal('lab_');" 
					onKeyUp="AllowOnlyFloat('dtr_op','lab_');">
            hrs<label id="lab_note"></label></td>
					<%
					strTemp = "";
					if(adSubjTotal[1] > 0)
						strTemp = CommonUtil.formatFloat(adSubjTotal[1], false);
					%>					
					<input type="hidden" name="lab_max" value="<%=WI.getStrValue(strTemp, "0")%>">
          <td align="right"><strong><%=WI.getStrValue(strTemp, ""," hrs","")%></strong>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>RLE</td>
					<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("rle_");
						
					strTemp = WI.getStrValue(strTemp, "0");
					if(Double.parseDouble(strTemp) == 0)
						strTemp = "";
					%>					
          <td><input name="rle_" type="text" class="textbox" value="<%=strTemp%>" 
				  onfocus="style.backgroundColor='#D3EBFF'" size="5" style="text-align:right" 
					onBlur="style.backgroundColor='white'; AllowOnlyFloat('dtr_op','rle_');checkVal('rle_');" 
					onKeyUp="AllowOnlyFloat('dtr_op','rle_');">
            hrs<label id="rle_note"></label></td>
					<%
					strTemp = "";
					if(adSubjTotal[2] > 0)
						strTemp = CommonUtil.formatFloat(adSubjTotal[2], false);
					%>					
					<input type="hidden" name="rle_max" value="<%=WI.getStrValue(strTemp, "0")%>">
          <td align="right"><strong><%=WI.getStrValue(strTemp, ""," hrs","")%></strong>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>NSTP</td>
					<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);
					else
						strTemp = WI.fillTextValue("nstp_");
						
					strTemp = WI.getStrValue(strTemp, "0");
					if(Double.parseDouble(strTemp) == 0)
						strTemp = "";
					%>								
          <td><input name="nstp_" type="text" class="textbox" value="<%=strTemp%>" 
				  onfocus="style.backgroundColor='#D3EBFF'" size="5" style="text-align:right" 
					onBlur="style.backgroundColor='white'; AllowOnlyFloat('dtr_op','nstp_');checkVal('nstp_');" 
					onKeyUp="AllowOnlyFloat('dtr_op','nstp_');">
            hrs<label id="nstp_note"></label></td>
					<%
					strTemp = "";
					if(adSubjTotal[3] > 0)
						strTemp = CommonUtil.formatFloat(adSubjTotal[3], false);
					%>					
					<input type="hidden" name="nstp_max" value="<%=WI.getStrValue(strTemp, "0")%>">
          <td align="right"><strong><%=WI.getStrValue(strTemp, ""," hrs","")%></strong>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <tr>
          <td>&nbsp;</td>
          <td>Graduate</td>
					<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("grad_");
						
					strTemp = WI.getStrValue(strTemp, "0");
					if(Double.parseDouble(strTemp) == 0)
						strTemp = "";
					%>							
          <td><input name="grad_" type="text" class="textbox" value="<%=strTemp%>" 
				  onfocus="style.backgroundColor='#D3EBFF'" size="5" style="text-align:right" 
					onBlur="style.backgroundColor='white'; AllowOnlyFloat('dtr_op','grad_');checkVal('grad_');" 
					onKeyUp="AllowOnlyFloat('dtr_op','grad_');">
            hrs<label id="grad_note"></label></td>
					<%
					strTemp = "";
					if(adSubjTotal[4] > 0)
						strTemp = CommonUtil.formatFloat(adSubjTotal[4], false);
					%>					
					<input type="hidden" name="grad_max" value="<%=WI.getStrValue(strTemp, "0")%>">
          <td align="right"><strong><%=WI.getStrValue(strTemp, ""," hrs","")%></strong>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        
      </table></td>
    </tr>
    <tr>
      <td height="18" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"> <div align="center">
        <%if (vEditInfo == null) {%>
        <!--
					<a href="javascript:AddRecord();"><img src="../../../images/save.gif" width="48" height="28" border="0"></a>
					-->
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
        <font size="1">click to add</font>
        <%}else{%>
        <!--
					<a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
					-->
        <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:EditRecord();">
        <font size="1">click to save changes</font>
        <%}%>
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
					-->
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
        <font size="1">click to cancel or go previous</font></div></td>
    </tr>
    <tr>
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
	<%if (vRetResult != null && vRetResult.size() > 0){	%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  <tr>
    <td width="16%" align="center" class="thinborder">Lecture</td>
    <td width="16%" align="center" class="thinborder">Laboratory</td>
    <td width="16%" align="center" class="thinborder">RLE</td>
    <td width="16%" align="center" class="thinborder">NSTP</td>
    <td width="16%" align="center" class="thinborder">Graduate</td>
    <td width="20%" align="center" class="thinborder">TOTAL</td>
    <td width="20%" align="center" class="thinborder">OPTION</td>
  </tr>
	<%for(int i = 0; i < vRetResult.size();i += 15){%>
  <tr>
		<%
			strTemp = (String)vRetResult.elementAt(i+3);
			strTemp = WI.getStrValue(strTemp, "0");
			if(Double.parseDouble(strTemp) == 0)
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+4);
			strTemp = WI.getStrValue(strTemp, "0");
			if(Double.parseDouble(strTemp) == 0)
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+5);
			strTemp = WI.getStrValue(strTemp, "0");
			if(Double.parseDouble(strTemp) == 0)
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+7);
			strTemp = WI.getStrValue(strTemp, "0");
			if(Double.parseDouble(strTemp) == 0)
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+6);
			strTemp = WI.getStrValue(strTemp, "0");
			if(Double.parseDouble(strTemp) == 0)
				strTemp = "&nbsp;";
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		<%
			strTemp = (String)vRetResult.elementAt(i+8);
		%>
    <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
    <td align="center" nowrap class="thinborder"><input type="button" name="122" value=" Edit " style="font-size:11px; height:24px;border: 1px solid #000000;" onClick="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>');">
      <input type="button" name="1222" value="Delete" style="font-size:11px; height:24px;border: 1px solid #000000;" onClick="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>');"></td>
  </tr>
	<%}%>
</table>

  <%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="prepareToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
