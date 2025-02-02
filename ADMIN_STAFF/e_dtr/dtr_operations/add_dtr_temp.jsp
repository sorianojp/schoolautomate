<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut,
																eDTR.TempDTR" %>
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
<title>Manual add time in time out </title>
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
		document.dtr_op.prepareToEditTemp.value = "";
		document.dtr_op.bTimeIn.value= bTimeInTimeOut;
		document.dtr_op.info_index.value = index;
	}

	function PrepareToEditTemp(index, bTimeInTimeOut){
 		document.dtr_op.prepareToEditTemp.value = 1;
		document.dtr_op.prepareToEdit.value = "";
		document.dtr_op.bTimeIn.value= bTimeInTimeOut;
		document.dtr_op.temp_index.value = index;
	}
	
	function AddRecord(){
		document.dtr_op.iAction.value = 1;
	}

	function EditRecordTemp(){
		document.dtr_op.iAction.value = 7;
		document.dtr_op.submit();
		//document.dtr_op.bTimeIn.value = document.dtr_op.strStatus1.value;
	}

	function EditRecord(){
		document.dtr_op.iAction.value = 2;
		
		//document.dtr_op.bTimeIn.value = document.dtr_op.strStatus1.value;
	}

	function CancelEdit(){
		location = "./add_dtr_temp.jsp?emp_id=" + document.dtr_op.emp_id.value + 
			"&requested_date="+document.dtr_op.requested_date.value+
			"&show_list=1";
	}

	function DeleteRecord(index,strAMPM){
		document.dtr_op.iAction.value = "0";
		document.dtr_op.bTimeIn.value = strAMPM;
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

	function DeleteTempRecord(index){
		document.dtr_op.iAction.value = "5";
		document.dtr_op.temp_index.value = index;
		document.dtr_op.prepareToEditTemp.value = "";
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
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no');
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

-->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
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
								"Admin/staff-eDaily Time Record-DTR Operations-Add Temp Timein/timeout","add_dtr_temp.jsp");

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
														"add_dtr_temp.jsp");
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
TempDTR tempDTR = new TempDTR();
Vector vTimeInList = null;
Vector vListForEdit = null;
Vector vPersonalDetails = null;
Vector vEditInfo =  null;
Vector vEditTempInfo =  null;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
String strPrepareToEditTemp = WI.getStrValue(WI.fillTextValue("prepareToEditTemp"),"0");
String strLateUnderTime = null;
String[] astrExcuse = {"Unexcused", "Excused"};
String[] astrEditStatus = {"Delete Request", "Save New", "Edit Existing"};
int iPageAction  = 0;
int iCtr = 0;
strTemp = WI.fillTextValue("iAction");
iPageAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));

if (iPageAction == 0 || iPageAction == 1 || iPageAction == 2 || iPageAction == 5 || iPageAction == 7){
  switch (iPageAction){
	case 0:
			if (tempDTR.operateOnTempDTRRecord(dbOP,request,0) == null)
				strErrMsg = tempDTR.getErrMsg();
			else
				strErrMsg = " Delete request added successfully";
			break;
	case 1:
			vListForEdit = tempDTR.operateOnTempDTRRecord(dbOP,request,1);
			if (vListForEdit == null)
				strErrMsg = tempDTR.getErrMsg();
			else{
				strErrMsg = " New Time Request added successfully";
			}
			break;
	case 2:
			vListForEdit = tempDTR.operateOnTempDTRRecord(dbOP,request,2);
			if (vListForEdit == null)
				strErrMsg = tempDTR.getErrMsg();
			else{
				strErrMsg = "Edit time request added successfully";
				strPrepareToEdit = "0";
			}
			break;
	case 5 :
			if (tempDTR.operateOnTempDTRRecord(dbOP,request,5) == null)
				strErrMsg = tempDTR.getErrMsg();
			else
				strErrMsg = " Request deleted successfully";
			break;
	case 7 :
			if (tempDTR.operateOnTempDTRRecord(dbOP, request, 7) == null)
				strErrMsg = tempDTR.getErrMsg();
			else{
				strErrMsg = " Request updated successfully";
				strPrepareToEditTemp = "0";
			}
			break;			
	} // end switch
}

if(strPrepareToEdit.equals("1")){
	vEditInfo = TInTOut.getAllTimeInTimeOutDetails(dbOP,request);
}else if(strPrepareToEditTemp.equals("1")){
	vEditTempInfo = tempDTR.getTempTimeDetails(dbOP, request);	
}

