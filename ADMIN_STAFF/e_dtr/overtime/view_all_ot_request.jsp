<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil" %>
<%
WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(7);
boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
if(bolMyHome)
	strColorScheme = CommonUtil.getColorScheme(9);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>View OverTime Requests</title>
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
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
.style1 {
font-size: 10px
}
TD.thinborder{
	font-size:10px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function DeleteRequest(strIndex){
		var iCtr = document.dtr_op.max_entries.value;
		var bol1Selected  = false;
		
		for (var i = 0; i < iCtr ; i++){
			if(eval("document.dtr_op.checkbox"+i+".checked")){
				bol1Selected = true;
				break;
			}
		}
		
		if (!bol1Selected){
			alert ("Select at least 1 entry to be deleted");
			return;	
		}

		var varConfirm = confirm(" Confirm Delete Selected Records?");
		if (!varConfirm){
			return;
		}
		
		document.dtr_op.delete_records.value="1";
		document.dtr_op.del_.src ="../../../images/blank.gif";
		document.dtr_op.submit();
		
	}

	function ViewRecords(){
		document.dtr_op.print_page.value = "";
		document.dtr_op.viewAll.value=1;
		document.dtr_op.delete_records.value = "0";		
	}
	function goToNextSearchPage()
	{
		document.dtr_op.viewAll.value=1;
		document.dtr_op.delete_records.value = "0";
		document.dtr_op.submit();
	}
	function ViewDetails(index){
	
	var loadPg = "./validate_approve_ot.jsp?info_index="+index+"&iAction=3&my_home="+
		document.dtr_op.my_home.value;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=447,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();	
	
	}
	function printpage(){
		document.dtr_op.print_page.value = "1";
		document.dtr_op.delete_records.value = "0";		
		document.dtr_op.submit();
	}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.req_for_id.value;
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
	document.dtr_op.req_for_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}	
	
///ajax here to load dept..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.dtr_op.c_index[document.dtr_op.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ //System.out.println("hellow1");%>
	<jsp:forward page="./view_all_ot_request_print.jsp" />
<%}

	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	boolean bolHasInternal = false;
	int i = 0;	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-View/Edit Overtime","view_all_ot_request.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolHasInternal = (readPropFile.getImageFileExtn("HAS_INTERNAL","0")).equals("1");
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
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT",
											request.getRemoteAddr(),null);	
if(iAccessLevel == 0){
 iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT-View/Edit Overtime",
											request.getRemoteAddr(),null);	
}
if(iAccessLevel == 0){
 iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),null);	
}
 if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS - Restricted",request.getRemoteAddr(),
														null);
 }

if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours",
															"Status", "Last Name(Requested for)","Department",strTemp};

String[] astrSortByVal     = {"head_.lname","request_date","ot_specific_date","no_of_hour",
															"approve_stat", "sub_.lname","d_name","c_name"};

int iSearchResult = 0;

String strDateFrom = WI.fillTextValue("DateFrom");
String strDateTo = WI.fillTextValue("DateTo");


if (strDateFrom.length() ==0){
	String[] astrCutOffRange = eDTRUtil.getCurrentCutoffDateRange(dbOP,true);
	if (astrCutOffRange!= null && astrCutOffRange[0] != null){
		strDateFrom = astrCutOffRange[0];
		strDateTo = astrCutOffRange[1];
	}
}

ReportEDTR RE = new ReportEDTR(request);
eDTR.OverTime ot = new eDTR.OverTime();

if (WI.fillTextValue("delete_records").equals("1")){
	int iDeletedRec = ot.deleteMultipleOTReq(dbOP, request);
	
	if (iDeletedRec == -1 ){
		strErrMsg = ot.getErrMsg();
	}else{
		strErrMsg = iDeletedRec + " pending OT requests were deleted successfully";
	}
}

Vector vRetResult = null;

boolean bolAllowOTCost = false;
int iTempMin = 0;
int iTempHr = 0;
double dTemp = 0d;
double dHoursOT = 0d;

String strSQLQuery = 
					"select restrict_index from edtr_restrictions where restriction_type = 1 " +
					" and user_index_ = " + (String)request.getSession(false).getAttribute("userIndex");
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
if(strSQLQuery != null)
	bolAllowOTCost = true;

