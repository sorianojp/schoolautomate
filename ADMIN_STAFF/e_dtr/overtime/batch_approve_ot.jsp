<%@ page language="java" import="utility.*,java.util.Vector, eDTR.OverTime, eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function PrintPg(){
	document.dtr_op.print_page.value = "1";
	document.dtr_op.submit();
}

function ReloadPage(){
	document.dtr_op.print_page.value = "";
	document.dtr_op.submit();
}

function CancelRecord(){
	document.dtr_op.print_page.value = "";
	location = "./batch_approve_ot.jsp?my_home="+document.dtr_op.my_home.value;
}

function SaveRecord(){
	document.dtr_op.print_page.value = "";
	document.dtr_op.save_record.value = 1;
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.aEmp";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

var ajaxPos = 0;
function AjaxMapName(iPos) {
	ajaxPos = iPos;
	
	var strCompleteName;// = document.dtr_op.requested_by.value;
	var objCOAInput;
	if(iPos == 1) {
		objCOAInput = document.getElementById("coa_info");
		strCompleteName = document.dtr_op.requested_by.value;
	}
	else {	
		objCOAInput = document.getElementById("coa_info2");
		strCompleteName = document.dtr_op.req_for_id.value;
	}
	
	
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
	if(ajaxPos == 1) {
		document.dtr_op.requested_by.value = strID;
		document.getElementById("coa_info").innerHTML = "";
	}else{
		document.dtr_op.req_for_id.value = strID;
		document.getElementById("coa_info2").innerHTML = "";
	}
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}	

function checkAllSave() {
 	var maxDisp = document.dtr_op.max_items.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllSave.checked) {
		for(var i =1; i<= maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}	else {
		for(var i =1; i<= maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
}

function CopyOT(){
	var vItems = document.dtr_op.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.dtr_op.ot_type_index'+i+'.value=document.dtr_op.ot_type_index_1.value');

}

-->
</script>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Validate / Approved Overtime</title>
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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
    }

</style>
</head>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
 if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./batch_approve_ot_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	int i = 3;
	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	boolean bolHasOTBreak = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-Approve Overtime(Batch)","batch_approve_ot.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasOTBreak = (readPropFile.getImageFileExtn("HAS_OT_BREAK","0")).equals("1");
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
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Approve Overtime",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");	
}														
// added for CLDHEI.. 
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome)
		iAccessLevel = 2;
}

if (strTemp == null) 
	strTemp = "";

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
	OverTime OT = new OverTime();
	Vector vRetResult = null;
	ReportEDTR RE = new ReportEDTR(request);
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours","Status", "Last Name(Requested for)"};
	String[] astrSortByVal     = {"head_.lname","request_date","ot_specific_date","no_of_hour","approve_stat", "sub_.lname"};
	String strLabel = null;
	
	String strDateFrom = WI.fillTextValue("DateFrom");
	String strDateTo = WI.fillTextValue("DateTo");
	int iSearchResult = 0;
	String strAMPM = " AM";
	int iHour = 0;
	int iMinute = 0;
	double dTime = 0d;
	
	if (strDateFrom.length() ==0){
		String[] astrCutOffRange = eDTRUtil.getCurrentCutoffDateRange(dbOP,true);
		if (astrCutOffRange!= null && astrCutOffRange[0] != null){
			strDateFrom = astrCutOffRange[0];
			strDateTo = astrCutOffRange[1];
		}
	}

	if (WI.fillTextValue("save_record").equals("1")){
		if(!OT.batchUpdateOvertimeStat(dbOP,request))
			strErrMsg = OT.getErrMsg();
		else
			strErrMsg = "Overtime Request status Updated Successfully";
	} 
 
	vRetResult = RE.searchOvertime(dbOP, true);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
	else
		iSearchResult = RE.getSearchCount();
