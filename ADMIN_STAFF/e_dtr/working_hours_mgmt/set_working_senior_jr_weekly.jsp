<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function ChangeWorkingHrType(isRegularHr)
{
	if(isRegularHr ==1)
	{
		document.dtr_op.regular_wh.checked = true;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value=1;
	}
	else if  (isRegularHr==0)
	{
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = true;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value = 2;
		
	}else if (isRegularHr==2){
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = true;
		document.dtr_op.is_nonDTR.checked = false;
		document.dtr_op.iStatus.value = 3;
	}else if (isRegularHr == 3){
		document.dtr_op.regular_wh.checked = false;
		document.dtr_op.specify_wh.checked = false;
		document.dtr_op.is_flex.checked = false;
		document.dtr_op.is_nonDTR.checked = true;
		document.dtr_op.iStatus.value = 4;
	}
	this.SubmitOnce('dtr_op');
}

function ViewRecord(){
	document.dtr_op.page_action.value=1;
}

function AddRecord(){
	document.dtr_op.page_action.value=2;
}
function DeleteRecord(index){
	document.dtr_op.page_action.value =3;
	document.dtr_op.info_index.value = index;
}
function PrepareToEdit(index){
	document.dtr_op.page_action.value = 4;
	document.dtr_op.prepareToEdit.value = 1;
}
function EditRecord(index){
	document.dtr_op.page_action.value = 5;
}
function CancelEdit()
{
	location = "./set_dtr_regular_wh.jsp";
}
function DeleteNonEDTR(strEmpIndex) {
	document.dtr_op.non_EDTR.value = strEmpIndex;
	document.dtr_op.info_index.value = "";
	document.dtr_op.page_action.value = "";
	document.dtr_op.prepareToEdit.value = "";
	
	this.SubmitOnce('dtr_op');
}

function viewHistory() {
	var pgLoc = "./set_working_history.jsp?emp_id=" + escape(document.dtr_op.emp_id.value);
	var win=window.open(pgLoc,"view_history",'dependent=yes,width=600,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
-->
</script>
<body bgcolor="#D2AE72" onLoad="document.dtr_op.emp_id.focus();">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strPrepareToEdit = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-WORKING HOURS MGMT","set_working.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(), 
														"set_working.jsp");	
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
	WorkingHour whPersonal = new WorkingHour();
	Vector vRetResult = null;
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};	
	String[] astrConverAMPM = {"AM","PM"};
	
	if(WI.fillTextValue("page_action").equals("1")){
		vRetResult = whPersonal.operateOnEmployeeWH(dbOP, request,1);
		strErrMsg = whPersonal.getErrMsg();
	}else if(WI.fillTextValue("page_action").compareTo("2")==0){
		vRetResult = whPersonal.operateOnEmployeeWH(dbOP, request,2);
		strErrMsg = whPersonal.getErrMsg();
		if (strErrMsg == null)  
			strErrMsg = "Working Hour added successfully." ;
	}else if(WI.fillTextValue("page_action").compareTo("3")==0){
		vRetResult = whPersonal.operateOnEmployeeWH(dbOP,request,3);
		strErrMsg = whPersonal.getErrMsg();
		if (strErrMsg == null)  strErrMsg = "Working Hour deleted successfully ." ;
	}
	if(WI.fillTextValue("non_EDTR").length() > 0) {
		if(whPersonal.removeNonEDTRWH(dbOP, WI.fillTextValue("non_EDTR"), 
				(String)request.getSession(false).getAttribute("login_log_index")))
			strErrMsg = "Woring hour information removed successfully.";
		else	
			whPersonal.getErrMsg();
	}

	
%>	
<form action="./set_working.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          WORKING HOURS MGMT - SET WORKING HOURS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25"><strong><font size=2>&nbsp;<%=WI.getStrValue(strErrMsg)%>&nbsp;</font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td width="2%" height="30" valign="top">&nbsp;</td>
      <td width="14%" height="30">Employee ID </td>
      <td width="23%" height="30"><input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="13%"><input type="image"  src="../../../images/form_proceed.gif" name="proceed" onClick="ViewRecord()" ></td>
      <td width="43%" valign="top"><label id="coa_info"></label></td>
    </tr>
  </table>
<% 

