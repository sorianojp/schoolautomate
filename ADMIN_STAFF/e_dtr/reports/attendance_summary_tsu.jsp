<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date, eDTR.ReportEDTRExtn" 
																buffer="16kb"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Attendance Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}
	.footerDynamic {
		background-color:<%=strColorScheme[2]%>
	}

    table.thinborder {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }
    TD.thinborder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }
		
		TD.thinborderReg {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
    }
		
		TD.BottomLeftRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function goToNextSearchPage(){
	ViewRecords();
	document.dtr_op.submit();
}
function ReloadPage()
{
	document.dtr_op.print_page.value="";

	document.dtr_op.reloadpage.value="1";
//	document.dtr_op.viewRecords.value ="1";
	document.dtr_op.submit();
}

function ViewRecords(){
	var vCheck = 0;
	var maxDisp = document.dtr_op.leave_count.value;
	if(document.dtr_op.show_ut.checked)
		vCheck++;
	if(document.dtr_op.show_late.checked)
		vCheck++;
	if(document.dtr_op.show_lwop.checked)
		vCheck++;
			
	for(var i =1; i< maxDisp; ++i){
		if(eval('document.dtr_op.leave_type_'+i+'.checked'))
			vCheck++;
	}
	if(vCheck == 0){
		alert("Please select at least 1 option to show");
		return;
	}

	document.dtr_op.print_page.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}

function PrintPage(){
	if(document.dtr_op.prepared_by.value == ""){
		alert("Enter prepared by");
		document.dtr_op.prepared_by.focus();
		return;
	}

	if(document.dtr_op.approved_by.value == ""){
		alert("Enter approving officer");
		document.dtr_op.approved_by.focus();
		return;
	}
 	document.dtr_op.print_page.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.submit(); 
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
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function checkAllSave() {
	var maxDisp = document.dtr_op.leave_count.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.select_all.checked) {
		document.dtr_op.show_ut.checked=false;
		document.dtr_op.show_late.checked=false;
		document.dtr_op.show_lwop.checked=false;
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.leave_type_'+i+'.checked=false');
	}
	else {
		document.dtr_op.show_ut.checked=true;
		document.dtr_op.show_late.checked=true;
		document.dtr_op.show_lwop.checked=true;
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.leave_type_'+i+'.checked=true');
	}
}
</script>

<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./attendance_summary_tsu_print.jsp" />
<%}
	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
  Vector vRetEDTR = new Vector();
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	String strTemp3 = null;
	int iCol = 0;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 0;
	double dTemp = 0d;
	boolean bolShowUT = WI.fillTextValue("show_ut").length() > 0;
	boolean bolShowLate = WI.fillTextValue("show_late").length() > 0;
	boolean bolShowLwop = WI.fillTextValue("show_lwop").length() > 0;
	boolean bolHasTeam = false;
	
	String strAMPMSet = "";
	String strAM = null;
	String strPM = null;
	String strMonths = WI.fillTextValue("strMonth");
 	String strYear = WI.fillTextValue("sy_");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Attendance Summary","attendance_summary_tsu.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"attendance_summary_tsu.jsp");
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
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

ReportEDTR RE = new ReportEDTR(request);
ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
Vector vDayInterval = null;

Vector vAllLeaves = null;
Vector vLeaveBenefits = null;
int iVarCols = 0;

String strDateFr = null;
String strDateTo = null;
int iIndexOf  = 0;
String strLate = null;
String strUt = null;
int iWidth = 2;
int iCounter = 1;
int l = 0;
double[] adTotal = null;
String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");

