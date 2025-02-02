<%@ page language="java" import="utility.*,java.util.Vector, eDTR.OverTime,
																 eDTR.eDTRUtil, payroll.PReDTRME"%>
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
function SaveData(){
	document.dtr_op.print_page.value = "";
	document.dtr_op.page_action.value = "1";	
	document.dtr_op.viewAll.value=1;
	document.dtr_op.submit();
}

function ViewRecords(){
	document.dtr_op.print_page.value = "";
	document.dtr_op.viewAll.value=1;
	document.dtr_op.submit();
}

function DeleteRecord(){
	document.dtr_op.print_page.value = "";
	document.dtr_op.page_action.value = "0";	
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

function checkAllSave() {
	var maxDisp = document.dtr_op.emp_count.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
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
	
//add security here
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Statistics & Reports-Summary of OT Rendered","ot_leave_crediting.jsp");
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
											request.getRemoteAddr(),"ot_leave_crediting.jsp");

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

OverTime ot = new eDTR.OverTime();
String strMonth = null;
String strYear = null;
Vector vRetResult = null;
Vector vUserOT = null;
int iOtTypeCount = 0;
int j = 0;
int iIndexOf = 0;
Long lIndex = null;
double dTemp = 0d;
String strPageAction = WI.fillTextValue("page_action");

if(strPageAction.length() > 0){
	if(ot.operateOnOTCrediting(dbOP, request, Integer.parseInt(strPageAction)) == null)
		strErrMsg = ot.getErrMsg();
	else
		strErrMsg = "Operation Successful";	
}
//dbOP.executeUpdateWithTrans("alter table edtr_ot_detail add IS_USED tinyint not null default 0 ", null, null, false);

if (WI.fillTextValue("viewAll").equals("1")){
	vRetResult = ot.operateOnOTCrediting(dbOP, request, 4);
	if (vRetResult == null)
		strErrMsg =  ot.getErrMsg();
	else
		iSearchResult = ot.getSearchCount();
}
vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<form action="./ot_leave_crediting.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        COMPENSATORY LEAVE CREDIT PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25" colspan="2">&nbsp;<strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr>
      <td>&nbsp;</td>
      <td height="25">Forward to Leave : </td>
			<%
				strTemp = WI.fillTextValue("leave_ben_index");
			%>			
      <td height="25"><select name="leave_ben_index">
        <%=dbOP.loadCombo("benefit_index","sub_type"," from  hr_benefit_incentive where is_valid = 1" +
						 " and exists(select * from edtr_leave_usage where is_valid = 1 and purpose = 1" +
						 "    and hr_benefit_incentive.benefit_index = edtr_leave_usage.benefit_index) ",strTemp,false)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="19%" height="25">Month / Year </td>
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
        <input type="checkbox" name="is_weekly" value="1" <%=strTemp%> onClick="ViewRecords();">
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
      <td height="24"><select name="emp_type_catg" onChange="ViewRecords();">
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
      <td height="32">Department/Office</td>
      <td height="32">
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
      </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="12" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
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
    <td height="22" colspan="5" bgcolor="#FFFFFF"><strong>OPTION</strong></td>
    </tr>
  <tr>
    <td height="22" bgcolor="#FFFFFF">&nbsp;</td>
    <td height="22" colspan="4" bgcolor="#FFFFFF"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
      <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ViewRecords();">
View with encoded hours
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ViewRecords();">
View Employees w/out encoded hours </td>
    </tr>
  <tr>
    <td height="22" bgcolor="#FFFFFF">&nbsp;</td>
	  <%
			strTemp = WI.fillTextValue("show_all");
			if (strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = ""; 
		%>
    <td height="22" colspan="4" bgcolor="#FFFFFF"><input type="checkbox" name="show_all" value="1" <%=strTemp%>>
check to show all result</td>
    </tr>
  <tr>
    <td  width="2%" bgcolor="#FFFFFF">&nbsp;</td>
    <td  width="8%" bgcolor="#FFFFFF"><strong>Sort By </strong></td>
    <td width="30%" bgcolor="#FFFFFF"><select name="sort_by1">
      <option value="" selected>N/A</option>
      <%=ot.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
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
    <td width="30%" bgcolor="#FFFFFF"><select name="sort_by2">
      <option value="">N/A</option>
      <%=ot.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
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
    <td width="30%" bgcolor="#FFFFFF"><select name="sort_by3">
      <option value="">N/A</option>
      <%=ot.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
    <td bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
</table>
<% if (vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td colspan="2" align="right">&nbsp;</td>
    </tr>
  <tr>
    <td><b>Total Requests: <%=iSearchResult%> 
	  <%if(strTemp.length() == 0){%>- Showing(<%=ot.getDisplayRange()%>) <%}%></b></td>
    <td width="33%" colspan="-2" align="right">
	<% 
	if(WI.fillTextValue("show_all").length() == 0){
	int iPageCount = iSearchResult/ot.defSearchSize;
	if(iSearchResult % ot.defSearchSize > 0) ++iPageCount;
	if (strTemp.length() == 0 && iPageCount > 1) {%> 
	Jump To page:
      <select name="jumpto" onChange="ViewRecords();">
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
	}%>		</td>
  </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr bgcolor="#F4FBF5">
    <td height="25" colspan="6" align="right">
		<font size="2">Number of Employees / rows Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></td>
  </tr>
  <tr bgcolor="#F4FBF5">
    <td height="25" colspan="6" align="center"><font color="#000000"><strong>LIST OF OVERTIME RENDERED</strong></font></td>
  </tr>
  <tr>
    <td colspan="6"><table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
      <tr>
        <td width="10%" align="center" class="thinborder" height="26">&nbsp;</td>
				<td width="35%" align="center" class="thinborder"><strong>Employee name</strong></td>
				<td width="32%" align="center" class="thinborder"><strong>Department / Office</strong></td>        
        <td width="13%" align="center" class="thinborder"><strong>Total Hours</strong></td>
        <td width="10%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
            <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
        </font></td>
      </tr>
      <%
			int iCtr = 0;
			int iCount = 1;
			String strIndexes = null;
			for (i=0 ; i < vRetResult.size(); i+=20,iCount++){ 
				vUserOT = (Vector)vRetResult.elementAt(i+11);
				strIndexes = WI.getStrValue((String) vRetResult.elementAt(i+15), "0");
			%>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="hidden" name="ot_indexes_<%=iCount%>" value="<%=strIndexes%>">			
			<input type="hidden" name="coc_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+16)%>">
      <tr>
				<%
					strTemp = (String)vRetResult.elementAt(i+1);
				%>
        <td nowrap class="thinborder">&nbsp;<%=strTemp%></td>
        <%
						strTemp = WI.formatName((String)vRetResult.elementAt(i+2), 
											(String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), 4);
				%>
        <td nowrap class="thinborder">&nbsp;<%=strTemp%></td>
				<%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
						strTemp = " ";			
					}else{
						strTemp = " - ";
					}
				%>				
        <td height="19" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
				<%
					strTemp = (String)vRetResult.elementAt(i + 14);
				%>				
				<td align="right" class="thinborder"><input type="textbox" name="ot_hour_<%=iCount%>" value="<%=strTemp%>"
				 class="textbox_noborder" readonly size="8" maxlength="8" style="text-align:right">&nbsp;</td>
        <td align="center" class="thinborder">
				<%if(((String)vRetResult.elementAt(i + 12)).equals("1")){%>
				<input type="hidden" name="save_<%=iCount%>">n/a	
			  <%}else{%>			
				<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">
				<%}%>
				</td>
      </tr>
      <%}%>
			<input type="hidden" name="emp_count" value="<%=iCount%>">
    </table></td>
  </tr>
  <tr>
    <td colspan="6" align="right">&nbsp;</td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  
  <tr>
    <td width="100%" colspan="2" align="center">
			<%if(iAccessLevel > 1 && WI.fillTextValue("with_schedule").equals("0")){%>
      <!--
				<a href='javascript:SaveData();'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
				-->
      <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:SaveData();">
      <font size="1"> click to save entries</font>
      <%}%>
			<%if((WI.fillTextValue("with_schedule")).equals("1") && iAccessLevel == 2){%>
      <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:DeleteRecord();">
      <font size="1">Click to delete selected </font>
      <%}%>

      <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelRecord();">
      <font size="1"> click to cancel or go previous</font>
      </td>
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
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>