<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Summary per Department/office</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
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
<script language="JavaScript">

function FocusID() {
	document.form_.emp_id.focus();
}

function ViewPrintDetails(strEmpID, strYear,strYearTo,strSemester,strBenefitIndex){
	var pgLoc = "../leave/leave_apply.jsp?view_only=1&emp_id="+ strEmpID  +
		"&sy_from="+strYear+"&sy_to="+strYearTo+"&semester="+strSemester+"&benefit_index=" + strBenefitIndex;
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no,dependent=yes');
	win.focus();
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function ChangeLeave(){
 	var strCurLeaveText = document.form_.cur_leave_text.value;
	if(strCurLeaveText.length == 0 || strCurLeaveText == null)
		strCurLeaveText = document.form_.benefit_index[document.form_.benefit_index.selectedIndex].text;
	if(strCurLeaveText.toUpperCase().indexOf("SICK") != -1){
		showLayer('sl_variant');			
	}else{
		hideLayer('sl_variant');
		document.form_.nature_leave.value = "";
	}
}

function PrintPg() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
 
 	document.getElementById('myADTable2').deleteRow(0);
 
 	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
 
 	document.form_.print_page.value = "1";
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>

<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	boolean bolMyHome = false;
	


//add security hehol.

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Leave Summary","leave_summary_auf.jsp");

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
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_summary_auf.jsp");

if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"leave_summary_auf.jsp");
}

// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){//for my home, allow applying leave.
		//if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		//else 
		//	iAccessLevel = 1;

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
Vector vEmpLeaves = null;
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status","HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","c_name","d_name"};

String[] astrNatureLeave = {"Sick","Emergency","Personal"};

int iSearchResult = 0;
ReportEDTR rptLeave = new ReportEDTR(request);
int iAction =  -1;

 if (WI.fillTextValue("searchEmployee").equals("1")) {
	vRetResult = rptLeave.viewLeavesSummaryAUF(dbOP, request);
 	
	if (vRetResult == null){
		strErrMsg = rptLeave.getErrMsg();
	}else
		iSearchResult = rptLeave.getSearchCount();
 }
 
 String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
 String strSYFrom = WI.fillTextValue("sy_from");
 String strSYTo = WI.fillTextValue("sy_to");
 String strSemester = WI.fillTextValue("semester");
 
 String[] astrNature = {"Sick Leave", "Emergency Leave", "Personal Leave", "Others"};

	String strOffice = "";
	Long lUserIndex = null;
	String strSem = null;
	int iLeaves = 0;
	double dHour = 0d;
	double dMin = 0d;
	double dDuration = 0d;
	double dTotalLeave = 0d;
	int i = 0;
	
%>
<body bgcolor="#663300" class="bgDynamic" onLoad="ChangeLeave();">
<form action="./hr_leave_summary_auf.jsp" method="post" name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
  <tr>
    <td>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="772%" height="25" colspan="4" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" size="2" ><strong>:::: 
        HR : LEAVE SUMMARY ::::</strong></font></td>
    </tr>
  </table>
	</td>
  </tr>
  <tr>
    <td><table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Date</td>
      <td colspan="2"><input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        <font size="1">(leave 'date to' field empty for a specific date)</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Month</td>
      <td colspan="2"><select name="strMonth">
	  <% 
	  	for (i = 0; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("strMonth"),"0")) == i) {
	  %>
	  	<option value="<%=i%>" selected><%=astrMonth[i]%></option>	  
	  <%}else{%>
	  	<option value="<%=i%>"><%=astrMonth[i]%></option>
	  <%} 
	  } // end for lop%>
	  </select> 
		<select name="year_of">
      <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
    </select><font size="1">(selecting a month will overwrite date(s) entry)</font></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="15%" class="fontsize11">Employee ID </td>
      <td width="11%">
				<select name="id_number_con">
				<%=rptLeave.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
				</select>			</td>
      <td width="72%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Lastname</td>
      <td><select name="lname_con">
          <%=rptLeave.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td class="fontsize11">Firstname</td>
      <td><select name="fname_con">
          <%=rptLeave.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Emp. Status</td>
      <td colspan="2"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Position&nbsp;</td>
      <td colspan="2"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");