String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
vLeaveBenefits = rptExtn.getLeaveBenefits(dbOP);
if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = RE.searchEDTR(dbOP, true);

	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();
 //added by biswa to get from and to date.
	if( WI.fillTextValue("DateDefaultSpecify").equals("2")) {
		try{			
			if (strYear.length()> 0){
				if (Integer.parseInt(strYear) >= 2005)
					calTemp.set(Calendar.YEAR, Integer.parseInt(strYear));
			else
				strErrMsg = " Invalid year entry";

			}else{
				strYear = Integer.toString(calTemp.get(Calendar.YEAR));
			}
		}
		catch (NumberFormatException nfe){
		strErrMsg = " Invalid year entry";
		}
	
		calTemp.set(Calendar.DAY_OF_MONTH,1);
	
		 if(!strMonths.equals("0") && strMonths.length() > 0){
				calTemp.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
		 }else{
				strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
		 }
	
		strDateFr = strMonths + "/01/" + calTemp.get(Calendar.YEAR);
		strDateTo = strMonths + "/" + Integer.toString(calTemp.getActualMaximum(Calendar.DAY_OF_MONTH))
				+ "/" + calTemp.get(Calendar.YEAR); 
	} else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");
	}

 		vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo, true);		
		if (vDayInterval == null)
			strErrMsg = RE.getErrMsg();
		else{
			iWidth = 80/vDayInterval.size();
		}
	vAllLeaves = rptExtn.getEmployeeLeaveWithName(dbOP, strDateFr , strDateTo);
	
 }

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="dtr_op" action="./attendance_summary_tsu.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header_">
     <tr bgcolor="#A49A6A">
			<%
				if(bolShowUT){
					strTemp = "UNDERTIME";
				}else{
					strTemp = "TARDINESS";				
				}
			%>		 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
       DTR OPERATIONS - ATTENDANCE SUMMARY ::::</strong></font></td>
    </tr>
     <tr bgcolor="#FFFFFF">
      <td height="25">
			<strong><font color="#FF0000" size="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
    
    <tr>
      <td height="24">&nbsp;</td>
      <td width="17%" height="24">Date</td>
      <td height="24"><select name="DateDefaultSpecify" onChange='ReloadPage();'>
        <option value="1">Specify date</option>
        <% if (WI.fillTextValue("DateDefaultSpecify").equals("2")){ %>
        <option value="2" selected>Month / year</option>
        <%}else{%>
        <option value="2">Month / year</option>
        <%}%>
				
      </select></td>
    </tr>
	<% if (strShowOpt.equals("1")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Specific Date range </td>
      <td height="25">
From
  <input name="from_date" type="text" size="10" maxlength="10"
	  value="<%=WI.fillTextValue("from_date")%>" class="textbox"
	  onKeyUp="AllowOnlyIntegerExtn('dtr_op','from_date','/');"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','from_date','/')">
  <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;to
        &nbsp;
        <input name="to_date" type="text" size="10" maxlength="10"
		value="<%=WI.fillTextValue("to_date")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'"
		onKeyUP = "AllowOnlyIntegerExtn('dtr_op','to_date','/')"
		onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','to_date','/')">
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>			</td>
    </tr>
		<%}else if (strShowOpt.equals("2")) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Month / Year</td>
      <td height="25">
	<select name="strMonth">
    <%
	  int iDefMonth = Integer.parseInt(strMonths);
	  	for (int i = 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
    <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
    <%} // end for lop%>
  </select>
-
<select name="sy_">
  <%=dbOP.loadComboYear(WI.fillTextValue("sy_"),2,1)%>
</select></td>
    </tr>
		<%}%>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Enter Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category">
        <option value="" selected>ALL</option>
        <%if (WI.fillTextValue("employee_category").equals("0")){%>
        <option value="0" selected>Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
        <option value="0">Non-Teaching</option>
        <option value="1" selected>Teaching</option>
        <%}else{%>
        <option value="0">Non-Teaching</option>
        <option value="1">Teaching</option>
        <%}%>
      </select></td>
    </tr>		
		<%}%>
