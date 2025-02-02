<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining,hr.HRInfoServiceRecord"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Official Business.</title>
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
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//function viewInfo(){
//	this.SubmitOnce("form_");
//}

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord(){

	document.form_.page_action.value="2";
	document.form_.submit();
}

function DeleteRecord(strInfoIndex){
	document.form_.info_index.value=strInfoIndex;
	document.form_.page_action.value="0";
	document.form_.submit();	
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value =strInfoIndex;
	document.form_.prepareToEdit.value="1";
	document.form_.submit();
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelRecord(strEmpID){
	location = "./hr_employee_logout.jsp?my_home=<%=WI.fillTextValue("my_home")%>";
}

function FocusID() {
<% if (WI.fillTextValue("my_home").compareTo("1") != 0) {%>
	document.form_.emp_id.focus();
<%}%>
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
	document.form_.emp_id.value = strID;
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
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Logout(Official Time)","hr_employee_logout.jsp");

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

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_employee_logout.jsp");
	if(strSchCode.startsWith("TSUNEISHI") && iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","OFFICIAL BUSINESS",request.getRemoteAddr(),
														"hr_employee_logout.jsp");
	}
														
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome) {
		iAccessLevel = 1;
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//

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
Vector vRetResult = null;
Vector vEmpRec = null;
Vector vEditInfo = null;

HRInfoLicenseETSkillTraining hrPx = new HRInfoLicenseETSkillTraining();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

int iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));

if(!bolMyHome) {
	strTemp = WI.fillTextValue("emp_id");

	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
}

strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (iAction == 1 || iAction  == 2 || iAction==0)
	vRetResult = hrPx.operateOnEmpLogout(dbOP,request,iAction);
	
	switch(iAction){
		case 0:{
			if (vRetResult != null)
				strErrMsg = " Employee Logout (official time)  removed successfully.";
			else
				strErrMsg = hrPx.getErrMsg();

			break;
		}
		case 1:{ // add Record
			if (vRetResult != null)
				strErrMsg = " Employee Official business information added successfully.";
			else
				strErrMsg = hrPx.getErrMsg();

			break;
		}
		case 2:{ //  edit record
			if (vRetResult != null){
				strErrMsg = " Employee Official business information edited successfully.";
				strPrepareToEdit = "";
			}else
				strErrMsg = hrPx.getErrMsg();

			break;
		}
	} //end switch
	
	if (strPrepareToEdit.compareTo("1")  == 0){
		vEditInfo = hrPx.operateOnEmpLogout(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = hrPx.getErrMsg();
	}
	vRetResult = hrPx.operateOnEmpLogout(dbOP,request,4);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg= hrPx.getErrMsg();
}
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_employee_logout.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
           OFFICIAL BUSINESS ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
	  </td>
      <td width="57%"> <input type="image" src="../../../images/form_proceed.gif" border="0">
			<label id="coa_info"></label>
      </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>

  <% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td width="100%"><hr size="1"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> </td>
          </tr>
        </table>