if (WI.fillTextValue("viewAll").equals("1")){

	vRetResult = RE.searchOvertime(dbOP, true);
	if (vRetResult==null){
		strErrMsg =  RE.getErrMsg();
	}else{
		iSearchResult = RE.getSearchCount();
	}
}
%>
<form action="./view_all_ot_request.jsp" method="post" name="dtr_op">
<input type="hidden" name="print_page">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        OVERTIME REQUEST VIEW PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="2">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <tr >
      <td width="17%" height="25"><strong>&nbsp;&nbsp;&nbsp;&nbsp;Date&nbsp;</strong></td>
      <td width="83%"><strong>&nbsp;From</strong>
        <input name="DateFrom" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateFrom','/')" value="<%=strDateFrom%>" size="10" maxlength="10">
        <a href="javascript:show_calendar('dtr_op.DateFrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;<strong>To</strong>
        <input name="DateTo" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateTo','/')" value="<%=strDateTo%>" size="10" maxlength="10">
        <a href="javascript:show_calendar('dtr_op.DateTo');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
	<%if(!bolMyHome){%> 
    <tr>
      <td width="17%"><strong>&nbsp;Requested By </strong></td>
      <td colspan="2"><select name="emp_id_con">
          <%=RE.constructGenericDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
          <input name="requested_by" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15"
			  value="<%=WI.fillTextValue("requested_by")%>"></td>
      <td width="30%">&nbsp;</td>
    </tr>
    <tr>
      <td width="17%"><strong>&nbsp;Requested For </strong></td>
      <td colspan="2"> 
          <input name="req_for_id" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15"
			  value="<%=WI.fillTextValue("req_for_id")%>" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
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
      <td width="30%"><select name="status" id="status">
        <option value="">ALL</option>
        <% if (WI.fillTextValue("status").equals("1")){%>
        <option value="1" selected>APPROVED</option>
        <%}else{%>
        <option value="1">APPROVED</option>
        <%} if (WI.fillTextValue("status").equals("0")){%>
        <option value="0" selected>DISAPPROVED</option>
        <%}else{%>
        <option value="0" >DISAPPROVED</option>
        <%} if (WI.fillTextValue("status").equals("2")){%>
        <option value="2" selected>PENDING</option>
        <%}else{%>
        <option value="2">PENDING</option>
        <%}%>
      </select></td>
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
      <td><strong>&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></strong></td>
			<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
			%>			
      <td colspan="3"><select name="c_index" onChange="loadDept();">
                <option value="">N/A</option>
                <%
	strTemp = WI.fillTextValue("c_index");
	if (strTemp.length()<1) strTemp="0";
   if(strTemp.compareTo("0") ==0)
	   strTemp2 = "Offices";
   else
	   strTemp2 = "Department";%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr>
      <td><strong>Department</strong></td>
      <td colspan="3">
			<label id="load_dept">
			<select name="d_index">
        <option value="">ALL</option>
        <%if (strCollegeIndex.length() == 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%>
        <%}else if (strCollegeIndex.length() > 0){%>
        <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
        <%}%>
      </select>
			</label>
	  </td>
    </tr>
    <%if(bolHasTeam){%>
		<tr>
      <td><strong>&nbsp;Team</strong></td>
      <td><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>			
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
		<%}%>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <%if(bolAllowOTCost){%>
		<tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
					<%
						strTemp = WI.fillTextValue("show_cost");
						if(strTemp.length() > 0)
							strTemp = "checked";
						else
							strTemp = "";
					%>				
          <td width="33%"><input type="checkbox" name="show_cost" value="1" <%=strTemp%>>
Show Overtime Cost </td>
					<%
						strTemp = WI.fillTextValue("show_internal");
						if(strTemp.length() > 0)
							strTemp = "checked";
						else
							strTemp = "";
					%>
          <td width="67%"><input type="checkbox" name="show_internal" value="1" <%=strTemp%>>
Show Internal Costing </td>
        </tr>
      </table></td>
    </tr>
		<%}%>
    <tr>
      <td height="21" bgcolor="#FFFFFF">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_details");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td bgcolor="#FFFFFF"><input type="checkbox" name="show_details" value="1" <%=strTemp%>>
        Show OT details and approval remarks </td>
    </tr>
    <tr>
      <td height="21" bgcolor="#FFFFFF">&nbsp;</td>
			<%
				if(WI.fillTextValue("show_actual").length() > 0)
					strTemp = " checked";
				else
					strTemp = "";			
			%>			
      <td bgcolor="#FFFFFF"><input type="checkbox" name="show_actual" value="1" <%=strTemp%>> 
      show No. of Hours in HH:mm format </td>
    </tr>
    <tr>
      <td height="21" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">
		<input type="checkbox" name="show_division" value="checked" <%=WI.fillTextValue("show_division")%>>Show Department/office &nbsp;
		<input type="checkbox" name="show_reason" value="checked" <%=WI.fillTextValue("show_reason")%>>Show Reason  &nbsp;
		<input type="checkbox" name="remove_req_by" value="checked" <%=WI.fillTextValue("remove_req_by")%>>Remove Requested by  &nbsp;
		<input type="checkbox" name="remove_status" value="checked" <%=WI.fillTextValue("remove_status")%>>Remove OT Status  &nbsp;
		<input type="checkbox" name="remove_date_of_req" value="checked" <%=WI.fillTextValue("remove_date_of_req")%>>Remove Date of Request 
	  </td>
    </tr>
    <tr>
      <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td width="17%" height="21" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="83%" bgcolor="#FFFFFF"><input name="image" type="image" onClick="ViewRecords()" src="../../../images/form_proceed.gif" width="81" height="21">      </td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="26" colspan="4" bgcolor="#FFFFFF">&nbsp;</td>
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
					if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
      </select></td><td width="28%" bgcolor="#FFFFFF"><select name="sort_by2">
      <option value="">N/A</option>
      <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
    </select>
        <br>
        <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
				if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
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
          <% if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
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
<% if (vRetResult != null){ %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td>&nbsp;</td>
	  <% strTemp = WI.fillTextValue("show_all");
			if (strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = ""; %>	
    <td colspan=2 align="right"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
check to show all result </td>
  </tr>
  <tr>
    <td><b>Total Requests: <%=iSearchResult%> 
	  <%if(strTemp.length() == 0){%>- Showing(<%=RE.getDisplayRange()%>) <%}%></b></td>
    <td width="26%" colspan="-2">&nbsp;</td>
    <td width="31%" colspan="-2" align="right">
	<% if (strTemp.length() == 0) {%> 
	
	Jump To page:
      <select name="jumpto" onChange="goToNextSearchPage();">
   <% 
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
	strTemp = request.getParameter("jumpto");
	
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
		for( i =1; i<= iPageCount; ++i ){
			if(i == Integer.parseInt(strTemp) ){%>
        <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
        <%
				}
		}
	%>
      </select>	  
	<%}%>	  </td>
  </tr>
  <tr bgcolor="#F4FBF5">
    <td height="25" colspan="3" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME SCHEDULE REQUEST
    </strong></font></td>
  </tr>
  <tr>
    <td colspan="3"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <%if(WI.fillTextValue("show_division").length() > 0){%>
				<td width="18%" align="center" class="thinborder"><strong><font size="1">Department / Office</font></strong></td>
        <%}if(WI.fillTextValue("remove_req_by").length() == 0){%>
        	<td width="17%" align="center" class="thinborder"><strong><font size="1">Requested by </font></strong></td>
		<%}%>
        <td width="17%" align="center" class="thinborder"><font size="1"><strong>Requested For</strong></font></td>
        <%if(WI.fillTextValue("remove_date_of_req").length() == 0){%>
        	<td width="10%" align="center" class="thinborder"><font size="1"><strong>Date of Request</strong></font></td>
        <%}%>
		<td width="14%" align="center" class="thinborder"><font size="1"><strong>OT Date</strong></font></td>
        <td width="12%" align="center" class="thinborder"><font size="1"><strong>Inclusive Time</strong></font></td>
        <td width="4%" align="center" class="thinborder"><font size="1"><strong>No. of Hours</strong></font></td>
        <%if(WI.fillTextValue("show_details").length() > 0 || WI.fillTextValue("show_reason").length() > 0){%>
				<td width="25%" align="center" class="thinborder"><font size="1"><strong>Details</strong></font></td>
        <%}if(WI.fillTextValue("remove_status").length() == 0){%>
				<td width="11%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
        <%}if(WI.fillTextValue("show_cost").length() > 0){%>
				<td width="6%" align="center" class="thinborder"><font size="1"><strong>Cost</strong></font></td>
		<%}%>
        <% if (iAccessLevel == 2) {%> 
        <td colspan="2" align="center" class="thinborder">&nbsp;</td>
        <%}%> 
      </tr>
        <%
			int iCtr = 0;
			for (i=0 ; i < vRetResult.size(); i+=45){ 
		 %>
      <tr>
				<%if(WI.fillTextValue("show_division").length() > 0){%>
				<%if((String)vRetResult.elementAt(i + 21)== null || (String)vRetResult.elementAt(i + 23)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>				
        <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 22),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 23),"")%> </td>
				<%}%>
				<%
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
									(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
				strTemp = (String)vRetResult.elementAt(i);				
        if(WI.fillTextValue("remove_req_by").length() == 0){%>
        	<td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2, "", "<br>(" + strTemp + ")","")%></td>
        <%} if (strTemp.equals((String)vRetResult.elementAt(i+1)))
						strTemp = "&nbsp;";
					else{
						strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
											(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
						strTemp += "(" + (String)vRetResult.elementAt(i+1) + ")";
					}
				%>
        <td class="thinborder">&nbsp;<%=strTemp%></td>
        <%if(WI.fillTextValue("remove_date_of_req").length() == 0){%>
        <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
        <%}
		   		strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
		   		if (strTemp  == null || strTemp.length() < 1){
		   			strTemp = (String)vRetResult.elementAt(i+4);
			    }else{
					strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
							" - " +	(String)vRetResult.elementAt(i+5) + ")";
				}
			%>
        <td align="center" class="thinborder">          <%=strTemp%></td>
        <td align="center" class="thinborder">
					<%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
			                               (String)vRetResult.elementAt(i+8),
										   (String)vRetResult.elementAt(i+9))%> - 
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), false);
				if(WI.fillTextValue("show_actual").length() > 0){
					strTemp = ConversionTable.replaceString(strTemp, ",","");
					dHoursOT = Double.parseDouble(strTemp);
					iTempHr = (int)dHoursOT;
					dTemp = dHoursOT - iTempHr;
					iTempMin = (int)((dTemp * 60) + 0.2);
					strTemp = iTempHr + ":" + CommonUtil.formatMinute(Integer.toString(iTempMin));
				}				
				%>
        <td class="thinborder">&nbsp;<%=strTemp%></td>
				<%if(WI.fillTextValue("show_details").length() > 0 || WI.fillTextValue("show_reason").length() > 0){%>
				<%
					strTemp = (String)vRetResult.elementAt(i+29);	
					strTemp = WI.getStrValue(strTemp,"&nbsp;");
					if(WI.fillTextValue("show_reason").length() == 0) 
						strTemp += WI.getStrValue((String)vRetResult.elementAt(i+35), "<br>-<font color='#FF0000'>", "</font>","");
				%>
        <td class="thinborder"><%=strTemp%></td>
				<%}%>
        <%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp.equals("1")){ 
					strTemp = "<strong><font color='#0000FF'> APPROVED </font></strong>";
				}else if (strTemp.equals("0")){
					strTemp = "<strong><font color='#FF0000'> DISAPPROVED </font></strong>";
				}else
					strTemp = "<strong> PENDING </strong>";
        if(WI.fillTextValue("remove_status").length() == 0){%>
        	<td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
        <%}if(WI.fillTextValue("show_cost").length() > 0){%>
				<td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+28)%></td>
				<%}%>				
        <% if (iAccessLevel == 2) {%> 		
        <td width="3%" class="thinborder">&nbsp;
			<% if (strTemp.indexOf("PENDING") != -1) {%>
			<input type="checkbox" value="<%=(String)vRetResult.elementAt(i+14)%>" 
				name="checkbox<%=iCtr++%>">
			<%}%>		</td>
        <td width="6%" class="thinborder"><a href='javascript:ViewDetails("<%=(String)vRetResult.elementAt(i+14)%>")'><img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
<%}%> 
      </tr>
      <%}%>
    </table></td>
  </tr>

  <tr>
    <td colspan="3" align="right" height="25">&nbsp;
<% if (iCtr > 0) {%> 
	<a href='javascript:DeleteRequest()'><img src="../../../images/delete.gif" width="55" height="28" border="0" name="del_"></a><span class="style1"> remove selected items</span><input type="hidden" name="max_entries" value="<%=iCtr%>">
<%}%>	</td>
  </tr>
  <tr>
    <td colspan="3" align="center" style="font-size:9px;">
	Number of Employees / rows Per Page :</font>
      <select name="num_rec_page">
        <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 15; i <=60 ; i++) {
				if ( i == iDefault) {%>
        <option selected value="<%=i%>"><%=i%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%></option>
        <%}}%>
      </select>
	
	<a href="javascript:printpage();"><img src="../../../images/print.gif"></a> <font style="size:9px"> click to print result</font></td>
  </tr>
</table>

<% }%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="viewAll" value="">
<input type="hidden" name="delete_records" value="0">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>