<% if(WI.fillTextValue("print_by").compareTo("1") != 0){ %>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
				<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#FFFFFF">
            <td width="18%" height="25">Employment Type</td>
            <td width="82%" height="25">
              <%strTemp2 = WI.fillTextValue("emp_type");%>
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%>
              </select>            </td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
              <option value="">ALL</option>
              <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
            </select></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td height="25">Office</td>
            <td height="25"><select name="d_index" onChange="ReloadPage();">
              <option value="">ALL</option>
              <%if ((strCollegeIndex.length() == 0)){%>
              <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index is null or c_index = 0) ", WI.fillTextValue("d_index"),false)%>
              <%}else if (strCollegeIndex.length() > 0){%>
              <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%>
              <%}%>
            </select></td>
          </tr>
        </table></td>
    </tr>
    <%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25">Print DTR whose lastname starts with
        <select name="lname_from" onChange="ReloadPage()">
<%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<28; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
<%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
<%}
}%>
        </select>
        to
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");

			 for(int i=++j; i<28; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("exclude_ghosts");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td colspan="2" height="25"><input type="checkbox" name="exclude_ghosts" value="1" <%=strTemp%>>
Exclude employees without dtr entry for the period </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>			
      <td colspan="2" height="25"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
        show all result in single page </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" height="25"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
        <tr>
					<%
						strTemp = WI.fillTextValue("select_all");
						if(strTemp.length() > 0)	
							strTemp = "checked";
						else
							strTemp = "";
					%>
          <td colspan="3" class="thinborderReg"><input type="checkbox" name="select_all" value="0" onClick="checkAllSave();" <%=strTemp%>>
            select/ unselect all </td>
          </tr>
        <tr>
					<%
						if(bolShowUT)
							strTemp = "checked";
						else
							strTemp = "";
					%>
          <td width="30%" class="thinborderReg">
					<label for="ut_">
					<input type="checkbox" name="show_ut" value="1" <%=strTemp%> id="ut_">Undertime</label></td>
					<%						
						if(bolShowLate)
							strTemp = "checked";
						else
							strTemp = "";
					%>
          <td width="36%" class="thinborderReg">
					<label for="late_">
					<input type="checkbox" name="show_late" value="1" <%=strTemp%> id="late_">Tardiness					</label>					</td>
					<%
						if(bolShowLwop)
							strTemp = "checked";
						else
							strTemp = "";
					%>						
          <td width="34%" class="thinborderReg">
					<label for="lwop_">
					<input type="checkbox" name="show_lwop" value="1" <%=strTemp%> id="lwop_">Leave without pay					</label>					</td>
        </tr>
				<%if(vLeaveBenefits != null && vLeaveBenefits.size() > 0){%>
				<%for(l = 0; l < vLeaveBenefits.size();){
					iCol = 0;
				%>
        <tr>
					<%
					/*
						Warning! i was running on auto mode when creating this page!
						when dat happens pataka na lang ko code... hehehe
						katulugon ko. human humba pa jud ang akong sud an for lunch. mao! August 2, 2010
					*/
					for(; l < vLeaveBenefits.size() && iCol < 3;l+=5, iCol++, iCounter++){
						strTemp = WI.fillTextValue("leave_type_"+iCounter);
						if(strTemp.length() > 0)
							strTemp = "checked";
						else
							strTemp = "";
					%>
          <td class="thinborder">
					<label for="id_<%=iCounter%>">
					<input type="checkbox" name="leave_type_<%=iCounter%>" value="1" <%=strTemp%>
							id="id_<%=iCounter%>"> 					
					<%=iCounter%>-<%=(String)vLeaveBenefits.elementAt(l+1)%> <%=WI.getStrValue((String)vLeaveBenefits.elementAt(l+2), "(",")","")%></label></td>
					<%}%>
					<%while(iCol < 3){
						iCol ++;
					%>
					<td class="thinborder">&nbsp;</td>
					<%}%>
        </tr>
				<%}
				}%>
				<input type="hidden" name="leave_count" value="<%=iCounter%>">
				
      </table></td>
    </tr>
    <%}//end of print by.