<%if(!bolMyHome){%>
		
       	<table width="90%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td width="20%">&nbsp;</td>
            <td width="80%">&nbsp; </td>
          </tr>
          <tr> 
            <td>Purpose </td>
            <td>
<%if (vEditInfo != null)  
	strTemp =  WI.getStrValue((String)vEditInfo.elementAt(1));
else 
	strTemp = WI.fillTextValue("purpose"); 
%> 
			<textarea name="purpose" cols="48" rows="3" class="textbox" 
	  onfocus="CharTicker('form_','256','purpose','count_');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','256','purpose','count_');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','256','purpose','count_');"><%=strTemp%></textarea>
              <br>
              <font size="1">Available Characters</font> 
              <input name="count_" type="text" class="textbox_noborder" size="5" maxlength="5" readonly="yes" tabindex="-1"></td>
          </tr>
          <tr> 
            <td>Destination</td>
            <td> 
<%
if (vEditInfo != null)  
	strTemp =  WI.getStrValue((String)vEditInfo.elementAt(2));
else 
	strTemp = WI.fillTextValue("destination");		
%> 
		<input name="destination" type="text" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
			value="<%=strTemp%>" size="48" maxlength="64"> </td>
          </tr>
          <tr>
            <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("less_oneday");
if(vEditInfo != null && vEditInfo.elementAt(4) == null && request.getParameter("reload_page") == null)
	strTemp = "1";
	
boolean bolIsOBLessOneDay = strTemp.equals("1");
if(bolIsOBLessOneDay) 
	strTemp = " checked";
else	
	strTemp = "";
%>
			<input type="checkbox" name="less_oneday" value="1" <%=strTemp%> onClick="document.form_.submit();"> OB is less than one day (must enter time of departure and Arrival) </td>
          </tr>
          <tr> 
            <td>Date Range </td>
            <td> 
<%
if (vEditInfo != null)  
	strTemp =  WI.getStrValue((String)vEditInfo.elementAt(3));
else 
	strTemp = WI.fillTextValue("date_logout");		

	if (strTemp == null || strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%> 
		<input name="date_logout" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyUp="AllowOnlyIntegerExtn('form_','date_logout','/')" value="<%=strTemp%>" size="15">
        <a href="javascript:show_calendar('form_.date_logout');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a> &nbsp; 
<%if(!bolIsOBLessOneDay){%>        
		<font size="1">to </font>
<%
if (vEditInfo != null)  
	strTemp =  WI.getStrValue((String)vEditInfo.elementAt(4));
else 
	strTemp = WI.fillTextValue("date_logout_to");		
%> 
		<input name="date_logout_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyUp="AllowOnlyIntegerExtn('form_','date_logout_to','/')" value="<%=strTemp%>" size="15">
        <a href="javascript:show_calendar('form_.date_logout_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>
			</td>
          </tr>
<%if(bolIsOBLessOneDay){%>
          <tr> 
            <td>Time of Departure</td>
            <td> 
<%
strTemp = "";
int[] iTimeConverted = {0,0,0};
if (vEditInfo != null) { 
	if(vEditInfo.elementAt(7) != null) {
		iTimeConverted = CommonUtil.convert24HRTo12Hr(((Double)vEditInfo.elementAt(7)).doubleValue(),false);
		strTemp = Integer.toString(iTimeConverted[0]);
	}
}
else
	strTemp = WI.fillTextValue("hr_dep");
%> 
		<input name="hr_dep" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';" 
	  onKeyUp="AllowOnlyInteger('form_','hr_dep')" value="<%=strTemp%>" size="2" maxlength="2" >
              : 
<%
if (vEditInfo != null) { 
	if(vEditInfo.elementAt(7) != null)
		strTemp = Integer.toString(iTimeConverted[1]);
}
else
	strTemp = WI.fillTextValue("min_dep");
%> 
		<input name="min_dep" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','min_dep')" 
			  value="<%=strTemp%>" size="2" maxlength="2"> <select name="ampm_dep">
                <option value="0" >AM</option>
<% 
if (vEditInfo != null) { 
	if(vEditInfo.elementAt(7) != null)
		strTemp = Integer.toString(iTimeConverted[2]);
}
else 
	strTemp = WI.fillTextValue("ampm_dep");		

if (strTemp.equals("1"))
	strTemp = "selected";
else	
	strTemp = "";
%>
                <option value="1" <%=strTemp%>>PM</option>
              </select> </td>
          </tr>
          <tr> 
            <td height="15">Time of Arrival</td>
            <td height="15"> 
<%
if (vEditInfo != null) { 
	if(vEditInfo.elementAt(8) != null) {
		iTimeConverted = CommonUtil.convert24HRTo12Hr(((Double)vEditInfo.elementAt(8)).doubleValue(),false);
		strTemp = Integer.toString(iTimeConverted[0]);
	}
}
else
	strTemp = WI.fillTextValue("hr_arr");
%> 
		 <input name="hr_arr" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUP="AllowOnlyInteger('form_','hr_arrive')" 
	  value="<%=strTemp%>" size="2" maxlength="2" >
              : 
<%
if (vEditInfo != null) { 
	if(vEditInfo.elementAt(8) != null)
		strTemp = Integer.toString(iTimeConverted[1]);
}
else 
	strTemp = WI.fillTextValue("min_arr");		
%> 
              
			  <input name="min_arr" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','min_arr')"
	  onKeyUp="AllowOnlyInteger('form_','min_arr')"
	  value="<%=strTemp%>" size="2" maxlength="2"> 
	  		<select name="ampm_arr" >
                <option value="0" >AM</option>
<% 
if (vEditInfo != null) { 
	if(vEditInfo.elementAt(8) != null)
		strTemp = Integer.toString(iTimeConverted[2]);
}
else 
	strTemp = WI.fillTextValue("ampm_arr");		

if (strTemp.equals("1"))
	strTemp = "selected";
else	
	strTemp = "";
%>
                <option value="1" <%=strTemp%>>PM</option>
              </select> </td>
          </tr>
<%}%>
          <tr>
            <td height="15">Comments</td>
            <td height="15">
<%
if (vEditInfo != null)  
	strTemp =  WI.getStrValue((String)vEditInfo.elementAt(5));
else 
	strTemp = WI.fillTextValue("remarks");		
%> 
				<textarea name="remarks" cols="75" rows="3" class="textbox"><%=strTemp%></textarea>
			</td>
          </tr>
          <tr>
            <td height="15">&nbsp;</td>
            <td height="15">
<% 
if (vEditInfo != null)  
	strTemp =  WI.getStrValue((String)vEditInfo.elementAt(4));	
else 
	strTemp = WI.fillTextValue("is_verified");

if (strTemp.equals("1")) 
	strTemp = "checked";
else 
	strTemp = "";
%>
			<input type="checkbox" name="is_verified" value="1" <%=strTemp%>>
              <font size="1">tick if Logout is verified</font></td>
          </tr>
        </table>
        
		<table width="92%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="15" colspan="2" valign="bottom">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2"><div align="center"> 
                <% if (iAccessLevel > 1){
					if (vEditInfo == null) { %>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{%>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font> 
                <%} // end if else vEditInfo != null%>
                <font size="1">&nbsp;<a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a>click 
                to cancel and clear entries</font> 
                <%} // if iAccessLevel > 1%>
              </div></td>
          </tr>
        </table> 
<%}//do not show the saving if coming from home page..%>
	  </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
    </tr>
  </table>
<% 
if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EDF0FA" style="font-weight:bold;" align="center"> 
      <td  class="thinborder" width="15%" height="25"><font size="1">OB Date </font></td>
      <td width="5%" class="thinborder"><font size="1">OB Duration</font></td>
      <td width="25%" class="thinborder"><font size="1">Purpose</font></td>
      <td width="15%" class="thinborder"><font size="1">Destination</font></td>
      <td width="25%" class="thinborder"><font size="1">Comments</font></td>
      <td width="7%" class="thinborder"><font size="1">EDIT</font></td>
      <td width="8%" class="thinborder"><font size="1">DELETE</font></td>
    </tr>
    <% 
	boolean bolIsEditAllowed = false;
	boolean bolIsDelAllowed  = false;
	boolean bolIsVerified    = false;
	if(!bolMyHome) {
		if(iAccessLevel > 1)
			bolIsEditAllowed = true;
		if(iAccessLevel == 2) 
			bolIsDelAllowed = true;
	}

	
	String strBGColor = "";
	for (int i = 0; i < vRetResult.size();i+=10){
		if(vRetResult.elementAt(i + 6).equals("1")) {
			strBGColor = " bgcolor='#dddddd'";
			bolIsVerified = true;
		}
		else {
			strBGColor = "";
			bolIsVerified = false;
		}
		strTemp = (String)vRetResult.elementAt(i + 3);
		if(vRetResult.elementAt(i + 4) != null)
			strTemp = strTemp + " to " +(String)vRetResult.elementAt(i + 4);
		else if(vRetResult.elementAt(i + 7) != null && vRetResult.elementAt(i + 8) != null) {
			strTemp = strTemp + "<br>"+CommonUtil.convert24HRTo12Hr(((Double)vRetResult.elementAt(i + 7)).doubleValue()) + " to " +
						CommonUtil.convert24HRTo12Hr(((Double)vRetResult.elementAt(i + 8)).doubleValue());
		}
		
	
	%>
    <tr <%=strBGColor%>> 
      <td class="thinborder" height="25"><%=strTemp%></td>
     <%
		strTemp = (String)vRetResult.elementAt(i+9);
		if(vRetResult.elementAt(i + 4) == null)
			strTemp = strTemp + " mins";
		else	
			strTemp = strTemp + " days";
	 %>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td class="thinborder"> 
	    <%if(bolIsVerified || !bolIsEditAllowed){%>
		N/A
	  	<%}else{%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a> 
      	<%}%>
	  </td>
      <td class="thinborder"> 
	    <%if(bolIsVerified || !bolIsDelAllowed){%>
		N/A
	  	<%}else{%><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a> 
      	<%}%>
		</td>
    </tr>
    <%} //end for loop%>
  </table>
  <%} // if vRetResult != null
  } // vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
  <%if(vEditInfo != null && vEditInfo.size() > 0) {%>
  	<input type="hidden" name="reload_page">
  <%}%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
