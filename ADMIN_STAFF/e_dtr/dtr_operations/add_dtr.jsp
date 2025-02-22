<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut" %>
<%
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;

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
		document.dtr_op.iAction.value = 4;
		document.dtr_op.prepareToEdit.value = 0;
		document.dtr_op.show_list.value = 1;		
	}

	function PrepareToEdit(index, bTimeInTimeOut){
 		document.dtr_op.prepareToEdit.value = 1;
		document.dtr_op.bTimeIn.value= bTimeInTimeOut;
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

	function AddRecord(){
		if(document.dtr_op.txtReason.value.length < 3) {
			alert("Please enter reason.");
			return;
		}
		document.dtr_op.iAction.value = 1;
		document.dtr_op.submit();
	}

	function EditRecord(){
		if(document.dtr_op.txtReason.value.length < 3) {
			alert("Please enter reason.");
			return;
		}
		document.dtr_op.iAction.value = 2;
		document.dtr_op.bTimeIn.value = document.dtr_op.strStatus1.value;
		
		document.dtr_op.submit();
	}

	function CancelEdit(){
		location = "./add_dtr.jsp?emp_id=" + document.dtr_op.emp_id.value + 
			"&requested_date="+document.dtr_op.requested_date.value+
			"&show_list=1";
	}

	function DeleteRecord(index,strAMPM){
		document.dtr_op.iAction.value = "0";
		document.dtr_op.bTimeIn.value = strAMPM;
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}
/*	
	function ClearDate(){
	 document.dtr_op.requested_date.value = "";
	 //document.dtr_op.submit();
	}
*/
	function updateWH(strIndex){
	var loadPg = "./wh_update.jsp?emp_id=" + strIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

function UpdateLateUT(strInfoIndex,strTinTout,iCtr){
	document.dtr_op.info_index.value = strInfoIndex;
	document.dtr_op.bTimeIn.value = strTinTout;
	eval('document.dtr_op.late_under_time_val.value=document.dtr_op.txtbox'+iCtr+'.value');
	document.dtr_op.iAction.value="5";
	document.dtr_op.submit();
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

function OtherPage(){
	document.dtr_op.set_group.value = "1";
	document.dtr_op.submit();
}

function gotoDate(strNewDate){
	document.dtr_op.requested_date.value = strNewDate;
	document.dtr_op.submit();
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
	if (WI.fillTextValue("set_group").compareTo("1")== 0){ 
	%>
	<jsp:forward page="./add_dtr_set.jsp" />
	<%  return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","add_dtr.jsp");

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
														"add_dtr.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP, (String)request.getSession(false).getAttribute("userId"),
															"eDaily Time Record","DTR Operations-Adjust DTR",request.getRemoteAddr(),
															"add_dtr.jsp");
}
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



TimeInTimeOut TInTOut = new TimeInTimeOut();
Vector vTimeInList = null;
Vector vPersonalDetails = null;
Vector vRetResult =  null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strLateUnderTime = null;
String[] astrExcuse = {"Unexcused", "Excused"};
int iPageAction  = 0;
strTemp = WI.fillTextValue("iAction");
iPageAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
//	System.out.println("1- " + ConversionTable.compareDate("9/11/2009", "9/12/2009"));
//	System.out.println("2- " + ConversionTable.compareDate("9/11/2009", "9/11/2009"));
//	System.out.println("3- " + ConversionTable.compareDate("9/12/2009", "9/11/2009"));
if (iPageAction == 0 || iPageAction == 1 || iPageAction == 2 || iPageAction == 5){
  switch (iPageAction){
	case 0:
			if (TInTOut.operateOnTimeInTimeOut(dbOP,request,iPageAction) == null)
				strErrMsg = TInTOut.getErrMsg();
			else
				strErrMsg = " Record deleted successfully";
			break;
	case 1:
			if (TInTOut.operateOnTimeInTimeOut(dbOP,request,iPageAction) == null)
				strErrMsg = TInTOut.getErrMsg();
			else{
				strErrMsg = " Record added successfully";
			}
			break;
	case 2:
			if (TInTOut.operateOnTimeInTimeOut(dbOP,request,iPageAction) == null)
				strErrMsg = TInTOut.getErrMsg();
			else{
				strErrMsg = " Record edited successfully";
				strPrepareToEdit = "0";
			}
			break;
	case 5 :
			if (TInTOut.updateLateUnderTime(dbOP,request))
				strErrMsg = TInTOut.getErrMsg();
			else{
				strErrMsg = " Record edited successfully";
			}
	} // end switch
}


if(strPrepareToEdit.equals("1")){
	vRetResult = TInTOut.getTimeInTimeOutDetails(dbOP,request);
}


if (WI.fillTextValue("show_list").equals("1")) { 
	if (WI.fillTextValue("requested_date").length() < 1) {
		vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP, request,4);
		
	}else{
		vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP, request,3);
	}
	
	if (vTimeInList == null || vTimeInList.size() == 0){
		if(strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg  = TInTOut.getErrMsg();
	}	
}

if(WI.fillTextValue("emp_id").trim().equals(strUserID)) {
	vTimeInList = null;
	strErrMsg   = "Can't process your own ID.";
	vRetResult  = null;
}


%>
<form action="./add_dtr.jsp" method="post" name="dtr_op">
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
		else
			{
			strTemp =WI.getStrValue((String)vPersonalDetails.elementAt(13));
			if((String)vPersonalDetails.elementAt(14) != null)
		 	 strTemp += "/" + WI.getStrValue((String)vPersonalDetails.elementAt(14));
			}
%>
                  <td height="25"><strong><font size=1>Office/<%if(bolIsSchool){%>College<%}else{%>Division<%}%>: <%=WI.getStrValue(strTemp)%></font></strong></td>
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
		strTemp = WI.fillTextValue("requested_date");
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
      <td colspan="2"><input name="requested_date" type="text" size="12" maxlength="12" value="<%=strTemp%>"
	    onfocus="style.backgroundColor='#D3EBFF'" class="textbox" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','requested_date','/');"
			onKeyUp = "AllowOnlyIntegerExtn('dtr_op','requested_date','/')">
        <a href="javascript:show_calendar('dtr_op.requested_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<!--
		&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1">
        clear the date</font> -->

				<a href="javascript:OtherPage();">set by group</a></td>
    </tr>
    <tr>
      <td width="3%" height="35">&nbsp;</td>
      <td width="13%" height="25">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ViewRecords()"  src="../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
  </table>
 <% if (vPersonalDetails!=null && WI.fillTextValue("emp_id").trim().length() > 0){ %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="20" colspan="4"><hr size="1"></td>
    </tr>
<%
if (vRetResult != null && vRetResult.size() > 0){	
%>

    <tr>
      <td height="25">&nbsp;</td>
      <td>WORKING HOUR</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(9),"");
			%>
      <td style="font-size:9px; color:#0000FF; font-weight:bold"><%=strTemp%>
	  <input name="wh_index" type="hidden" value='<%=WI.getStrValue((String)vRetResult.elementAt(5),"")%>'>	  </td>
      <td>
			 <%  if (WI.fillTextValue("bTimeIn").equals("0")){ %>
		  <a href='javascript:updateWH("<%=WI.fillTextValue("emp_id")%>");'><img src="../../../images/update.gif" alt="update working hour" width="60" height="26" border="0"></a><font size="1">click
        to update work schedule </font>
      <%}%>
		&nbsp;</td>
    </tr>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
			<%
	strTemp =WI.getStrValue((String)vRetResult.elementAt(1));
 	if (strTemp.equals("00")) 
		strTemp="12";			
			%>			
      <td width="18%">NEW TIME</td>
      <td width="36%"><input name="hh" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        :
        <input name="mm" type="text" size="2" maxlength="2" 
		value="<%=WI.getStrValue((String)vRetResult.elementAt(2))%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
       <% strTemp =(String)vRetResult.elementAt(3);
	   if (strTemp== null) 
   			strTemp = WI.fillTextValue("am_pm");
				%> 
   		<select name="am_pm">
          <option value="0" >A.M.</option>
          <%	if (strTemp.compareTo("PM") == 0){ %>
          <option value="1" selected>P.M.</option>
          <%}else{%>
          <option value="1">P.M.</option>
          <%}%>
      </select></td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td> STATUS </td>
      <td colspan="2"> 
<% 
	strTemp = WI.fillTextValue("bTimeIn");

	if (strTemp.equals("0")){
		strTemp = "TIME IN";
		strLateUnderTime = "LATE";
	}else{
		strTemp = "TIME OUT";
		strLateUnderTime = "UNDERTIME";
	}
%> <strong><%=strTemp%></strong> <input name="strStatus1" type="hidden" 
				value="<%=WI.fillTextValue("bTimeIn")%>" size="12" maxlength="12" readonly>
		 <%if(WI.fillTextValue("bTimeIn").equals("1")){%>
				<input type="checkbox" name="nextday_logout" value="1" <%=strTemp%>>				
				<font size="1">Next day logout </font>
			<%}%>
			</td>
       
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%=strLateUnderTime%></td>
	  
<%  
	strTemp = WI.getStrValue((String)vRetResult.elementAt(6));
	if (strTemp.length() == 0 || strTemp.equals("0"))
		strTemp = "";
	
%>
      <td colspan="2">
		<input name="late_under_time" type="text" size="3" maxlength="3" 
		   value="<%=strTemp%>" class="textbox"
		   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		   onKeyUp="AllowOnlyInteger('dtr_op','late_under_time')">	    

<% 
	if (WI.getStrValue((String)vRetResult.elementAt(7)).equals("1")){
		strTemp = "checked";
	}else{
		strTemp = "";
	}
%>		
		<input type="checkbox" name="is_excused" value="1" <%=strTemp%>> 
		<strong><font size="1">Excused?
		&nbsp;&nbsp;&nbsp;Reason :</font></strong>
		<input name="excused_reason" type="text" size="32" maxlength="128"
		 value="<%=WI.getStrValue((String)vRetResult.elementAt(8))%>"
 	     class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	     onBlur="style.backgroundColor='white'"></td>
    </tr>	

    <%}else{%>
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="18%">NEW TIME</td>
      <td width="36%"> <input name="hh" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("hh")%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        :
        <input name="mm" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
				<%				
					strTemp = WI.fillTextValue("am_pm");					
				%>
        <select name="am_pm">
          <option value="0" >A.M.</option>
          <%	if (strTemp.compareTo("1") == 0){ %>
          <option value="1" selected>P.M.</option>
          <%}else{%>
          <option value="1">P.M.</option>
          <%}%>
      </select> </td>
      <td width="40%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>NEW STATUS </td>
      <td><select name="strStatus2" onChange="showNextday();">
          <option value="0"> Time-In</option>
          <% if (WI.fillTextValue("strStatus2").equals("1")) {%>
          <option value="1" selected> Time-Out</option>
          <% }else{ %>
          <option value="1">Time-Out</option>
          <% } %>
        </select>
        <input type="checkbox" name="nextday_logout" value="1" disabled>
        <font size="1">Next day logout </font></td>
      <td>&nbsp;</td>
    </tr>
<!-- NOT allowed to edit date of time in / time out because users are required to have time in / time out date same
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;&nbsp;&nbsp;DATE</td>
      <td> <input name="requested_date2" type="text" size="12" maxlength="12" readonly value="<%=WI.fillTextValue("requested_date2")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('dtr_op.requested_date2');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
-->	
    <%}%>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="3">REASON FOR ADJUSTMENT:</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="top"><textarea name="txtReason" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("txtReason")%></textarea></td>
    </tr>
    
    <tr>
      <td height="25" colspan="4"> <div align="center">
          <%
    if(WI.getStrValue(strPrepareToEdit,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <a href="javascript:AddRecord();"><img src="../../../images/add.gif" width="42" height="32" border="0"></a>
          <font size="1">click to add record </font>
          <%     } // end iAccessLevel  > 1
  }else{ %>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
          <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1">click to cancel or go previous</font>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
    <%
	if ((vTimeInList != null) && (vTimeInList.size()>0)) { %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  
  			bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" align="center" class="thinborder"><font color="#FFFFFF">
	  	<strong>LIST OF TIME RECORDED</strong></font></td>
    </tr>
    <tr >
      <td width="22%" height="25" align="center" class="thinborder"><strong>DAY :: TIME</strong></td>
      <td width="19%" align="center" class="thinborder"><strong>STATUS</strong></td>
      <td width="18%" align="center" class="thinborder"><strong>LATE / UNDERTIME</strong></td>
      <% if (strSchCode.startsWith("CGH")){%> 
      <td width="28%" align="center" class="thinborder"><strong>EXCUSED / UNEXCUSED</strong> </td>
	  <%} if (strUserID.equals("jan bs")){%> 
      <td width="8%" align="center" class="thinborder">&nbsp;</td>
	  <%}%>
      <td width="5%" height="25" align="center" class="thinborder"><strong>EDIT </strong></td>
      <td width="8%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <%  
		int iCtr = 0;
		for (int i=0; i < vTimeInList.size() ; i+=11,iCtr++){ %>
    <tr >
      <td height="25"  class="thinborder">&nbsp;<%=(String)vTimeInList.elementAt(i)%></td>
      <td  class="thinborder">&nbsp;TIME IN</td>
	  <% strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+5));
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
			strTemp = ""; %>	  
	  <td  class="thinborder">&nbsp;
	  	<input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
		maxlength="3" <% if (!strUserID.equals("jan bs")){%> readonly <%}%> 
		name="txtbox<%=iCtr%>">
 		<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>	min(s) <%}%>
	  </td>
	  
      <% if (strSchCode.startsWith("CGH")){%> 
      <td  class="thinborder">&nbsp;
	  	<%if (strTemp.length() != 0) {%> 
	  		<%=astrExcuse[Integer.parseInt(WI.getStrValue((String)vTimeInList.elementAt(i+7),"0"))]%>
	  		<%=WI.getStrValue((String)vTimeInList.elementAt(i+9),"(",")","")%>
			<%}%></td>
    <%}%> 
		<% if (strUserID.equals("jan bs")){%>		
      <td  class="thinborder">
		<a href="javascript:UpdateLateUT('<%=(String)vTimeInList.elementAt(i+4)%>','0','<%=iCtr%>')">
			<img src="../../../images/update.gif" border="0"></a>

	 </td>
<%}%>

      <td align="center"  class="thinborder"><% if (iAccessLevel > 1){ %>
          <a href='javascript:PrepareToEdit("<%=(String)vTimeInList.elementAt(i+4)%>","0")'>
					<img src="../../../images/edit.gif" width="40" height="26" border="0">
					</a>
					
			<%}%></td>
      <td align="center"  class="thinborder">&nbsp;<% if (iAccessLevel == 2){ %>
          <a href='javascript:DeleteRecord("<%=(String)vTimeInList.elementAt(i+4)%>","0");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
          <%}%></td>
    </tr>
	<% if ((String)vTimeInList.elementAt(i+1) !=null ) {%>
    <tr>
      <td  class="thinborder">&nbsp;<%=(String)vTimeInList.elementAt(i+1)%></td>
      <td  class="thinborder">&nbsp;TIME OUT</td>
        <%	strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+6));
		 	if (strTemp.length() == 0 || strTemp.equals("0"))   
				strTemp = ""; 
		%>	  
      <td  class="thinborder">&nbsp;
	  	<input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
		maxlength="3" <% if (!strUserID.equals("jan bs")){%> readonly <%}%> name="txtbox<%=++iCtr%>">		
				<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>	min(s) <%}%> 
	 </td>
      <% if (strSchCode.startsWith("CGH")){%> 
      <td  class="thinborder">&nbsp;
	  <%if ((String)vTimeInList.elementAt(i+6) != null) {%> 
	      <%=astrExcuse[Integer.parseInt(WI.getStrValue((String)vTimeInList.elementAt(i+8),"0"))]%>
	      <%=WI.getStrValue((String)vTimeInList.elementAt(i+10),"(",")","")%>
	  <%}%></td>
      <%}%>	  
