<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ReloadPage(){
		document.dtr_op.submit();
	}
	
	function CancelRecord(){
		location = "./batch_approve_ot.jsp?my_home="+document.dtr_op.my_home.value;
	}
	
	function SaveRecord(){
		document.dtr_op.save_record.value = 1;
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.aEmp";
		var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
function AjaxMapName() {
		var strCompleteName = document.dtr_op.requested_by.value;
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
	document.dtr_op.requested_by.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
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
</head>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime, eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
 
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

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OverTime","batch_approve_ot.jsp");
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
														"eDaily Time Record","OVERTIME MANAGEMENT-APPROVE",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");
														
// added for CLDHEI.. 
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome && iAccessLevel <= 0){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").equals("1"))
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
	//end of authenticaion code.
	OverTime OT = new OverTime();
	Vector vRetResult = null;
	ReportEDTR RE = new ReportEDTR(request);
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Requested By","Date of Request","Date of OT", "No of Hours","Status", "Last Name(Requested for)"};
	String[] astrSortByVal     = {"head_.lname","request_date","ot_specific_date","no_of_hour","approve_stat", "sub_.lname"};

	
	String strDateFrom = WI.fillTextValue("DateFrom");
	String strDateTo = WI.fillTextValue("DateTo");
	
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
		strErrMsg = OT.getErrMsg();
%>
<form action="./batch_approve_ot.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" ><strong>:::: 
        VALIDATE/APPROVE OVERTIME::::</strong></font></td>
    </tr>
    <tr >
      <td height="25"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr >
      <td height="25"><table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
        <tr>
          <td><strong>&nbsp;&nbsp;&nbsp;&nbsp;Date&nbsp;</strong></td>
          <td colspan="3"><strong>&nbsp;From</strong>
            <input name="DateFrom" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateFrom','/')" value="<%=strDateFrom%>" size="10" maxlength="10">
            <a href="javascript:show_calendar('dtr_op.DateFrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;<strong>To</strong>
            <input name="DateTo" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('dtr_op','DateTo','/')" value="<%=strDateTo%>" size="10" maxlength="10">
            <a href="javascript:show_calendar('dtr_op.DateTo');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
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
						%>
          <td width="30%">
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
      </table></td>
    </tr>
    <tr >
      <td height="25"><table width="100%" border="0" cellpadding="0" cellspacing="0">
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
</table>&nbsp;</td>
    </tr>
    <tr > 
      <td height="25"><input name="image" type="image" onClick="ReloadPage()" src="../../../images/form_proceed.gif" width="81" height="21"></td>
    </tr>
  </table>
<% 
	if (vRetResult != null && vRetResult.size()>3) { %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
      <tr>
        <td width="18%" align="center" class="thinborder"><strong><font size="1">Requested 
          by </font></strong></td>
        <td width="18%" align="center" class="thinborder"><font size="1"><strong>Requested 
          For</strong></font></td>
        <td width="14%" align="center" class="thinborder"><font size="1"><strong>Date 
          of Request</strong></font></td>
        <td width="14%" align="center" class="thinborder"><font size="1"><strong>OT 
          Date</strong></font></td>
        <td width="12%" align="center" class="thinborder"><font size="1"><strong>Inclusive 
          Time</strong></font></td>
        <td width="4%" align="center" class="thinborder"><font size="1"><strong>No. 
          of Hours</strong></font></td>
        <td width="11%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
<% if (iAccessLevel == 2) {%> 
        <td align="center" class="thinborder">&nbsp;</td>
        <%}%> 
      </tr>
      <tr>
        <%
			int iCtr = 1;
			for (i=0 ; i < vRetResult.size(); i+=21, iCtr++){ 
			strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
								(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
		 	strTemp = (String)vRetResult.elementAt(i);
			strTemp = WI.getStrValue(strTemp);
		 %>
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
        <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
        <% 
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
										   (String)vRetResult.elementAt(i+9))%> - <br>
                  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
			  						 (String)vRetResult.elementAt(i+11),
									 (String)vRetResult.elementAt(i+12))%></td>
        <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
        <%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp.equals("1")){ 
					strTemp = "<strong><font color='#0000FF'> APPROVED </font></strong>";
				}else if (strTemp.equals("0")){
					strTemp = "<strong><font color='#FF0000'> DISAPPROVED </font></strong>";
				}else
					strTemp = "<strong> PENDING </strong>";
			%>
        <td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
			<% if (iAccessLevel == 2) {%> 		
        <td width="3%" class="thinborder">&nbsp;
				<% if (strTemp.indexOf("PENDING") != -1) {%>
				<input type="checkbox" value="1" name="save_<%=iCtr%>">
				<%}else{%>		
				<input type="hidden" name="save_<%=iCtr%>">
				<%}%>			
				</td>
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
						<td width="19%" align="right">Remarks : </td>
						<%
							strTemp = WI.fillTextValue("ot_stat_reason");
						%>									
						<td colspan="3">
					<input name="ot_stat_reason" type="text" size="64" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					value="<%=strTemp%>">
					</td>
					</tr>
					<tr> 
						<td>Approved by : </td>
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
						<td>Date of Approval : </td>
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
						</select>				  
						</td>
					</tr>
				</table></td>
		</tr>
		<tr>
			<td colspan="4" align="center">
				 
				<input name="image2" type="image" onClick="SaveRecord();" src="../../../images/save.gif" width="48" height="28">
				<font size="1">click to save changes</font></td>
		</tr>
	</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>


  <input type="hidden" name="save_record">  
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>