%>
<form action="./batch_approve_ot.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        VALIDATE/APPROVE OVERTIME BY BATCH ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr >
      <td height="25"><table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
        <tr>
          <td><strong>&nbsp;&nbsp;&nbsp;&nbsp;Date&nbsp;</strong></td>
          <td colspan="3"><strong>&nbsp;From</strong>
            <input name="DateFrom" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
						onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateFrom','/')" 
						value="<%=strDateFrom%>" size="10" maxlength="10">
            <a href="javascript:show_calendar('dtr_op.DateFrom');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
						<img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;<strong>To</strong>
            <input name="DateTo" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
						onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateTo','/')" 
						value="<%=strDateTo%>" size="10" maxlength="10">
            <a href="javascript:show_calendar('dtr_op.DateTo');" title="Click to select date" 
						onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
						<img src="../../../images/calendar_new.gif" border="0"></a></td>
          </tr>
        <% if (!bolMyHome) {%>
        <tr>
          <td width="17%"><strong>&nbsp;Requested By </strong></td>
          <td colspan="2"><select name="emp_id_con">
              <%=RE.constructGenericDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%>
            </select>
              <input name="requested_by" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15"
			  value="<%=WI.fillTextValue("requested_by")%>" onKeyUp="AjaxMapName(1);">
            <label id="coa_info"></label></td>
          <td width="30%">&nbsp;</td>
        </tr>
        <%}%>
        <tr>
          <td width="17%"><strong>&nbsp;Date of Request </strong></td>
          <td width="39%"><input name="date_request" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
				onBlur="style.backgroundColor='white'"
			  value="<%=WI.fillTextValue("date_request")%>" size="10" maxlength="10">
              <a href="javascript:show_calendar('dtr_op.date_request');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> <font size="1">(mm/dd/yyyy)</font></td>
          <td width="14%"><strong>&nbsp;Status</strong></td>
		<%
			strTemp = WI.fillTextValue("status");
			if(bolMyHome)
				strTemp = "2";
		%>
          <td width="30%">
		  <%if(!bolMyHome){%>
			<select name="status" id="status">
              <option value="">ALL</option>
              <% if (strTemp.equals("1")){%>
              <option value="1" selected>APPROVED</option>
              <%}else{%>
              <option value="1">APPROVED</option>
              <%} if (strTemp.equals("0")){%>
              <option value="0" selected>DISAPPROVED</option>
              <%}else{%>
              <option value="0" >DISAPPROVED</option>
              <%} if (strTemp.equals("2")){%>
              <option value="2" selected>PENDING</option>
              <%}else{%>
              <option value="2">PENDING</option>
              <%}%>
          </select>
		  <%}else{%>
		  	<input type="hidden" name="status" value="<%=strTemp%>">PENDING
		  <%}%>		  </td>
        </tr>
        <tr>
          <td><strong>&nbsp;Date of Overtime </strong></td>
          <td><input name="ot_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10" maxlength="10" value="<%=WI.fillTextValue("ot_date")%>">
              <a href="javascript:show_calendar('dtr_op.ot_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> <font size="1">(mm/dd/yyyy)</font></td>
          <td><strong>&nbsp;No. of Hours</strong></td>
          <td><input name="num_hours" type="text" class="textbox"  
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  	onKeyUp="AllowOnlyFloat('dtr_op','num_hours')" size="4" maxlength="4" 
	  	value="<%=WI.fillTextValue("num_hours")%>"></td>
        </tr>
        <tr>
          <td><strong>&nbsp;
                <%if(bolIsSchool){%>
            College
            <%}else{%>
            Division
            <%}%>
          </strong></td>
          <td><select name="c_index">
              <option value="">N/A</option>
              <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";%>
              <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
          </select></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
				<%if(bolHasTeam){%>
        <tr>
          <td><strong>Team</strong></td>
          <td><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
        <%}%>
				<tr>
          <td><strong>Overtime type</strong></td>
					<%
						strTemp = WI.fillTextValue("ot_type_search");
					%>
          <td><select name="ot_type_search">
						<option value="">ALL</option>
            <%=dbOP.loadCombo("ot_type_index","ot_name", " from pr_ot_mgmt " +
		 					 " where is_valid = 1 and is_for_ot = 1 ", strTemp,false)%>
          </select></td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
        </tr>
				<tr>
				  <td><strong>&nbsp;Requested for </strong></td>
				  <td colspan="3"><input name="req_for_id" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15"
			  value="<%=WI.fillTextValue("req_for_id")%>" onKeyUp="AjaxMapName(2);">
			  <label id="coa_info2" style="position:absolute; width:400px;"></label>			  </td>
				  </tr>				
      </table></td>
    </tr>
    <tr >
      <td height="25"><table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
		<%
			strTemp= WI.fillTextValue("show_all");
			if(strTemp.length() > 0)	
				strTemp = "checked";
			else
				strTemp = "";
		%>
    <td height="26" colspan="4" bgcolor="#FFFFFF"><input type="checkbox" name="show_all" value="1" <%=strTemp%>> View All</td>
  </tr>
  <tr>
    <td  width="10%" bgcolor="#FFFFFF"><strong>Sort By </strong></td>
    <td width="28%" bgcolor="#FFFFFF"><select name="sort_by1">
      <option value="" selected>N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
					if(WI.fillTextValue("sort_by1").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="28%" bgcolor="#FFFFFF"><select name="sort_by2">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
				if(WI.fillTextValue("sort_by2").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
    <td width="34%" bgcolor="#FFFFFF"><select name="sort_by3">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <% if(WI.fillTextValue("sort_by3").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td>
  </tr>
  <tr>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
    <td bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>
       </td>
    </tr>
    <tr > 
      <td height="25"><input name="image" type="image" onClick="ReloadPage()" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
  </table>
<% 
	if (vRetResult != null && vRetResult.size()>3) { %>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="right">Number of Employees / rows Per 
        Page : 
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font> 
		</td>
  </tr>
  <tr>
    <td align="right"> <%
		if(WI.fillTextValue("show_all").length() == 0){
		int iPageCount = iSearchResult/RE.defSearchSize;
		if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> Jump To page:
        <select name="jumpto" onChange="ReloadPage();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select>
      <%}
			}%></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
      <tr>
        <td width="18%" align="center" class="thinborder"><strong><font size="1">Requested 
          by </font></strong></td>
        <td width="18%" align="center" class="thinborder"><font size="1"><strong>Requested 
          For</strong></font></td>
        <td width="20%" align="center" class="thinborder"><font size="1"><strong>OT 
          Date/Time</strong></font></td>
        <%if(bolHasOTBreak){%>
				<td width="18%" align="center" class="thinborder"><font size="1"><strong>Break</strong></font></td>
				<%}%>
        <td width="7%" align="center" class="thinborder"><font size="1"><strong>No. 
        of Hours</strong></font></td>
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>Reason</strong></font></td>
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
 				<td width="10%" align="center" class="thinborder"><font size="1"><strong>OT Code<br>
 				<a href="javascript:CopyOT();">Copy</a></strong></font></td>
 			  <% if (iAccessLevel == 2) {%> 
        <td width="3%" align="center" class="thinborder"><font size="1">
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
        </font></td>
        <%}%> 
      </tr>
      <tr>
        <%
			int iCtr = 1;
			//for (i=0 ; i < vRetResult.size(); i+=45, iCtr++){ 
			for (i=0 ; i < vRetResult.size(); i+=45, iCtr++){ 
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
								(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
		 	strTemp = (String)vRetResult.elementAt(i);
			strTemp = WI.getStrValue(strTemp);
		 %>
		 		<input type="hidden" name="weekday_<%=iCtr%>" value="<%=vRetResult.elementAt(i+6)%>">
		 		<input type="hidden" name="hr_from_<%=iCtr%>" value="<%=vRetResult.elementAt(i+30)%>">
				<input type="hidden" name="hr_to_<%=iCtr%>" value="<%=vRetResult.elementAt(i+31)%>">				
				<input type="hidden" name="u_index_<%=iCtr%>" value="<%=vRetResult.elementAt(i+27)%>">
				<input type="hidden" name="ot_date_<%=iCtr%>" value="<%=vRetResult.elementAt(i+4)%>">
				<input type="hidden" name="emp_id_<%=iCtr%>" value="<%=vRetResult.elementAt(i+1)%>">
         <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2, "", "(" + strTemp + ")","")%>
          <input type="hidden" name="ot_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i+14)%>"></td>
        <% if (strTemp.equals((String)vRetResult.elementAt(i+1)))
						strTemp = "&nbsp;";
					else{
						strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
											(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
						strTemp += "(" + (String)vRetResult.elementAt(i+1) + ")";
					}
				%>
        <td class="thinborder">&nbsp;<%=strTemp%></td>
        <% 
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td class="thinborder"><%=strTemp%><br>
          <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - 
          <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
					<%if(bolHasOTBreak){%>
					<%
					strTemp = (String)vRetResult.elementAt(i+33);
					strTemp2 = (String)vRetResult.elementAt(i+34);
					if(strTemp != null && strTemp2 != null){
						dTime = Double.parseDouble(strTemp);
						if(dTime >= 12){
							strAMPM = " PM";
							if(dTime > 12)
								dTime = dTime - 12;
						}else{
							strAMPM = " AM";
						}
						
						iHour = (int)dTime;
						dTime = (dTime - iHour) * 60 + .02;
						iMinute = (int)dTime;
						if(iHour == 0)
							iHour = 12;
						
						strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
						
						dTime = Double.parseDouble(strTemp2);
						if(dTime >= 12){
							strAMPM = " PM";
							if(dTime > 12)
								dTime = dTime - 12;
						} else {
							strAMPM = " AM";
						}
						
						iHour = (int)dTime;
						dTime = ((dTime - iHour) * 60) + .02;
						iMinute = (int)dTime;
						if(iHour == 0)
							iHour = 12;
						
						strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
						
						strTemp += " - <br>" + strTemp2;
					} 
					%>									         
				<td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
				<%}%>
        <td class="thinborder">
					<input type="text" name="no_of_hours_<%=iCtr%>" class="textbox" maxlength="4" size="4"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					 value="<%=(String)vRetResult.elementAt(i+3)%>"
					 style="text-align:right"></td>
				<%
					strTemp = (String)vRetResult.elementAt(i+29);
					strTemp = WI.getStrValue(strTemp,"&nbsp;");
				%>
        <td class="thinborder"><%=strTemp%></td>
        <%
				strLabel = (String)vRetResult.elementAt(i+13);
				if(strLabel.equals("1")){ 
					strLabel = "<strong><font color='#0000FF'> APPROVED </font></strong>";
				}else if (strLabel.equals("0")){
					strLabel = "<strong><font color='#FF0000'> DISAPPROVED </font></strong>";
				}else
					strLabel = "<strong> PENDING </strong>";
			%>
        <td class="thinborder"><font size="1"><%=strLabel%></font></td>
 				<td class="thinborder">
				<% if (strLabel.indexOf("PENDING") != -1) {%>
				<select name="ot_type_index_<%=iCtr%>" style="font-size:10px">
          <option value=""></option>
          <%=dbOP.loadComboLoop("ot_type_index","code", " from pr_ot_mgmt " +
		 					 " where is_valid = 1 and is_for_ot = 1 ", ((Long)vRetResult.elementAt(i+25)).toString())%>
        </select>
				<%}else{%>
						<%=WI.getStrValue((String)vRetResult.elementAt(i+32))%>
				<%}%>				</td>
 			  <% if (iAccessLevel == 2) {%> 		
        <td align="center" class="thinborder">
				<% if (strLabel.indexOf("PENDING") != -1) {%>
				<input type="checkbox" value="1" name="save_<%=iCtr%>">
				<%}else{%>		
				<input type="hidden" name="save_<%=iCtr%>">
				<%}%>				</td>
      <%}%> 
      </tr>
      <%}%>
 		<input type="hidden" name="max_items" value="<%=iCtr-1%>"> 
  </table>		
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
<!-- disable print 
    <tr > 
      <td height="25" align="center">
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a></td>
    </tr>	
-->
  </table>
  <table width="100%" border="0" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
		 <tr> 
			<td width="427%" colspan="4"><table width="100%" height="53" border="0" cellpadding="5" cellspacing="0">
					<tr> 
						<td width="19%" align="right">Remarks :</td>
						<%
							strTemp = WI.fillTextValue("ot_stat_reason");
						%>									
						<td colspan="3">
					<input name="ot_stat_reason" type="text" size="64" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=strTemp%>"></td>
					</tr>
					
					<tr>
					  <td align="right">Overtime type </td>
						<%
							strTemp = WI.fillTextValue("ot_type_index");
						%>
					  <td><select name="ot_type_index">
              <!--
					<option value="">Select overtime type</option>
					-->
              <option value="">Retain OT Type in request</option>
              <%=dbOP.loadCombo("ot_type_index","ot_name", " from pr_ot_mgmt " +
					 " where is_valid = 1 and is_for_ot = 1 ", strTemp,false)%>
            </select></td>
				    <td colspan="2"><font size="1">Override overtime type of requests</font></td>
			    </tr>
					<tr> 
						<td align="right">Approved by : </td>
						<td colspan="3">
					<%  strTemp = WI.fillTextValue("aEmp");
					if(strTemp.length() == 0)
						strTemp = (String)request.getSession(false).getAttribute("userId");%> 
			<input name="aEmp" type="text" class="textbox" value="<%=strTemp%>"  
		<% if(WI.fillTextValue("my_home").equals("1")) {%> readonly  <%}%> 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	
		<% if(!WI.fillTextValue("my_home").equals("1")) {%>
			<a href="javascript:OpenSearch();">Search</a>
		<%}%>				 </td>
					</tr>
					<tr> 
						<td align="right">Date of Approval : </td>
						<%
							strTemp = WI.fillTextValue("DateApproval");
							if(strTemp.length() == 0)	
								strTemp = WI.getTodaysDate(1);
						%>
						<td width="25%">				   
						<input name="DateApproval" type="text"  class="textbox" id="DateApproval" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="12" maxlength="12" readonly="true" 
							value="<%=strTemp%>">
							<a href="javascript:show_calendar('dtr_op.DateApproval');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;                  </td>
						<td width="7%">Status</td>
						<%
							strTemp = WI.fillTextValue("status");
						%>
						<td width="49%">
						<select name="status_">
							<option value="2">Pending</option>
							<%if (strTemp.equals("1")){%>
							<option value="1" selected>Approved</option>
							<%}else{ %>
							<option value="1" >Approved</option>
							<%}if (strTemp.equals("0")){%>
							<option value="0" selected>Disapproved</option>
							<%}else{ %>
							<option value="0" >Disapproved</option>
							<%}%>
						</select>						</td>
					</tr>
					<tr>
					  <td align="right">&nbsp;</td>
						<%
							strTemp = WI.fillTextValue("ignore_wh");
							if(strTemp.length() > 0)
								strTemp = "checked";
							else
								strTemp = "";
						%>
					  <td colspan="3"><input type="checkbox" value="1" name="ignore_wh" <%=strTemp%>> 
					  Ignore working hour checking(<font size="1">allow OT even if it falls on a regular working hour</font>)</td>
				  </tr>
				</table></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				 <%if(iAccessLevel > 1){%>
				<input name="image2" type="image" onClick="SaveRecord();" src="../../../images/save.gif" width="48" height="28">
				<font size="1">click to save changes</font>
				<%}%>
			</td>
		</tr>
	</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

  <input type="hidden" name="print_page">  
	<input type="hidden" name="save_record">  
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
	<input type="hidden" name="from_batch" value="1">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>