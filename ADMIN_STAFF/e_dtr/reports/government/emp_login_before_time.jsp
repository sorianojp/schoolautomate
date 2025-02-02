<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn" %>
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
<title>Login Tracking (per Day)</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
 
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.dtr_op.print_pg.value="1";
	document.dtr_op.submit();
}

function ReloadPage()
{
	document.dtr_op.print_pg.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value ="0";
	document.dtr_op.submit();
}

 
function ViewRecords()
{
	document.dtr_op.print_pg.value="";
	document.dtr_op.reloadpage.value="1";
	document.dtr_op.viewRecords.value="1";
	document.dtr_op.submit();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.id_number.value;
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
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.dtr_op.id_number.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function ToggleFields(){
	var vOption = document.dtr_op.show_option.selectedIndex;
	if(vOption == 1){
		document.dtr_op.hour_to.disabled = false;
		document.dtr_op.minute_to.disabled = false;
		document.dtr_op.am_pm_to.disabled = false;
	}else{
		document.dtr_op.hour_to.disabled = true;
		document.dtr_op.minute_to.disabled = true;
		document.dtr_op.am_pm_to.disabled = true;	
	}	
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="ToggleFields();">
<%
if( request.getParameter("print_pg") != null && request.getParameter("print_pg").equals("1"))
{ %>
	<jsp:forward page="./emp_login_before_time_print.jsp" />
<%}
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = new Vector();
	String strTemp2 = null;
	String strTemp3 = null;
	String strTemp4 = null;
	int iSearchResult =0;
	boolean bolHasTeam = false;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Login Tracking(per day)",
								"emp_login_before_time.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");							
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"emp_login_before_time.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
	int i = 0;
	int iIndexOf = 0;
	int iPageCount =  1;
	int iJumpTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("jumpto"),"1"));
	int iRowCount = rptExtn.defSearchSize;
	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	if(bolIsSchool)
		 strTemp = "College";
	else
		 strTemp = "Division";
	String[] astrSortByName    = {strTemp, "Department","Firstname","Lastname", "Undertime"};
	String[] astrSortByVal     = {"c_code","d_code","fname","lname","count_"};


	String[] astrMonth={" &nbsp", "January", "February", "March", "April", "May", "June", "July",
					"August", "September","October", "November", "December"};
	String[] astrOption = {"Before specified time", "Between specified times", "After specified time"};
	
	String strMonths = WI.fillTextValue("month_of");
	if(strMonths.length() == 0 && WI.fillTextValue("date_fr").length() == 0){
		strTemp = WI.getTodaysDate(1);
		iIndexOf = strTemp.indexOf("/");
		if(iIndexOf != -1)
			strMonths = strTemp.substring(0,iIndexOf);
 	}

if (WI.fillTextValue("viewRecords").equals("1")) {
	vRetResult = rptExtn.generateLoginBeforeSpecified(dbOP);
	if (vRetResult == null) 
		strErrMsg = rptExtn.getErrMsg();
	else 
		iSearchResult = vRetResult.size()/14;
	
	iPageCount = iSearchResult/rptExtn.defSearchSize;
	if(iSearchResult % rptExtn.defSearchSize > 0) ++iPageCount;		
	if(iJumpTo > iPageCount)
		iJumpTo = iPageCount;
}

String strSchCode = dbOP.getSchoolIndex();
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

String strCurDate = null;
%>
<form action="./emp_login_before_time.jsp" name="dtr_op" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        EMPLOYEE  LOGIN TRACKING ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
			<%
				if(WI.fillTextValue("is_pit").length() == 0)
					strTemp = "./login_tracking_main.jsp";
				else
					strTemp = "./gov_reports_main.jsp";
			%>
      <td height="25" ><strong>&nbsp;<a href="<%=strTemp%>"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;<%=WI.getStrValue(strErrMsg,"<font color=\"#FF0000\" size=\"3\"><strong>","</strong></font>","")%></strong></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
      <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Date &nbsp;&nbsp;&nbsp;&nbsp;:: 
        &nbsp;From: 
        <input name="date_fr" type="text" size="12" class="textbox"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_fr")%>">
          <a href="javascript:show_calendar('dtr_op.date_fr');" title="Click to select date" 
		  onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To : 
          <input name="date_to" type="text"  size="12" class="textbox" 
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>">
          <a href="javascript:show_calendar('dtr_op.date_to');" title="Click to select date" 
		  onmouseover="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
		  <img src="../../../../images/calendar_new.gif" border="0"></a></td>
  </tr>