if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
      </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td class="fontsize11">Office/Dept</td>
      <td colspan="2"><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
      </tr>
    <tr>
      <td height="24">&nbsp;</td>
				
      <td class="fontsize11">Leave Filter </td>
			<%
				strTemp = WI.fillTextValue("benefit_index");
			%>			
      <td colspan="2" class="fontsize11">			
			<select name="benefit_index" onChange="ChangeLeave()">
				<option value="">All</option>
        <%if(strTemp.equals("0")){%>
				<option value="0" selected>Leave w/out pay</option>
				<%}else{%>
				<option value="0">Leave w/out pay</option>
				<%}%>
								
        <%=dbOP.loadCombo("benefit_index","sub_type"," from hr_benefit_incentive " +
														" join hr_preload_benefit_type on (hr_preload_benefit_type.benefit_type_index = hr_benefit_incentive.benefit_type_index)" +								
														"where is_benefit = 0 and benefit_name = 'leave' " +
														" order by sub_type asc",strTemp, false)%>
      </select></td>
      </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("nature_leave");
			%>
      <td colspan="2" class="fontsize11">
			<div id="sl_variant">
			<select name="nature_leave">
        <option value="">All</option>
				<%for(i = 0; i < astrNatureLeave.length ; i++){
					if(strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrNatureLeave[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrNatureLeave[i]%></option>
        <%}
				}%>
      </select>
			</div>
			</td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td class="fontsize11">&nbsp;</td>
      <td colspan="2" class="fontsize11"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";				
			%>
      <td colspan="3" class="fontsize11"><input type="checkbox" name="view_all" value="1" <%=strTemp%>>
      view all </td>
    </tr>
    <tr> 
      <td height="19" colspan="4"><hr size="1"></td>
    </tr>
  </table>
	</td>
  </tr>
  <tr>
    <td><table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%" class="fontsize11">Sort by</td>
      <td width="25%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=rptLeave.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=rptLeave.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="40%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=rptLeave.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table></td>
  </tr>
</table>
	<%
 	if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
		<tr>
			<td align="right"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"><font size="1"></font></a>click to print</td>
        </tr>
<%		
	if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/rptLeave.defSearchSize;		
	if(iSearchResult % rptLeave.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
		<tr>
		  <td align="right"><font size="2">Jump To page:
          <select name="jumpto" onChange="SearchEmployee();">
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
		  </font></td>
	  </tr>
		<%}
		}%>
      </table></td>
		</tr>    
	</table>
	<% 
	for (i = 0 ; i < vRetResult.size() ; i+=14) {
		vEmpLeaves = (Vector)vRetResult.elementAt(i+10);
		dTotalLeave = 0d;
	%>
	<%if(i > 0){%>
	<DIV style="page-break-before:always">&nbsp;</DIV>
	<%}%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<% 
	if (lUserIndex == null || !lUserIndex.equals((Long)vRetResult.elementAt(i))){
		lUserIndex = (Long)vRetResult.elementAt(i);
		
	if(vEmpLeaves != null && vEmpLeaves.size() > 0){
	%>
  <tr>
    <td>		
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
		<tr>
		  <td height="54" colspan="2" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
		</tr>
		<tr> 
			<td width="50%" height="21" class="thinborderBOTTOM">EMPLOYEE ID :<%=(String)vRetResult.elementAt(i+1)%> </td>
		  <td width="50%" class="thinborderBOTTOM">EMPLOYEE NAME : <%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4), 4 )%></td>
		</tr>
		</table>
		
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
		<tr> 
			<td height="12" colspan="4" align="center" class="thinborder"><strong>DURATION</strong></td>
			<td width="38%" rowspan="2" align="center" class="thinborder"><strong>REASON</strong></td>
			<td width="14%" rowspan="2" align="center" class="thinborder"><strong>NATURE</strong></td>
			<td width="16%" rowspan="2" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong class="thinborderBOTTOMLEFTRIGHT">REMARKS</strong></td>
		</tr>
		<tr>
			<td width="9%" height="13" align="center" class="thinborder"><strong>FROM</strong></td>
			<td width="9%" align="center" class="thinborder"><strong>TO</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>HRS</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>MIN</strong></td>
		</tr>
		<%
		strSem = null;
		for(iLeaves = 0; iLeaves < vEmpLeaves.size(); iLeaves+=21){
			if(strSem == null || !strSem.equals((String)vEmpLeaves.elementAt(iLeaves+14))){
				dTotalLeave = 0d;		
		%>
		<tr> 
		 <td height="25" colspan="7" align="center" class="thinborderBOTTOMLEFTRIGHT">
	&nbsp;<strong><%=(String)vEmpLeaves.elementAt(iLeaves+14)%></strong></td>
		</tr>
		<%}%>
		<tr> 
		 <td height="25" class="thinborder">&nbsp;&nbsp;<%=(String)vEmpLeaves.elementAt(iLeaves)%></td>
		 <td height="25" class="thinborder"><%=WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+4),"&nbsp;")%></td>
		 <%
		 	strTemp = WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+17),"0");
			dDuration = Double.parseDouble(strTemp);
			if(dDuration == 0d){
				strTemp = WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+18),"0");
				dDuration = Double.parseDouble(strTemp);			
			}
			
			dHour = (int)dDuration; 
			strTemp = CommonUtil.formatFloat((dDuration  - dHour) * 60, false);
			dTotalLeave += dDuration;
		 %>
		 <td height="25" align="right" class="thinborder"><%=CommonUtil.formatFloat(dHour, false)%>&nbsp;</td>
		 <td height="25" align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		 <td class="thinborder">&nbsp;<%=(String)vEmpLeaves.elementAt(iLeaves+10)%> </td>
		 <%
 		 strTemp2 = (String)vEmpLeaves.elementAt(iLeaves+11);
		 if(strTemp2 != null)
			 strTemp2 = astrNature[Integer.parseInt(strTemp2)];
			
		 strTemp = WI.getStrValue(strTemp2, (String)vEmpLeaves.elementAt(iLeaves+12));		 
		 strTemp = WI.getStrValue(strTemp, "&nbsp;");
		 %>
		 <td class="thinborder">&nbsp;<%=strTemp%></td>
		 <td class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+16),"&nbsp;")%> </td>
		</tr>
		<%
		if((strSem != null && !strSem.equals((String)vEmpLeaves.elementAt(iLeaves+14)))
				|| (iLeaves + 22) > vEmpLeaves.size()){%>
		<tr>
		  <td height="25" colspan="2" align="right">semester total: </td>
			<%			
			dHour = (int)dTotalLeave;
 			dMin = (int)((dTotalLeave - dHour) * 60);
			%>
		  <td height="25" align="right"><%=CommonUtil.formatFloat(dHour, false)%>&nbsp;</td>
		  <td height="25" align="right"><%=CommonUtil.formatFloat(dMin, false)%>&nbsp;</td>
		  <td colspan="3">&nbsp;</td>
		  </tr>
		<%}%>
		<%
		strSem = (String)vEmpLeaves.elementAt(iLeaves+14);
		}%>
	</table>
		
		</td>
  </tr>
	<%} // end if(vEmpLeaves != null && vEmpLeaves.size() > 0)%>
	<%}%> 			
	</table>
	 <%} // end for loop %>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="cur_leave_text" value="<%=WI.fillTextValue("cur_leave_text")%>">
	<input type="hidden" name="per_college" value="1">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