if ((WI.fillTextValue("emp_id").length() !=0)){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vRetResult = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vRetResult !=null){
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Employee Name</font></td>
      <td height="15"><font size="1">Employee Status</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = WI.formatName((String)vRetResult.elementAt(1), (String)vRetResult.elementAt(2),
									(String)vRetResult.elementAt(3),1); %>
      <td colspan="2" valign="top"><font size="1"><strong><%=strTemp%></strong></font></td>
      <td valign="top"><font size="1"><strong><%=WI.getStrValue((String)vRetResult.elementAt(16))%></strong></font></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td height="15" colspan="2"><font size="1">Position</font></td>
      <td height="15"><font size="1">College/Office</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <% strTemp = (String)vRetResult.elementAt(15);%>
      <td colspan="2" valign="top"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
      <%
				if((String)vRetResult.elementAt(13) == null)
				strTemp = WI.getStrValue((String)vRetResult.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue((String)vRetResult.elementAt(13));
				if((String)vRetResult.elementAt(14) != null)
					strTemp += "/" + WI.getStrValue((String)vRetResult.elementAt(14));
			}
%>
      <td valign="top"><font size="1"><strong><%=WI.getStrValue(strTemp)%></strong></font></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <%if(WI.fillTextValue("regular_wh").compareTo("1") ==0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <%}if ((iAccessLevel > 1) && ((WI.fillTextValue("is_flex").equals("1"))    || 
        (WI.fillTextValue("regular_wh").equals("1")) ||
		(WI.fillTextValue("specify_wh").equals("1")) ||
		(WI.fillTextValue("is_nonDTR").equals("1")))){%>	
    <tr> 
      <td>&nbsp;</td>
      <td height=30>Effective Date From: </td>
      <td height=30><input name="date_from" type="text" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" 
	   onBlur="style.backgroundColor='white'; AllowOnlyIntegerExtn('dtr_op','date_from','/');"
	   onKeyUp= "AllowOnlyIntegerExtn('dtr_op','date_from','/')"
	    value="<%=WI.fillTextValue("date_from")%>" size="10" maxlength="10">
      <a href="javascript:show_calendar('dtr_op.date_from');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td height=30>Effective Date To: 
        <input name="date_to" type="text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','date_to','/');"
		onKeyUP= "AllowOnlyIntegerExtn('dtr_op','date_to','/')"
		value="<%=WI.fillTextValue("date_to")%>" size="10" maxlength="10"> <a href="javascript:show_calendar('dtr_op.date_to');"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        <font size="1">(leave empty if still applicable)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height=10>&nbsp;</td>
      <td height=10>&nbsp;</td>
      <td height=10>&nbsp;</td>
    </tr>
		
    <tr> 
      <td height="10" colspan="4"><div align="center">
          <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
          <font size="1">click to save changes </font> &nbsp; </div></td>
    </tr>
<%}%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr bgcolor="#B9B292"> 
      <td height="25" bgcolor="#B9B292" colspan="9"><div align="center">LIST OF 
          EXISTING WORKING HOURS FOR ID : <%=WI.fillTextValue("emp_id")%> </div></td>
    </tr>
    <tr> 
      <td height="25" colspan="9">
	  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
<% vRetResult = whPersonal.getEmployeeWorkingHours(dbOP,request);
if (vRetResult == null) {  %>
          <tr> 
            <td height="25" colspan=4 align="center" class="thinborder">&nbsp;</td>
          </tr>
<% } // end if ( vRetResult == null)
    else{ // else if (vRetResult == null)%>
          <tr> 
            <td width="20%" class="thinborder"><strong>EFFECTIVE DATES</strong> </td>
            <td width="16%" height="25" class="thinborder"><div align="center"><strong>WEEK DAY</strong></div></td>
            <td width="46%" class="thinborder"><div align="center"><strong>TIME / HOURS</strong></div></td>
            <td width="18%" class="thinborder"><div align="center"><strong> DELETE</strong></div></td>
          </tr>
<% if(vRetResult.size() == 2 && 
		((String)vRetResult.elementAt(0)).compareTo("-1") == 0){
		  vRetResult.removeElementAt(0);//do not enter in next loop. %>
<% } else {//end if (vRetResult.size() == 2 && ((String)vRetResult.elementAt(0)).compareTo("-1") == 0)
		  for (int i = 0; i < vRetResult.size(); i+=35){%>
    <%}else { // else  %>
          <% }else{ 
		strTemp = (String)vRetResult.elementAt(i+1);
		
		if (strTemp == null)
			strTemp = "N/A Weekday";
		else
			strTemp = astrConvertWeekDay[Integer.parseInt(strTemp)];

		strTemp2 = (String)vRetResult.elementAt(i+2) +  ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+3)) +
				" " +(String)vRetResult.elementAt(i+4) + " - " + (String)vRetResult.elementAt(i+5) +  ":"  + 
				CommonUtil.formatMinute((String)vRetResult.elementAt(i+6)) + " " + (String)vRetResult.elementAt(i+7);
	
		if ((String)vRetResult.elementAt(i+8) !=null){
		strTemp2 += " / " + (String)vRetResult.elementAt(i+8) + ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+9)) +
				 " " + (String)vRetResult.elementAt(i+10) + " - " + (String)vRetResult.elementAt(i+11) + 
				 ":"  + CommonUtil.formatMinute((String)vRetResult.elementAt(i+12)) +  " " + (String)vRetResult.elementAt(i+13);
				 
		if (((String)vRetResult.elementAt(i+32)).compareTo("1") == 0)
			strTemp2 +=" (next day)";
		}
%>
          <tr> 
            <td height="25" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+33),"**") + WI.getStrValue((String)vRetResult.elementAt(i+34)," - ",""," - present")%></td>
            <td height="25" class="thinborder"><%=strTemp%></td>
            <td height="25" class="thinborder"><strong><%=WI.getStrValue(strTemp2,"")%></strong></td>
            <td class="thinborder"> <div align="center"> 
                <%if(iAccessLevel ==2){%>
                <input type="image" src="../../../images/delete.gif" width="55" border="0" 
	    onClick='DeleteRecord("<%=WI.getStrValue((String)vRetResult.elementAt(i+31))%>")'>
                <%} //end if (iAccessLevel == 2) %>
              </div></td>
          </tr>
          <%}// end else
    }
   } // end for loop
  } // end if
 } // else if (vRetResult == null)
} %>
        </table></td>
    </tr>
</table>
<%}%>
<!-- here lies the great mysteries of and future-->
  <table bgcolor="#FFFFFF" width="100%" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25"s>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="">
<input type="hidden" name="prepareToEdit" value="">
<input type="hidden" name="iStatus" value="">

<!-- for non-EDTR set user_index if called for nonEDTR remove info-->
<input type="hidden" name="non_EDTR">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>