vListForEdit = tempDTR.operateOnTempDTRRecord(dbOP, request, 4);

if (WI.fillTextValue("show_list").equals("1")) { 
	if (WI.fillTextValue("requested_date").length() < 1) {
		vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP, request,4);
	}else{
		vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP, request,3);
	}
	
	if (vTimeInList == null || vTimeInList.size() == 0){
		if(strErrMsg == null)	
			strErrMsg = TInTOut.getErrMsg();
	}
}
%>

<form action="./add_dtr_temp.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - ADJUST TEMPORARY DTR PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" align="left">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
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
      <td width="19%">
			<a href="javascript:OpenSearch();">
				<img src="../../../images/search.gif" width="37" height="30" border="0">
			</a>
			<div id="emp_list" style="position:absolute; height:120px; width:400px;  overflow:auto;">
				<label id="coa_info"></label>
			</div>
			</td>
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
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20" colspan="3"></td>
    </tr>
    <tr>
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2">
<%
strTemp = WI.fillTextValue("requested_date");
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%>	  <input name="requested_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('dtr_op.requested_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
<!--
		&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1">
        clear the date</font> --></td>
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
    <tr>
      <td width="6%" height="25">&nbsp;</td>
      <td width="94%" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <%//if((vEditInfo != null && vEditInfo.size() > 0) || (vEditTempInfo != null && vEditTempInfo.size() > 0)){%>
				<tr>
          <td>WORKING HOUR</td>
					<%
						if(vEditTempInfo != null && vEditTempInfo.size() > 0){
							strTemp = WI.getStrValue((String)vEditTempInfo.elementAt(2),"");
							strTemp2 = WI.getStrValue((String)vEditTempInfo.elementAt(12),"");
						}else if(vEditTempInfo != null && vEditTempInfo.size() > 0){
							strTemp = WI.getStrValue((String)vEditInfo.elementAt(2),"");
							strTemp2 = WI.getStrValue((String)vEditInfo.elementAt(16),"");
						}else{
							strTemp = "";
							strTemp2 = "";
						}
					%>
          <td><font size="1" color="#0000FF"><%=strTemp2%></font>
					<input name="wh_index" type="hidden" value='<%=strTemp%>'>
					</td>
          <td>
            <a href='javascript:updateWH("<%=WI.fillTextValue("emp_id")%>");'><img src="../../../images/update.gif" alt="update working hour" width="60" height="26" border="0"></a><font size="1">click
        to update work schedule </font>&nbsp;</td>
        </tr>
				<%//}%>
        <tr>
          <td width="23%">NEW TIME In </td>
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(3);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(3);
						else
							strTemp = WI.fillTextValue("hr_fr");
						if(strTemp.equals("00"))
							strTemp = "12";							
					%>
          <td width="28%"><input name="hr_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(4);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(4);							
						else
							strTemp = WI.fillTextValue("min_fr");
					%>
  <input name="min_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(5);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(5);							
						else
							strTemp = WI.fillTextValue("ampm_from");
						strTemp = WI.getStrValue(strTemp);
						if(strTemp.equals("PM"))
							strTemp = "1";							
					%>
  <select name="ampm_from">
    <option value="0" >A.M.</option>
    <%	if (strTemp.compareTo("1") == 0){ %>
    <option value="1" selected>P.M.</option>
    <%}else{%>
    <option value="1">P.M.</option>
    <%}%>
  </select></td>
          <td width="49%">&nbsp;</td>
          </tr>
        <tr>
          <td>NEW TIME Out </td>
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(7);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(7);
						else
							strTemp = WI.fillTextValue("hr_to");
						if(WI.getStrValue(strTemp).equals("00"))
							strTemp = "12";
					%>					
          <td><input name="hr_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(8);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(8);
						else
							strTemp = WI.fillTextValue("min_to");
					%>	
  <input name="min_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" 
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(9);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(9);
						else
							strTemp = WI.fillTextValue("ampm_to");
						strTemp = WI.getStrValue(strTemp);
						if(strTemp.equals("PM"))
							strTemp = "1";
					%>	
  <select name="ampm_to">
    <option value="0" >A.M.</option>
    <%	if (strTemp.compareTo("1") == 0){ %>
    <option value="1" selected>P.M.</option>
    <%}else{%>
    <option value="1">P.M.</option>
    <%}%>
  </select></td>
					<%
						strTemp = "";
						if(vEditInfo != null && vEditInfo.size() > 0){
							strTemp = (String)vEditInfo.elementAt(2);
							strTemp2 = (String)vEditInfo.elementAt(6);
							if(strTemp2 != null && !(strTemp2).equals(strTemp))
								strTemp = " checked";
						}
					%>	
          <td><input type="checkbox" name="nextday_logout" value="1" <%=strTemp%>>
            <font size="1">Next day logout</font></td>
          </tr>
        <tr>
          <td>Late <font size="1">(in minutes)</font></td>
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(10);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(10);							
						else
							strTemp = WI.fillTextValue("late_time_in");
					%>	
          <td colspan="2"><input name="late_time_in" type="text" size="3" maxlength="3" 
		   value="<%=strTemp%>" class="textbox"
		   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		   onKeyUp="AllowOnlyInteger('dtr_op','late_time_in')"></td>
        </tr>
        <tr>
          <td>Undertime <font size="1">(in minutes)</font></td>
					<%
						if(vEditInfo != null && vEditInfo.size() > 0)
							strTemp = (String)vEditInfo.elementAt(13);
						else if(vEditTempInfo != null && vEditTempInfo.size() > 0)
							strTemp = (String)vEditTempInfo.elementAt(11);
						else
							strTemp = WI.fillTextValue("undertime");
					%>	
          <td colspan="2"><input name="undertime" type="text" size="3" maxlength="3" 
		   value="<%=WI.getStrValue(strTemp)%>" class="textbox"
		   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		   onKeyUp="AllowOnlyInteger('dtr_op','undertime')">            </td>
          </tr>
      </table></td>
    </tr>     
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="3">REASON FOR ADJUSTMENT:</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="top"><textarea name="txtReason" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("txtReason")%></textarea>      </td>
    </tr>
    
    <tr>
      <td height="25" colspan="4"> <div align="center">
			<%if(strPrepareToEdit.equals("0") && strPrepareToEditTemp.equals("0")) {
					if (iAccessLevel > 1){
			%>
          <input type="image" src="../../../images/add.gif" width="42" height="32"
		  onClick="AddRecord()">
          <font size="1">click to add record </font>
          <%} // end iAccessLevel  > 1
		  }else if(strPrepareToEdit.equals("1")){%>
				<input type="image" src="../../../images/edit.gif" border="0" onClick='EditRecord()'>
			<%}else if(strPrepareToEditTemp.equals("1")){%>
				<a href='javascript:EditRecordTemp();'><img src="../../../images/edit.gif" border="0"></a>
			<%} if(strPrepareToEdit.equals("1") || strPrepareToEditTemp.equals("1")){%>					
          <font size="1">click to save changes</font> 
			<%}%>
					<a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1">click to cancel or go previous</font>
          
        </div></td>
    </tr>
    <tr>
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
    <%if ((vListForEdit != null) && (vListForEdit.size()>0)) {%>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  
  			bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="8" align="center" class="thinborder"><font color="#FFFFFF">
	  	<strong>LIST OF UPDATE REQUESTS </strong></font></td>
    </tr>
    <tr >
      <td width="20%" height="25" align="center" class="thinborder"><strong>TIME IN</strong></td>
      <td width="12%" align="center" class="thinborder"><strong>LATE</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>TIME OUT </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>UNDERTIME</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>TYPE</strong></td>
      <td width="10%" height="25" align="center" class="thinborder"><strong>EDIT </strong></td>
      <td width="10%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
		
    <% 
			for(int i = 0; i < vListForEdit.size();i+= 10 ){%>
		<tr bgcolor="#DDDDDD">
      <td height="25"  class="thinborder">&nbsp;<%=(String)vListForEdit.elementAt(i+1)%></td>
	  <% strTemp = WI.getStrValue((String)vListForEdit.elementAt(i+5));
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
			strTemp = ""; %>	  
	  <td  class="thinborder">&nbsp;
	  	<input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
		maxlength="3" readonly name="txtbox<%=iCtr%>" style="background-color:#DDDDDD">
 		<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>	min(s) <%}%>	  </td>
			<td  class="thinborder">&nbsp;<%=WI.getStrValue((String)vListForEdit.elementAt(i+2))%></td>
			<%	strTemp = WI.getStrValue((String)vListForEdit.elementAt(i+6));
				if (strTemp.length() == 0 || strTemp.equals("0"))   
					strTemp = ""; 
			%>	
      <td align="center"  class="thinborder"><input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
			 maxlength="3" readonly name="txtbox<%=++iCtr%>" style="background-color:#DDDDDD">
        <%if (strTemp.length() != 0 && !strTemp.equals("0")){%>
min(s)
<%}%></td>
      <td  class="thinborder">(<%=astrEditStatus[Integer.parseInt((String)vListForEdit.elementAt(i+9))]%>)</td>
      <td align="center"  class="thinborder"><% if (iAccessLevel > 1 && !((String)vListForEdit.elementAt(i+9)).equals("0")){%>
        <input name="image2" type="image"
					onClick='PrepareToEditTemp("<%=(String)vListForEdit.elementAt(i)%>","0")' src="../../../images/edit.gif" width="40" height="26">
        <%}else{%>
&nbsp;
<%}%></td>
      <td align="center"  class="thinborder"><% if (iAccessLevel == 2){ %>
        <a href='javascript:DeleteTempRecord("<%=(String)vListForEdit.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}%></td>
    </tr>
	<% if ((String)vListForEdit.elementAt(i+1) !=null ) {%>
    			
		<%}%>
	<%}// end for loop%>
  </table>
		<%}// end if vListForEdit != null%>
    <%
	if ((vTimeInList != null) && (vTimeInList.size()>0)) { %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  
  			bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF">
	  	<strong>LIST OF TIME RECORDED</strong></font></td>
    </tr>
    <tr >
      <td width="23%" height="25" align="center" class="thinborder"><strong>TIME IN</strong></td>
      <td width="16%" align="center" class="thinborder"><strong>LATE</strong></td>
			<td width="23%" align="center" class="thinborder"><strong>TIME OUT </strong></td>
      <td width="16%" align="center" class="thinborder"><strong>UNDERTIME</strong></td>
      <td width="11%" height="25" align="center" class="thinborder"><strong>EDIT </strong></td>
      <td width="11%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
		<% iCtr = 0;
		for (int i=0; i < vTimeInList.size() ; i+=11,iCtr++){ %>
    <tr >
      <td height="25"  class="thinborder">&nbsp;<%=(String)vTimeInList.elementAt(i)%></td>
      
	  <% strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+5));
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
			strTemp = ""; %>	  
	  <td  class="thinborder">&nbsp;
	  	<input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
		maxlength="3" <% if (!strUserID.equals("jan bs")){%> readonly <%}%> 
		name="txtbox<%=iCtr%>">
 		<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>	min(s) <%}%>	  </td>
			<td  class="thinborder">&nbsp;<%=WI.getStrValue((String)vTimeInList.elementAt(i+1))%></td>
        <%	strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+6));
					if (strTemp.length() == 0 || strTemp.equals("0"))   
						strTemp = ""; 
				%>	  			
      <td align="center"  class="thinborder"><input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
		maxlength="3" <% if (!strUserID.equals("jan bs")){%> readonly <%}%> name="txtbox<%=++iCtr%>2">
        <%if (strTemp.length() != 0 && !strTemp.equals("0")){%>
min(s)
<%}%></td>
      <td align="center"  class="thinborder"><% if (iAccessLevel > 1){ %>
          <input type="image" src="../../../images/edit.gif" width="40" height="26"
					onClick='PrepareToEdit("<%=(String)vTimeInList.elementAt(i+4)%>","0")'>
			<%}%></td>
      <td align="center"  class="thinborder">&nbsp;<% if (iAccessLevel == 2){ %>
          <a href='javascript:DeleteRecord("<%=(String)vTimeInList.elementAt(i+4)%>","0");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
          <%}%></td>
    </tr>
    <%
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

<input type="hidden" name="prepareToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
<input type="hidden" name="prepareToEditTemp" value=" <%=WI.getStrValue(strPrepareToEditTemp,"0")%>">
<input type="hidden" name="iAction" value="">
<input type="hidden" name="bTimeIn" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<!--
<input type="hidden" name="noAdjustment" value="1">
-->
<input type="hidden" name="info_logged" value="<%=WI.fillTextValue("info_logged")%>">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
<input type="hidden" name="late_under_time_val" value="">

<input type="hidden" name="temp_index" value="<%=WI.fillTextValue("temp_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
