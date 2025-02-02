<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn,eDTR.eDTRUtil, payroll.PReDTRME" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Overtime Rendered</title>
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
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.dtr_op.print_page.value = "";
		document.dtr_op.viewAll.value=1;
		document.dtr_op.submit();
	}
	function goToNextSearchPage()
	{
		document.dtr_op.viewAll.value=1;
		document.dtr_op.submit();
	}
	 
	function PrintPg(){
		document.dtr_op.print_page.value = "1";
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

function loadSalPeriods() {
		var strMonth = document.dtr_op.month_of.value;
		var strYear = document.dtr_op.year_of.value;
		var strWeekly = null;
		
		if(document.dtr_op.is_weekly)
			strWeekly = document.dtr_op.is_weekly.value;
		var objCOAInput = document.getElementById("sal_periods");
			
		if(strMonth.length == 0){
			objCOAInput.innerHTML = "";
			return;
		}
		
		
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		// has_all
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&has_all=1&month_of="+strMonth+
								 "&year_of="+strYear+"&is_weekly="+strWeekly;

		this.processRequest(strURL);
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ %>
	<jsp:forward page="./ot_rendered_print.jsp" />
<%}
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	String strHasWeekly = null;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Summary of OT Rendered","ot_rendered.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");		
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
											"eDaily Time Record","STATISTICS & REPORTS",
											request.getRemoteAddr(),"ot_rendered.jsp");

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

String[] astrSortByName    = {"Last Name(Requested for)","Department",strTemp};

String[] astrSortByVal     = {"lname","d_name","c_name"};

String[] astrMonth = {"January", "February","March", "April", "May","June","July",  
						"August", "September", "October", "November", "December"};
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};

int iSearchResult = 0;
Vector vSalaryPeriod 		= null;//detail of salary period.
PReDTRME prEdtrME = new PReDTRME();

ReportEDTRExtn RE = new ReportEDTRExtn(request);
eDTR.OverTime ot = new eDTR.OverTime();
String strMonth = null;
String strYear = null;
Vector vRetResult = null;
Vector vOtTypes = new Vector();
Vector vUserOT = null;
int iOtTypeCount = 0;
int j = 0;
int iIndexOf = 0;
Long lIndex = null;
double[] adHours = null;
double[] adAmount = null;
double dTemp = 0d;
double dRegOtHour = 0d;
double dHourlyRate = 0d;
int iWidth = 7;
String strAmount = null;
double dOtRate = 0d;
double dExcessRate = 0d;
double dExcessHr = 0d;

String strRateType = null;
String strExcessType = null;
boolean bolAllowOTCost = false;
String strSQLQuery = 
					"select restrict_index from edtr_restrictions where restriction_type = 1 " +
					" and user_index_ = " + (String)request.getSession(false).getAttribute("userIndex");
strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
//if(strSQLQuery != null)
	bolAllowOTCost = true;