<% if (strUserID.equals("jan bs")){%>		
      <td  class="thinborder">
		<a href="javascript:UpdateLateUT('<%=(String)vTimeInList.elementAt(i+4)%>','1','<%=iCtr%>')">
			<img src="../../../images/update.gif" border="0"></a>

	 </td>
<%}%>

      <td height="25" align="center"  class="thinborder">
          <% if (iAccessLevel > 1){ %>
					<a href='javascript:PrepareToEdit("<%=(String)vTimeInList.elementAt(i+4)%>","1")'>
          <img src="../../../images/edit.gif" width="40" height="26" border="0">
					</a>
          <%}%></td>
      <td height="25" align="center"  class="thinborder">&nbsp;<% if (iAccessLevel == 2){ %>
          <a href='javascript:DeleteRecord ("<%=(String)vTimeInList.elementAt(i+4)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
      <%}%></td>
    </tr>
    <%} // end ((String)vTimeInList.elementAt(i+1) == null)
 } //end for loop

%>
  </table>
<%}} // end else (vTimeInList == null)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="set_group">
<input type="hidden" name="prepareToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
<input type="hidden" name="iAction" value="">
<input type="hidden" name="bTimeIn" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<!--
<input type="hidden" name="noAdjustment" value="1">
-->
<input type="hidden" name="info_logged" value="<%=WI.fillTextValue("info_logged")%>">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
<input type="hidden" name="late_under_time_val" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