%>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
			<input type="button" name="proceed_btn" value=" Proceed " 
			style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
			onClick="javascript:ViewRecords();">			</td>
    </tr>
 </table>
<%
	if (vRetResult!=null) {
		iSearchResult = RE.getSearchCount();
		int iPageCount =  1;

		if (RE.defSearchSize != 0) {
			iPageCount = iSearchResult/RE.defSearchSize;
			if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
		}

	if(iPageCount > 1) {//show this if page cournt > 1%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
	 <tr>

      <td width="66%"><b>Total Result: <%=iSearchResult%>
<% 	strTemp = "checked";
	if (!WI.fillTextValue("show_all").equals("1")) {
	strTemp = "";
%>
	   - Showing(<%=RE.getDisplayRange()%>)
<%}%>
	   </b> &nbsp;&nbsp;&nbsp;
 	   </td>
		  <td width="26%">&nbsp;
<% if (!WI.fillTextValue("show_all").equals("1")) {%>

		  Jump To page:
		<select name="jumpto" onChange="goToNextSearchPage()">
 <%
	strTemp = request.getParameter("jumpto");
	if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
	for( int i =1; i<= iPageCount; ++i ){
	if(i == Integer.parseInt(strTemp) ){%>
		<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}else{%>
	   <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
    <%}
	} // end for loop
%>
	   </select>

<%}%>
	   </td>
	    <td width="8%">&nbsp;</td>
	 </tr>
  </table>
 <%}//show jump page if page count > 1

 } // if ( PrintPage is not called.)
 %>
 	<%if(vDayInterval != null && vDayInterval.size() > 0){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr >
      <td height="25" colspan="2" align="center"  class="thinborder"><strong>ATTENDANCE SUMMARY</strong></td>
    </tr>
	</table>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td width="11%" height="25" rowspan="2" align="center" class="thinborder"><strong>Name</strong></td>
			<%
			if(bolShowUT)
				iVarCols++;
			
			if(bolShowLate)
				iVarCols++;
			
			if(bolShowLwop)
				iVarCols++;
			iCounter = 1;
			for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0)
					iVarCols++;
			}	
			for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){%>
			<%
			strTemp2 = (String)vDayInterval.elementAt(iDay);
			strTemp = strTemp2.substring(0,strTemp2.length() - 5);
			%>
      <td colspan="<%=iVarCols%>" align="center" class="thinborder"><%=strTemp%></td>			
			<%}%>
 			<td colspan="<%=iVarCols%>" align="center" class="thinborder">TOTAL</td>
		</tr>		
    <tr >      
		<%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
			iCounter = 1;
		%>		
			<%for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
					//strTemp = Integer.toString(iCounter);
					strTemp = WI.getStrValue((String)vLeaveBenefits.elementAt(l+2),Integer.toString(iCounter));
					if(strTemp.length() == 1){
						strTemp = "&nbsp;" + strTemp + "&nbsp;";
					}
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>      
			<%}
			}%>
			<%if(bolShowLwop){%>
			<td align="center" class="thinborder">NP</td>
			<%}%>
			<%if(bolShowUT){%>
      <td align="center" class="thinborder">UT</td>
			<%}%>
			<%if(bolShowLate){%>
      <td align="center" class="thinborder">&nbsp;T&nbsp;</td>
			<%}%>
			<%}%>
			<%
			iCounter = 1;
			for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
					//strTemp = Integer.toString(iCounter);
					strTemp = WI.getStrValue((String)vLeaveBenefits.elementAt(l+2),Integer.toString(iCounter));
					if(strTemp.length() == 1){
						strTemp = "&nbsp;" + strTemp + "&nbsp;";
					}				
			%>
			<td width="7%" align="center" class="thinborder"><%=strTemp%></td>
			<%}
			}%>
			<%if(bolShowLwop){%>
			<td width="7%" align="center" class="thinborder">NP</td>
			<%}%>
			<%if(bolShowUT){%>
			<td width="7%" align="center" class="thinborder">UT</td>
			<%}%>
			<%if(bolShowLate){%>
			<td width="6%" align="center" class="thinborder">&nbsp;T&nbsp;</td>
			<%}%>		  
    </tr>    