</table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#FFFFFF"> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="26">&nbsp; </td>
      <td height="25"> Month and Year</td>
      <td width="590" height="25">
			<select name="month_of">
      <option value="">&nbsp;</option>
			<%
	  int iDefMonth = Integer.parseInt(WI.getStrValue(strMonths,"0"));
	  	for (i = 1; i <= 12; ++i) {
	  		if (iDefMonth == i)
				strTemp = " selected";
			else
				strTemp = "";
	   %>
      <option value="<%=i%>" <%=strTemp%>><%=astrMonth[i]%></option>
      <%} // end for lop%>
     </select>
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"), 2, 1)%>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25">Employee ID</td>
      <td height="25"><select name="id_number_con">
          <%=rptExtn.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select><input name="id_number" type="text" size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("id_number")%>" onKeyUp="AjaxMapName();"><label id="coa_info"></label></td>
    </tr>
		 <%if(strSchCode.startsWith("AUF")){%>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25">Employment Category </td>
      <td height="25"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
				strTemp = WI.fillTextValue("emp_type_catg");
				for(i = 0;i < astrCategory.length;i++){
					if(strTemp.equals(Integer.toString(i))) {%>
        <option value="<%=i%>" selected><%=astrCategory[i]%></option>
        <%}else{%>
        <option value="<%=i%>"> <%=astrCategory[i]%></option>
        <%}
							}%>
      </select></td>
    </tr>
		<%}%>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp; </td>
      <td height="25">Position</td>
      <td height="25"><strong> 
        <%strTemp2 = WI.fillTextValue("emp_type");%>
        <select name="emp_type">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
					WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
					" order by EMP_TYPE_NAME asc", strTemp2, false)%> 
        </select>
        </strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="24"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="24"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
		strTemp = WI.fillTextValue("c_index");
		if (strTemp.length()<1) strTemp="0";
	   if(strTemp.compareTo("0") ==0)
		   strTemp2 = "Offices";
	   else
		   strTemp2 = "Department";
	%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25"> <select name="d_index">
          <% if(strTemp.compareTo("") ==0){//only if from non college.%>
          <option value="">All</option>
          <%}else{%>
          <option value="">All</option>
          <%} strTemp3 = WI.fillTextValue("d_index");%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and c_index="+strTemp+" order by d_name asc",strTemp3, false)%> </select> </td>
    </tr>
    <%if(bolHasTeam){%>
		<tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>		
    <tr bgcolor="#FFFFFF"> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td width="1%">&nbsp;</td>
      <td height="25" colspan="5"><strong>OPTION</strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_option");
			%>
      <td height="25" colspan="5">Show login
        <select name="show_option" onChange="ToggleFields();">
        <%
				for (i = 0; i < astrOption.length; ++i) {
					if (strTemp.equals(Integer.toString(i))){
				%>
        <option value="<%=i%>" selected><%=astrOption[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrOption[i]%></option>
        <%}%>
        <%} // end for lop%>
      </select></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("hour");
				if(strTemp.length() == 0)
					strTemp = "12";				
			%>
      <td height="25" colspan="5">TIME :
        <input name="hour" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
			<%
				strTemp = WI.fillTextValue("minute");
				if(strTemp.length() == 0)
					strTemp = "30";				
			%>
  <input name="minute" type="text" size="2" maxlength="2" 
		value="<%=strTemp%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
			<% 
				strTemp = WI.fillTextValue("am_pm");
				if(strTemp.length() == 0)
					strTemp = "1";
			%>
			<select name="am_pm">
				<option value="0" >A.M.</option>
				<%	if (strTemp.equals("1")){ %>
				<option value="1" selected>P.M.</option>
				<%}else{%>
				<option value="1">P.M.</option>
				<%}%>
			</select> 
			<%
				strTemp = WI.fillTextValue("hour_to");
				if(strTemp.length() == 0)
					strTemp = "12";				
			%> 
			- 
			<input name="hour_to" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
:
<%
				strTemp = WI.fillTextValue("minute_to");
				if(strTemp.length() == 0)
					strTemp = "30";				
			%>
<input name="minute_to" type="text" size="2" maxlength="2" 
		value="<%=strTemp%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  	onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
<% 
				strTemp = WI.fillTextValue("am_pm_to");
				if(strTemp.length() == 0)
					strTemp = "1";
			%>
<select name="am_pm_to">
  <option value="0" >A.M.</option>
  <%	if (strTemp.equals("1")){ %>
  <option value="1" selected>P.M.</option>
  <%}else{%>
  <option value="1">P.M.</option>
  <%}%>
</select></td>
    </tr>
    
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="24" colspan="5">
				<%
					strTemp = WI.fillTextValue("schedule");
					if(strTemp.equals("0"))
						strTemp2 = "checked ";
					else
						strTemp2 = "";
				%>
				<input type="radio" name="schedule" value="0" <%=strTemp2%>>
				check in the first login set
				<%
					if(strTemp2.length() == 0)
						strTemp2 = "checked ";
					else
						strTemp2 = "";
				%>
				<input type="radio" name="schedule" value="1" <%=strTemp2%>>
				check in the second login set</td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="27" colspan="5">
				<%
					strTemp = WI.fillTextValue("order_by");
					if(strTemp.equals("0"))
						strTemp2 = "checked ";
					else
						strTemp2 = "";
				%>
        <input type="radio" name="order_by" value="0" <%=strTemp2%>>
        Order by last name per day 
        <%
					if(strTemp2.length() == 0)
						strTemp2 = "checked ";
					else
						strTemp2 = "";
				%>
        <input type="radio" name="order_by" value="1" <%=strTemp2%>>
        Order by time in</td>
    </tr>
    
    <tr bgcolor="#FFFFFF">
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td>&nbsp;</td>
      <td width="3%" height="25">&nbsp;</td>
      <td width="96%" height="25" colspan="4"><a href="javascript:ViewRecords()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<% 
	if (vRetResult !=null && vRetResult.size()> 0){
	if (iPageCount > 1){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="40%">&nbsp;</td>
			<td width="60%" align="right">&nbsp;
        <% if (!WI.fillTextValue("show_all").equals("1")) {%>
			Jump To page:
			<select name="jumpto" onChange="ViewRecords();">
				<%
				strTemp = request.getParameter("jumpto");
				if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
				for(i =1; i<= iPageCount; ++i){
				if(i == Integer.parseInt(strTemp)){%>
				<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}
				} // end for loop%>
			</select>
			<%}%>
			</td>
		</tr>
	</table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="right"><font size="2">Number of Employees / rows Per 
        Page :</font><font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="10%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
        ID</font></strong></td>
      <td width="30%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
        NAME</font></strong></td>
      <td width="33%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">TIME IN </font></strong></td>
    </tr>
    <% i = (rptExtn.defSearchSize*14*(iJumpTo-1));
		for(; i < vRetResult.size() && iRowCount > 0; i +=14, iRowCount--){%>
    <%if(strCurDate == null || !((String)vRetResult.elementAt(i + 10)).equals(strCurDate)){
			strCurDate = (String)vRetResult.elementAt(i + 10);
		%>
		<tr>
      <td height="25" colspan="5" class="thinborder"><strong>DATE : <%=strCurDate%></strong></td>
    </tr>
		<%}%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder">&nbsp; 
	  <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 7) != null) {
	  		if(vRetResult.elementAt(i + 8) != null) {
				strTemp = (String)vRetResult.elementAt(i + 7) + " / "  + (String)vRetResult.elementAt(i + 8);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 7);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 8) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 8);
			}
	  %><%=strTemp%>      </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i + 9)%>&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;</td>
    </tr>
   <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type=hidden name="reloadpage" value="<%=WI.fillTextValue("reloadpage")%>">
  <input type=hidden name="viewRecords" value="0">
  <input type="hidden" name="show_only_total" value="1">
	<input type="hidden" name="is_pit" value="<%=WI.fillTextValue("is_pit")%>">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>