if (WI.fillTextValue("viewAll").equals("1")){

	vRetResult = RE.generateOTRendered(dbOP);
	if (vRetResult == null){
		strErrMsg =  RE.getErrMsg();
	}else{
		vOtTypes = (Vector)vRetResult.remove(0);
		vRetResult.remove(0);// remove dates
		iSearchResult = RE.getSearchCount();
		
		if(vOtTypes != null){
			iOtTypeCount = vOtTypes.size() / 7;
			if(WI.fillTextValue("show_division").length() > 0)
				iWidth = 80/(iOtTypeCount + 1);
			else
				iWidth = 80/ iOtTypeCount;

			adHours = new double[iOtTypeCount];
			adAmount = new double[iOtTypeCount];
		}
	}
}
vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<form action="./ot_rendered.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        OVERTIME REQUEST VIEW PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="2">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="30"></td>
      <td width="19%" height="30">Date Range</td>
      <td height="30">&nbsp;From: 
        <input name="from_date" type="text"  id="from_date3" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>"> 
        <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
        : 
        <input name="to_date" type="text"  id="to_date3" size="12" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>"> 
        <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Month / Year </td>
			<%strTemp = WI.fillTextValue("month_of");%>
      <td width="79%" height="25">
			<select name="month_of" onChange="loadSalPeriods();">
        <option value="">&nbsp;</option>
        <%for (i = 0; i < astrMonth.length; i++) {
			if (strTemp.equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=astrMonth[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrMonth[i]%></option>
        <%}
			}%>
      </select>
         
			
      <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%>
        </select>
        <font size="1">(this option will overwrite the date range encoded above)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Salary Period</td>
      <td height="25"><strong>
        <label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
				 <option value=""> &nbsp;</option>
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
				//strDateFrom = (String)vSalaryPeriod.elementAt(i + 1);
				//strDateTo = (String)vSalaryPeriod.elementAt(i + 2) ;
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
        </label>
      </strong>
        <% 
				if(strHasWeekly.equals("1")){
					strTemp = WI.fillTextValue("is_weekly");
					if(strTemp.compareTo("1") == 0) 
						strTemp = " checked";
					else	
						strTemp = "";
				%>
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ReloadPage();">
        <font size="1">for weekly </font>
        <%}// check if the company has weekly salary type%></td>
    </tr>
    <tr> 
      <td width="2%">&nbsp; </td>
      <td height="25">Employee ID</td>
      <td height="25"><input name="emp_id" type="text"  size="12" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("emp_id")%>" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
    </tr>
    <% if (strSchCode.startsWith("AUF")) {%>
    <tr> 
      <td>&nbsp;</td>
      <td height="24">Employment Catg</td>
			<%
				strTemp = WI.fillTextValue("emp_type_catg");
			%>
      <td height="24"><select name="emp_type_catg" onChange="ReloadPage();">
        <option value="">ALL</option>
        <%
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
    <tr> 
      <td>&nbsp;</td>
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
    <tr> 
      <td>&nbsp;</td>
      <td height="24"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
			%>
      <td height="24"><select name="c_index" onChange="loadDept();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Department/Office</td>
      <td height="25">
			<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> 
				</label>			</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="25">Office/Dept filter<br></td>
      <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
		
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>			</td>
    </tr>
		<%}%>
    <tr> 
      <td height="12" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
		<%if(bolAllowOTCost){%>
		<tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("show_cost");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
      <td bgcolor="#FFFFFF"><input type="checkbox" name="show_cost" value="1" <%=strTemp%>>
      Show OT Costing  </td>
    </tr>
		<%}%>	
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>    
    <tr>
      <td width="17%" height="21" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="83%" bgcolor="#FFFFFF">
			<input name="btn_proceed" type="button" onClick="ViewRecords()" value="Proceed" 
			style="font-size:11px; height:28px;border: 1px solid #FF0000;">      </td>
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
<% if (vRetResult != null){ %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
 <% strTemp = WI.fillTextValue("show_division");
 	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = ""; %>		
    <td colspan="4"><input type="checkbox" name="show_division" value="1" <%=strTemp%>>
    check to show Department/office</td>
	  <%
			strTemp = WI.fillTextValue("show_all");
			if (strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = ""; %>	
    <td colspan=2 align="right"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
check to show all result </td>
  </tr>
  <tr>
    <td colspan="4"><b>Total Requests: <%=iSearchResult%> 
	  <%if(strTemp.length() == 0){%>- Showing(<%=RE.getDisplayRange()%>) <%}%></b></td>
    <td width="26%">&nbsp;</td>
    <td width="31%" align="right">
	<% 
	if(WI.fillTextValue("show_all").length() == 0){
	int iPageCount = iSearchResult/RE.defSearchSize;
	if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
	if (strTemp.length() == 0 && iPageCount > 1) {%> 
	Jump To page:
      <select name="jumpto" onChange="goToNextSearchPage();">
   <% 
	
	
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
	<%}
	}%>	  
		</td>
  </tr>
  <tr bgcolor="#F4FBF5">
    <td height="25" colspan="6" align="center"><font color="#000000"><strong>LIST 
      OF OVERTIME RENDERED
    </strong></font></td>
  </tr>
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <%if(WI.fillTextValue("show_division").length() > 0){%>
				<td align="center" class="thinborder"><strong>Department / Office</strong></td>
				<%}%>
        <td width="19%" height="26" align="center" class="thinborder"><strong>Employee name</strong></td>
				<%for(j = 0; j < vOtTypes.size(); j+=7){%>
				<%
					strTemp = (String)vOtTypes.elementAt(j+1);
				%>
        <td align="center" class="thinborder" width="<%=iWidth/2%>%"><strong><%=strTemp%></strong></td>
				<%if(WI.fillTextValue("show_cost").length() > 0){%>
				<td align="center" class="thinborder" width="<%=iWidth/2%>%"><strong>COST</strong></td>
				<%}%>
				<%}%>
      </tr>
        <%
			int iCtr = 0;
			for (i=0 ; i < vRetResult.size(); i+=20){ 
				vUserOT = (Vector)vRetResult.elementAt(i+11);
				// initialize array
				for(j=0; j < adHours.length;j++)
					adHours[j] = 0d;				

				for(j=0; j < adAmount.length;j++)
					adAmount[j] = 0d;							
		 %>
      <tr>
				<%if(WI.fillTextValue("show_division").length() > 0){%>
				<%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>				
        <td height="19" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
				<%}%>
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);
						strTemp += "<br>(" + (String)vRetResult.elementAt(i+1) + ")";
				%>
        <td nowrap class="thinborder">&nbsp;<%=strTemp%></td>
        <%				
				for(j = 0; j < vOtTypes.size(); j+=7){
					dOtRate = Double.parseDouble((String)vOtTypes.elementAt(j+3));
					strRateType = (String)vOtTypes.elementAt(j+4);					
					
					dExcessRate = Double.parseDouble(WI.getStrValue((String)vOtTypes.elementAt(j+5), "0"));
					strExcessType = WI.getStrValue((String)vOtTypes.elementAt(j+6));
										
					lIndex = (Long)vOtTypes.elementAt(j);
					iIndexOf = vUserOT.indexOf(lIndex);
					while(iIndexOf != -1){
						dExcessHr = 0d;
						iIndexOf = iIndexOf - 3;
						vUserOT.remove(iIndexOf);// 1remove user index
						vUserOT.remove(iIndexOf);// 2date
						dTemp = ((Double)vUserOT.remove(iIndexOf)).doubleValue();// 3remove hours
						vUserOT.remove(iIndexOf);// 4remove otTypeIndex
						dHourlyRate = Double.parseDouble((String)vUserOT.remove(iIndexOf));// 5remove hourly rate
						vUserOT.remove(iIndexOf);// 6 free
						vUserOT.remove(iIndexOf);// 7 free
						
						adHours[j/7] += dTemp;
						
						dRegOtHour = dTemp;
            if (dTemp > 8) {
              dExcessHr = dTemp - 8;
              dRegOtHour = 8;
            }						
						
						if(strExcessType.equals("0")){ // percentage
							adAmount[j/7] += (dExcessRate / 100) * dHourlyRate * dExcessHr;		
						}else{ // specific rate
							adAmount[j/7] += dExcessHr * dHourlyRate;		
						}

						if(strRateType.equals("0")){ // percentage
							dTemp = (dOtRate / 100) * dHourlyRate;
							strTemp = CommonUtil.formatFloat(dTemp, 2);
							strTemp = ConversionTable.replaceString(strTemp, ",","");
							dTemp = Double.parseDouble(strTemp);
						
							adAmount[j/7] += dTemp * dRegOtHour;
						}else if(strRateType.equals("1")){ // specific rate
							adAmount[j/7] += dRegOtHour * dHourlyRate;		
						}else{ // flat rate	
							adAmount[j/7] += dOtRate;		
						}
						
						iIndexOf = vUserOT.indexOf(lIndex);
					}
					
					if(adHours[j/7] > 0d)
						strTemp = CommonUtil.formatFloat(adHours[j/7], false) + " hr(s)";
					else
						strTemp = "-";
						
					if(adAmount[j/7] > 0d)
						strTemp2 = CommonUtil.formatFloat(adAmount[j/7], 2);
					else
						strTemp2 = "-";
				%>
				<td align="right" class="thinborder"><%=strTemp%>  &nbsp;</td>
				<%if(WI.fillTextValue("show_cost").length() > 0){%>
				<td align="right" class="thinborder"><%=strTemp2%></td>
				<%}%>
				<%}%>
      </tr>
      <%}%>
    </table></td>
  </tr>

  <tr>
    <td colspan="6" align="right"><font size="2">Number of Employees / rows Per 
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
        <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
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
	<input type="hidden" name="print_page">
	<input type="hidden" name="viewAll" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>