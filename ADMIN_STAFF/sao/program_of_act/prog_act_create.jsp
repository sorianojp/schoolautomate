<%@ page language="java" import="utility.*, java.util.Vector, osaGuidance.ProgramOfActivity"%>
<%
	WebInterface WI = new WebInterface(request);
	
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";
boolean bolIsCIT = strSchoolCode.startsWith("CIT");

String strThemeObj = null;
if(bolIsCIT)
	strThemeObj = "Theme";
else
	strThemeObj = "Objective";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function ShiftView()
{
	location = "./view_poa_list.jsp?sy_from="+document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value;
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function AssignObjectives(strIndex)
{
	var pgLoc = "./prog_act_update.jsp?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&act_index="+strIndex;
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=800,height=600,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateObjective(){
	if(document.form_.sy_from.value.length == 0){
		alert("Please enter sy from/ sy to.");
		return;
	}
	if(document.form_.sy_to.value.length == 0){
		alert("Please enter sy from/ sy to.");
		return;
	}
	var pgLoc = "./prog_obj_update.jsp?sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value;
	var win=window.open(pgLoc,"myfile",'dependent=yes,width=800,height=600,top=0,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}

var objCOA;
var objCOAInput;
function AjaxMapName() {
	var strIDNumber = document.form_.in_charge.value;
	objCOAInput = document.getElementById("coa_info");
	
	eval('objCOA=document.form_.in_charge');
	if(strIDNumber.length < 3) {
		objCOAInput.innerHTML = "";
		return ;
	}
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
	
	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOA.value = strID;
	//objCOAInput.innerHTML = "";	
	this.AjaxMapName();
}

function UpdateName(strFName, strMName, strLName) {
		//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}


</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	strTemp = WI.fillTextValue("page_action");
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-PROGRAM OF ACTIVTIES","prog_act_create.jsp");
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
														"Student Affairs","PROGRAM OF ACTIVTIES",request.getRemoteAddr(),
														"prog_act_create.jsp");
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

Vector vActivities = null;
Vector vEditInfo = null;

ProgramOfActivity POA = new ProgramOfActivity();

if(strTemp.length() > 0) {
		if(POA.operateOnActivity(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = POA.getErrMsg();
     
	}
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = POA.operateOnActivity(dbOP, request, 3);
	
	if(vEditInfo == null && strErrMsg == null ) 
		strErrMsg = POA.getErrMsg();
}

//collect information for view.
if(WI.fillTextValue("sy_from").length() > 0) 
	vActivities = POA.operateOnActivity(dbOP, request,4);
%>
<body bgcolor="#D2AE72">
<form action="./prog_act_create.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          PROGRAM OF ACTIVITIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="14%" >School year</td>
      <td width="31%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        -
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
      </td>
      <td width="52%">
	  <a href="javascript:ReloadPage();"><img src="../../../images/refresh.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <a href="javascript:ShiftView();"><img src="../../../images/view.gif" border="0"></a>
	  <font size="1">Click to show ordered list of activities</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%if (WI.fillTextValue("sy_from").length()>0 && WI.fillTextValue("sy_to").length()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<!--
<tr>
      <td height="24" width="5%">&nbsp;</td>
      <td width="19%" height="0">Date (Month, Year)</td>
      <td height="24" colspan="2">
      <%if (vEditInfo!=null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(1);
      else
		strTemp = WI.fillTextValue("month");%>
      <select name="month">
          <option value="0">January</option>
          <%if(strTemp.compareTo("1") == 0){%>
          <option value="1" selected>February</option>
          <%}else{%>
          <option value="1">February</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>March</option>
          <%}else{%>
          <option value="2">March</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="3" selected>April</option>
          <%}else{%>
          <option value="3">April</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="4" selected>May</option>
          <%}else{%>
          <option value="4">May</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="5" selected>June</option>
          <%}else{%>
          <option value="5">June</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="6" selected>July</option>
          <%}else{%>
          <option value="6">July</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="7" selected>August</option>
          <%}else{%>
          <option value="7">August</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="8" selected>September</option>
          <%}else{%>
          <option value="8">September</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="9" selected>October</option>
          <%}else{%>
          <option value="9">October</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="10" selected>November</option>
          <%}else{%>
          <option value="10">November</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="11" selected>December</option>
          <%}else{%>
          <option value="11">December</option>
          <%}%>
        </select> 
        <%if (vEditInfo!=null && vEditInfo.size()>0)
		        strTemp = (String)vEditInfo.elementAt(2);
        	else
        		strTemp = WI.fillTextValue("year");%>
      <input name="year" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"></td>
    </tr>
    -->
    <tr>
      <td height="24" width="3%">&nbsp;</td>
      <td width="14%" height="24">Date Range</td>
      <td width="55%" height="24">
	  <% if(vEditInfo !=null && vEditInfo.size()>0)
	  		strTemp = (String) vEditInfo.elementAt(1);
		else 
		   strTemp = WI.fillTextValue("date_range_from");%>
      <input name="date_range_from" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"  
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
        <a href="javascript:show_calendar('form_.date_range_from');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a> 
		To:&nbsp;
		<% if(vEditInfo!=null && vEditInfo.size()>0)
				strTemp = (String) vEditInfo.elementAt(2);
		   else
		   		strTemp = WI.fillTextValue("date_range_to");
		  
		%>
		<input name="date_range_to" type="text" value="<%=strTemp%>" size="10" readonly="true" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('form_.date_range_to');" title="Click to select date"
		onMouseOver="window.status='Select date'; return true;" onMouseOut="window.status='';return true;">
		<img src="../../../images/calendar_new.gif" border="0"></a>	  </td>
      <td width="28%" rowspan="2">
	  <a href="javascript:UpdateObjective();"><img src="../../../images/update.gif" border="0" ></a>
	  <font size="1">click to create <%=strThemeObj.toLowerCase()%>s</font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Activities</td>
      <td height="24"> 
      <%if (vEditInfo!=null && vEditInfo.size()>0)
      		strTemp = (String)vEditInfo.elementAt(3);
      	else
	      	strTemp = WI.fillTextValue("activities");%>
      <input name="activities" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="55"></td>
      </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Target Population</td>
      <td height="24" colspan="2"> 
      <%if (vEditInfo!= null && vEditInfo.size()>0) 
			strTemp = (String)vEditInfo.elementAt(4);
		else
			strTemp = WI.fillTextValue("target_population");%>
      <input name="target_population" type="text" size="4" maxlength="4"
	  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','target_population')"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>In-charge(ID)</td>
      <td colspan="2">
      <%
      	if (vEditInfo!=null && vEditInfo.size()>0)
      	strTemp = (String)vEditInfo.elementAt(5);
      	else
      	strTemp = WI.fillTextValue("in_charge");
      %>
      <input name="in_charge" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="16"  onKeyUp="AjaxMapName();"> <label id="coa_info" style="width:300px; position:absolute"></label></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Time frame</td>
      <td height="24" colspan="2">
      <%
      	if(vEditInfo != null && vEditInfo.size()>0)
	      	strTemp = (String)vEditInfo.elementAt(6);
      	else
    	  	strTemp = WI.fillTextValue("time_frame");
      %>
      <input name="time_frame" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="55"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Venue</td>
      <td height="24" colspan="2">
      <%
      	if (vEditInfo != null && vEditInfo.size()>0)
      		strTemp = (String)vEditInfo.elementAt(7);
   		else
      		strTemp = WI.fillTextValue("venue");%>
      <input name="venue" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	value="<%=strTemp%>" size="55"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" valign="top">&nbsp;</td>
      <td height="23" colspan="2">&nbsp;</td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="19%" height="25"><div align="center"></div></td>
      <td width="76%" height="25"><font size="1">
	  <%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to cancel 
        <%}%></font></td>
    </tr>
  </table>
<%}

if(vActivities != null && vActivities.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>PROGRAM
      OF ACTIVITIES LIST FOR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></font></div></td>
    </tr>
    <tr>
      <td width="14%" height="27" class="thinborder" ><div align="center"><font size="1"><strong>DATE RANGE</strong></font></div></td>
      <td width="23%" height="27" class="thinborder"><div align="center"><font size="1"><strong>ACTIVITY</strong></font></div></td>
      <td width="12%" height="27" class="thinborder"><div align="center"><font size="1"><strong>TARGET
      POPULATION </strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>IN-CHARGE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>TIME FRAME</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>VENUE</strong></font></div></td>
      <td width="5%" height="27" class="thinborder"><div align="center"><font size="1">&nbsp;</font></div></td>
      <td width="8%" height="27" class="thinborder"><div align="center"><font size="1">&nbsp;</font></div></td>
	  <td width="6%" height="27" class="thinborder"><div align="center"><font size="1">&nbsp;</font></div></td>
    </tr>
<%for(int i = 0 ; i < vActivities.size() ; i +=8){
     String[] astrMonthList = {"January","February","March","April","May","June","July","August",
	"September","October","November","December"};%>
    <tr>
      <!--
	  <td height="25" class="thinborder">
	  <%//=astrMonthList[Integer.parseInt((String)vActivities.elementAt(i + 1))]%>,
	  <%//=(String)vActivities.elementAt(i + 2)%></td>
	  -->
      <td height="25" class="thinborder">
	  <%=(String)vActivities.elementAt(i + 1)%> 
	  <%=WI.getStrValue((String)vActivities.elementAt(i + 2),"- ","","")%></td>
      <td class="thinborder"><%=(String)vActivities.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vActivities.elementAt(i + 4)%></td>
      <td class="thinborder"><%=(String)vActivities.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vActivities.elementAt(i + 6)%></td>
      <td class="thinborder"><%=(String)vActivities.elementAt(i + 7)%></td>
      <td class="thinborder"><a href='javascript:PrepareToEdit("<%=(String)vActivities.elementAt(i)%>");'>
	  <img src="../../../images/edit.gif" border="0"></a></td>
      <td class="thinborder"><a href='javascript:PageAction(0, "<%=(String)vActivities.elementAt(i)%>");'>
	  <img src="../../../images/delete.gif" border="0"></a></td>
	  <td class="thinborder"><a href='javascript:AssignObjectives("<%=(String)vActivities.elementAt(i)%>");'>
	  <img src="../../../images/update.gif" border="0"></a></td>
    </tr>
<%}//end of vActivities loop%>
  </table>
<%}//if vActivities is not null.%>
   <!--<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="95%" align="left"></td>
    </tr>
  </table>-->

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action">
   	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>