<%
 if (vRetResult!=null && vRetResult.size() > 0) {
	long lTotalUt = 0l;
	long lTotalLate = 0l;	
	long lUndertime = 0l;
	long lLate = 0l;
	String strBGColor = "";

	Vector vEmpLeavesWP = null; // leaves with pay
	Vector vEmpLeavesWoutP = null; // leaves without pay
	Vector vLeavePerDay = null;
	Integer iObjUserIndex = null;

//as requestd, i have to show all the days worked and non worked.
//	System.out.println("----------------------------------------------------");
   for (int i=0; i<vRetResult.size() ; i+=7){
		// vEmpLeaves
		// System.out.println("size -- " + (vLeaveBenefits.size()/5) + 3);
		adTotal = new double[(vLeaveBenefits.size()/5) + 3];
		iObjUserIndex = new Integer((String)vRetResult.elementAt(i+6));
		if(vAllLeaves != null){
			vEmpLeavesWP = new Vector();
			vEmpLeavesWoutP = new Vector();
			vLeavePerDay = new Vector();
			iIndexOf = vAllLeaves.indexOf(iObjUserIndex);
 			while(iIndexOf != -1){
				if(((String)vAllLeaves.elementAt(iIndexOf+3)).equals("0")){
					vAllLeaves.remove(iIndexOf); // remove user index(Integer)
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove date
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave hours/days
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove with[1]/ without pay[0]
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave status[0-dwop, 1-hwop, 2- dwp, 3-hwp]
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave sub type
					vEmpLeavesWoutP.addElement((Long)vAllLeaves.remove(iIndexOf)); // remove leave type index (Long)
				} else {
					vAllLeaves.remove(iIndexOf); // remove user index(Integer)
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove date
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave hours/days
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove with[1]/ without pay[0]
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave status[0-dwop, 1-hwop, 2- dwp, 3-hwp]
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave sub type
					vEmpLeavesWP.addElement((Long)vAllLeaves.remove(iIndexOf)); // remove leave type index (Long)
				}
					vAllLeaves.remove(iIndexOf);// free
					vAllLeaves.remove(iIndexOf);// free
					vAllLeaves.remove(iIndexOf);// free				
				iIndexOf = vAllLeaves.indexOf(iObjUserIndex);
			}
			
			//System.out.println("iObjUserIndex---- " + iObjUserIndex);
			//System.out.println("vEmpLeavesWP " + vEmpLeavesWP);
			//System.out.println("vEmpLeavesWoutP " + vEmpLeavesWoutP);
		}
		lLate = 0l;
		lUndertime = 0l;
		lTotalUt = 0l;
		lTotalLate = 0l;
				 
 		if(i%14 == 7){
			strBGColor = "#EEEEEE";
		}else{
			strBGColor = "";
		}
		
	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);

	vRetEDTR = RE.getDTRDetails(dbOP, (String)vRetResult.elementAt(i), true, true);
 
%>
		
    <tr bgcolor="<%=strBGColor%>">
      <td height="21" nowrap class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>		  
		  <%
		 for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
		 //System.out.println("---------- " + vDayInterval.elementAt(iDay));
			strTemp = "";
			strTemp2 = "";
		%>			
		<%
		if(vEmpLeavesWP != null){
			iIndexOf = vEmpLeavesWP.indexOf((String)vDayInterval.elementAt(iDay));
			while(iIndexOf != -1){
				vEmpLeavesWP.remove(iIndexOf); // remove date						
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove leave hours/days
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove with[1]/ without pay[0]
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove leave status
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove leave sub type
				vLeavePerDay.addElement((Long)vEmpLeavesWP.remove(iIndexOf)); // remove leave type index
				iIndexOf = vEmpLeavesWP.indexOf((String)vDayInterval.elementAt(iDay));
			}// end while
		}
		iCounter = 1;
		for(l = 0; l < vLeaveBenefits.size();l+=5,iCounter++){
			strTemp = "";
			if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
			//iIndexOf = vEmpLeavesWP.indexOf((String)vDayInterval.elementAt(iDay));
				if(vLeavePerDay != null){
					iIndexOf = vLeavePerDay.indexOf((Long)vLeaveBenefits.elementAt(l));
					while(iIndexOf != -1){
						iIndexOf = iIndexOf - 4;
						strTemp = (String)vLeavePerDay.remove(iIndexOf); // remove leave hours/days
						vLeavePerDay.remove(iIndexOf); // remove with[1]/ without pay[0]
						vLeavePerDay.remove(iIndexOf); // remove leave status
						vLeavePerDay.remove(iIndexOf); // remove leave sub type
						vLeavePerDay.remove(iIndexOf); // remove leave type index
						iIndexOf = vLeavePerDay.indexOf((Long)vLeaveBenefits.elementAt(l));
					}// end while
				}
				strTemp2 = CommonUtil.formatFloat(strTemp, true);
				strTemp2 = ConversionTable.replaceString(strTemp2, ",","");
				adTotal[iCounter-1] += Double.parseDouble(strTemp2);				
			%>		
		<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		}%>			
		<%
			if(bolShowLwop){
				if(vEmpLeavesWoutP != null){
					iIndexOf = vEmpLeavesWoutP.indexOf((String)vDayInterval.elementAt(iDay));
					while(iIndexOf != -1){
						vEmpLeavesWoutP.remove(iIndexOf); // remove date						
						strTemp = (String)vEmpLeavesWoutP.remove(iIndexOf); // remove leave hours/days
						vEmpLeavesWoutP.remove(iIndexOf); // remove with[1]/ without pay[0]
						vEmpLeavesWoutP.remove(iIndexOf); // remove leave status
						vEmpLeavesWoutP.remove(iIndexOf); // remove leave sub type
						vEmpLeavesWoutP.remove(iIndexOf); // remove leave type index
						iIndexOf = vEmpLeavesWoutP.indexOf((String)vDayInterval.elementAt(iDay));
					}// end while
				}
				strTemp2 = CommonUtil.formatFloat(strTemp, false);
				strTemp2 = ConversionTable.replaceString(strTemp2, ",","");
				dTemp = Double.parseDouble(strTemp2);
				adTotal[iCounter-1] += dTemp;

				if(dTemp == 0d)
					strTemp2 = "";
			%>		
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
			<%}// end if bolShowLwop%>
			<%
				strAM = "";
				strPM = "";
				lLate = 0l;
				lUndertime = 0l;					
				strLate = "";
				strUt = "";				
 			if(vRetEDTR != null){			
				if (vRetEDTR.size() == 1){//non DTR employees
					strTemp = (String) vRetEDTR.elementAt(0);
				}else{
 					iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					strAM = "";
					strPM = "";

					
					while(iIndexOf != -1){						
 						//if(iIndexOf != -1){
 							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							
							strLate = (String)vRetEDTR.remove(iIndexOf); // remove late_time_in
							if(bolShowLate){
								lLate += Long.parseLong(WI.getStrValue(strLate,"0"));
							}else{
								strLate = "&nbsp;";
							}
							
							if(lLate == 0)
								strLate = "&nbsp;";
							else
								strLate = Long.toString(lLate);							
							
							strUt = (String)vRetEDTR.remove(iIndexOf); // remove under_time
 							if(bolShowUT){
								lUndertime += Long.parseLong(WI.getStrValue(strUt,"0"));
							} 

							if(lUndertime == 0)
								strUt = "&nbsp;";
							else
								strUt = Long.toString(lUndertime);
 
							vRetEDTR.remove(iIndexOf); // remove '**' indicator
							strAMPMSet = (String)vRetEDTR.remove(iIndexOf); // remove am_pm_set
							strAMPMSet = WI.getStrValue(strAMPMSet);
							vRetEDTR.remove(iIndexOf); // remove free
							vRetEDTR.remove(iIndexOf); // remove free
							vRetEDTR.remove(iIndexOf); // remove free
							vRetEDTR.remove(iIndexOf); // remove free
							vRetEDTR.remove(iIndexOf); // remove free
					
							vRetEDTR.remove(iIndexOf - 1); // remove timeout	
							vRetEDTR.remove(iIndexOf - 2); // remove timein							
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
						//}
						
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}		
					lTotalUt +=lUndertime;
					lTotalLate += lLate;
				}// end else
			}		
				adTotal[iCounter] += (double)lUndertime;
				
				adTotal[iCounter+1] += (double)lLate;
			%>
			<%			
			if(bolShowUT){%>
      <td height="21" align="right" class="thinborder"><%=WI.getStrValue(strUt,"&nbsp;")%></td>	
			<%}// end bolShowUT%>		
			<%if(bolShowLate){%>
			<td align="right" class="thinborder"><%=WI.getStrValue(strLate,"&nbsp;")%></td>
			<%}%>
			<%}// end inner for loop%>
			
			<%
			iCounter = 1;
			for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
			%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter-1], false)%></td>
			<%}
			}%>
			<%if(bolShowLwop){%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter-1], false)%></td>
			<%}%>
			<%if(bolShowUT){%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter], false)%></td>
			<%}%>
			<%if(bolShowLate){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter+1], false)%></td>
			<%}%>
    </tr>
		<%}// end employee for loop%>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="print_table">
    <tr >
      <td height="25" colspan="2" bgcolor="#FFFFFF" >&nbsp;</td>
    </tr>
	  <tr >
	    <td width="15%" height="25" bgcolor="#FFFFFF">Prepared by : </td>
      <td width="85%" height="25" bgcolor="#FFFFFF">
			<input name="prepared_by" type="text" size="32" value="<%=WI.fillTextValue("prepared_by")%>" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	  <tr >
	    <td height="25" bgcolor="#FFFFFF">Approved by: </td>
			<%
				strTemp = WI.fillTextValue("approved_by");
 				if(strTemp.length() == 0)
					strTemp = WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"University President",7)),"").toUpperCase();
				if(strTemp.length() == 0)
					strTemp = WI.getStrValue((CommonUtil.getNameForAMemberType(dbOP,"President",7)),"").toUpperCase();
			%>
      <td height="25" bgcolor="#FFFFFF">
			<input name="approved_by" type="text" size="32" value="<%=strTemp%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  </tr>
	  <tr >
      <td height="25" colspan="2" bgcolor="#FFFFFF" align="center">
			<font size="2">Number of Employees Per Page :</font>
      <select name="num_rec_page">
        <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i =15; i <=45 ; i++) {
				if ( i == iDefault) {%>
        <option selected value="<%=i%>"><%=i%></option>
        <%}else{%>
        <option value="<%=i%>"><%=i%></option>
        <%}
			}%>
      </select>
	  	<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
			<font size="1">click to print</font></td>
    </tr>
</table>
<%}// if (vRetResult)%>
<%}// if vDayInterval%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="footer_">
    <tr bgcolor="#ffffff">
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25">&nbsp;</td>
    </tr>
</table>

<input type="hidden" name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
<input type="hidden" name="viewRecords" value="0">
<input type="hidden" name="for_undertime" value="<%=WI.fillTextValue("for_undertime")%>">
<input type="hidden" name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
