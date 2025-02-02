<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAllowances, payroll.PayrollConfig" buffer="16kb"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
WebInterface WI = new WebInterface(request);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchEmployee(){
	if(document.form_.cola_ecola_index.selectedIndex == -1){
		this.SubmitOnce("form_");
		return;
	}
	document.form_.allowance_name.value = document.form_.cola_ecola_index[document.form_.cola_ecola_index.selectedIndex].text;
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value="";
 	//document.form_.submit();
	this.SubmitOnce("form_");
}

function ReloadPage(){	
	//document.form_.page_reloaded.value = "1";
	//document.form_.searchEmployee_.value="";
	//document.form_.print_page.value="";	
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(){
  var vProceed = confirm('Remove selected records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee_.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./variable_allowance_set.jsp";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

function CopyRate(strBase){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		if(strBase == '0'){
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.monthly_'+i+'.value=document.form_.monthly_1.value');			
		}else if(strBase == '1'){
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.daily_'+i+'.value=document.form_.daily_1.value');					
		}else{
			for (var i = 1 ; i < eval(vItems);++i)
				eval('document.form_.hourly_'+i+'.value=document.form_.hourly_1.value');		
		}
		
}

-->
</script>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strAllowanceName = WI.fillTextValue("allowance_name");
	boolean bolAllowOverride = false;
	boolean bolCheckDate = true;//-- change to true alwasy to show the date range by default.. false;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="variable_allowance_set_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Variable Allowance-Variable Allowance Management","variable_allowance_set.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolAllowOverride = (readPropFile.getImageFileExtn("ALLOWANCE_OVERRIDE","0")).equals("1");
		//commented to make sure check date is always true .. 
		//bolCheckDate = (readPropFile.getImageFileExtn("CHECK_ALLOWANCES_DATE","0")).equals("1");
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

//end of authenticaion code.
	Vector vRetResult = null;
	Vector vAllowanceInfo = null;
	
	PRAllowances prAllow = new PRAllowances();
	PayrollConfig pr = new PayrollConfig();
	String strTxtClass = "textbox_noborder";
	if(bolAllowOverride)
		strTxtClass = "textbox";
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) 
		strSchCode = "";
	
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");
	String strTemp2 = null;
	String strEmpCatg = null;
	String[] astrCategory = {"Staff","Faculty","Employees"};
	String[] astrStatus = {"Part-Time","Full-Time","Contractual",""};
	String[] astrCondition = {"between","more than","less than","equal to"};
	String strCurSem = (String) request.getSession(false).getAttribute("cur_sem");
	String strCurSYFr = (String) request.getSession(false).getAttribute("cur_sch_yr_from");
	String strCurSYto = (String) request.getSession(false).getAttribute("cur_sch_yr_to");
	if(bolIsSchool)
		strTemp2 = "College";
	else
		strTemp2 = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname",strTemp2,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","c_name","d_name"};
	
	String[] astrBasis={"Fixed Allowance","Present","Absences", "Hours Present"};

	String[] astrActualName ={"Every Salary Period","Monthly (Every Last Period of the Month)", 
												"Quarterly (Every Last Period of the Quarter)",
												"Bi-annual (June &amp; December)","Monthly (Every First Period)"};
	
	
	
	String strHourCon = null;
	String strLoadCon = null;
	String strRateCon = null;
	boolean bolHasItems = false;
	int iCount = 1;
	int i = 0;
	int iSearchResult = 0;
	boolean bolFixed = false;
	String strMonthly = null;
	String strDaily = null;
	String strHourly = null;
	String strReleaseSched = null;
	
	vAllowanceInfo = pr.operateOnColaEcola(dbOP,request,3, WI.fillTextValue("cola_ecola_index"));
	if(vAllowanceInfo != null){
	
		strAllowanceName = (String)vAllowanceInfo.elementAt(6);
		strAllowanceName += WI.getStrValue((String)vAllowanceInfo.elementAt(7)," (",")","");						
		bolFixed = WI.getStrValue((String)vAllowanceInfo.elementAt(5),"0").equals("0");
		strMonthly =  WI.getStrValue((String)vAllowanceInfo.elementAt(3),"");
		strDaily =  WI.getStrValue((String)vAllowanceInfo.elementAt(4),"");
		strHourly =  WI.getStrValue((String)vAllowanceInfo.elementAt(10),"");
	}

	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (prAllow.operateOnAllowances(dbOP,request,0) != null){
				strErrMsg = " Allowance removed successfully ";
			}else{
				strErrMsg = prAllow.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (prAllow.operateOnAllowances(dbOP,request,1) != null){
				strErrMsg = " Allowance posted successfully ";
			}else{
				strErrMsg = prAllow.getErrMsg();
			}
		}
	}
	
	if(WI.fillTextValue("searchEmployee_").length() > 0){
		
		vRetResult = prAllow.operateOnAllowances(dbOP,request,4);
		
		if (vRetResult == null){
			strErrMsg = prAllow.getErrMsg();	
		}else{
			iSearchResult = prAllow.getSearchCount();
		}
	}		
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./variable_allowance_set.jsp" name="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: VARIABLE ALLOWANCE IMPLEMENTATION PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font size="1"><a href="./variable_allowance_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="21%">Allowance name </td>
	  <%
		  	strTemp = WI.fillTextValue("cola_ecola_index");
	  %>
      <td width="74%" colspan="3">
			<select name="cola_ecola_index" onChange="ReloadPage();">
        <%=dbOP.loadCombo("cola_ecola_index","allowance_name, sub_type", 
					" from pr_cola_ecola where is_valid = 1 and is_del = 0 and is_cola = 0 " +
					" order by allowance_name, sub_type", 
					strTemp, false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
			<%
				strTemp2 = "";
				strTemp = "";
				if(vAllowanceInfo != null && vAllowanceInfo.size() > 0){					
					strReleaseSched = WI.getStrValue((String)vAllowanceInfo.elementAt(5),"0");	
					if(strReleaseSched.equals("0")){
						strTemp2 = WI.getStrValue((String)vAllowanceInfo.elementAt(12),"0");
						strTemp2 = astrActualName[Integer.parseInt(strTemp2)];									
					}
 
 					strTemp2 = WI.getStrValue(strTemp2,"<br>- ","","");
						
					if(((String)vAllowanceInfo.elementAt(13)).equals("1"))
						strTemp2 += "<br>- Added to Basic";
						
					strTemp = astrBasis[Integer.parseInt(strReleaseSched)] + strTemp2;
				}
			%>			
      <td colspan="3">&nbsp;<%=strTemp%></td>
    </tr>
    <tr>
      <td colspan="5" height="10"><hr size="1" color="#000000"></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee ID </td>
			<%
				strTemp = WI.fillTextValue("emp_id");
			%>
      <td colspan="3"><input name="emp_id" type="text" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>" size="16" maxlength="16"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>
			<label id="coa_info"></label></td>
   </tr>
	 <%if(bolIsSchool){%>
   <tr>
      <td height="24">&nbsp;</td>
      <td>Subject allowance </td>
			<%
				strTemp = WI.fillTextValue("sub_index");
			%>
      <td colspan="3"><select name="sub_index">
        <option value="">Select Subject</option>
        <%=dbOP.loadCombo("subject.sub_index","sub_code",
				" from e_sub_section join subject on (e_sub_section.sub_index = subject.sub_index) " +
			  " join curriculum on (e_sub_section.cur_index = curriculum.cur_index) " +
				" where offering_sy_from = " + strCurSYFr + " and offering_sy_to = " + strCurSYto + 
				" and offering_sem = " + strCurSem + " and e_sub_section.is_del = 0 " +
				" and curriculum.is_del = 0 and (subject.is_del = 0 or subject.is_del = 2) " +
				" group by sub_code, subject.sub_index, subject.is_del " +
				" order by subject.is_del asc, sub_code asc", strTemp , false)%>
      </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
	  <%
		strTemp = WI.fillTextValue("pt_ft");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  
      <td colspan="3"><select name="pt_ft">
          <option value="">ALL</option>
		  <%if (strTemp.equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if (strTemp.equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = null;
	strCollegeIndex = WI.fillTextValue("c_index");
	strCollegeIndex = WI.getStrValue(strCollegeIndex);
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
	  <%
	 	strTemp = WI.fillTextValue("employee_category");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  	  
      <td colspan="3">
	    <select name="employee_category">
          <option value="">ALL</option>
          <%if (strTemp.equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}else if (strTemp.equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}%>
		</select> </td>
    </tr>
	<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
	  <%
		  strTemp = WI.fillTextValue("d_index");
	  %>	  	  	  
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%> 
          <%}%>
        </select> 
			</label>			</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Period Name </td>
      <td colspan="3"><select name="period_index">
        <option value="">Select Period Name</option>
        <%=dbOP.loadCombo("PERIOD_INDEX","PERIOD_NAME", " from pr_preload_period order by period_name",strTemp,false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
<%if(strSchCode.startsWith("DLSHSI")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Group Processor </td>
      <td colspan="3">
	  <select name="group_index"  onChange="ReloadPage();">
        <option value="">--- All --- </option>
<%
strTemp =  WI.fillTextValue("group_index");
if(strTemp.equals("-1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
       <option value="-1"<%=strErrMsg%>>Show employees do not belong to any group</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group order by group_name", strTemp, false)%>
      </select>
	  
	  </td>
    </tr>
<%}%>    
    <tr>
      <td height="11" colspan="5"><hr size="1"></td>
    </tr>
		<%if(vAllowanceInfo != null && vAllowanceInfo.size() > 0){%>
    
		<%}%>
    <tr>
      <td height="11" colspan="5">OPTION:</td>
    </tr>
    <tr>
      <td height="11" colspan="5"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
        View with  allowance
        <%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
	<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View all Employees</td>
    </tr>
    <tr>
      <td height="24" colspan="5"><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%>>View ALL</td>
    </tr>
		<!--
		<%//if(WI.fillTextValue("with_schedule").equals("1")){%>
    <tr>
      <td height="11" colspan="5"><%
	//strTemp = WI.fillTextValue("active");
//	strTemp = WI.getStrValue(strTemp,"1");
	//if(strTemp.compareTo("1") == 0) 
	//	strTemp = " checked";
	//else	
	//	strTemp = "";	
%>
        <input type="radio" name="active" value="1"<%//=strTemp%> onClick="ReloadPage();">
View only active
<%
	//if(strTemp.length() == 0) 
	////	strTemp = " checked";
	///else
	//	strTemp = "";
	%>
<input type="radio" name="active" value="0"<%//=strTemp%> onClick="ReloadPage();">
View all</td>
    </tr>	
		<%//}%>
		-->
  </table>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=prAllow.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=prAllow.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=prAllow.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
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
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
				<!--<input type="image" onClick="SearchEmployee()" src="../../../../images/form_proceed.gif"> -->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="SearchEmployee();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>	
  
 <% if (vRetResult != null) {%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>   
      <% if (vRetResult != null && vRetResult.size() > 0 ){%>
      <td height="10"><div align="right"><font size="2">Number of Employees / rows Per 
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
                  <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/prAllow.defSearchSize;		
	if(iSearchResult % prAllow.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td><div align="right"><font size="2">Jump To page:
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
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	  <%
		strAllowanceName = strAllowanceName.toUpperCase();
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH " + strAllowanceName + " ALLOWANCE";
	  else
	    strTemp = "EMPLOYEES WITHOUT " + strAllowanceName + " ALLOWANCE";
	  %>	
    <tr> 
      <td height="25" colspan="9" align="center" bgcolor="#B9B292"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="3%" height="24" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="9%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE ID </strong></font></td>
      <td width="28%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="24%" align="center" class="thinborderBOTTOMRIGHT"><span class="thinborder"><strong><font size="1"><strong>DEPARTMENT/OFFICE</strong></font></strong></span></td>
 			<td width="8%" align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">MONTHLY<br>
 			  <a href="javascript:CopyRate('0');">Copy</a></font></strong></td>
 			<td width="8%" align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">DAILY</font></strong><br>
		  <strong><font size="1"><a href="javascript:CopyRate('1');">Copy</a></font></strong></td>
 			<td width="8%" align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">HOURLY<br>
		  <a href="javascript:CopyRate('2');">Copy</a></font></strong></td>
 			<td width="6%" align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">EFFECTIVE DATE </font></strong></td>
 			<%
				strTemp = "";
				if(WI.fillTextValue("selAllSave").length() > 0){
					strTemp = " checked";
				}else{
					strTemp = "";
				}
			%>
      <td width="6%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" <%=strTemp%>>
      </font></td>
    </tr>
    <% 
	for (i = 0; i< vRetResult.size() ; i+=15, iCount++) {%>
		<%if(WI.fillTextValue("with_schedule").equals("1")){%>
		<input type="hidden" name="allow_set_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<%}%>
    <tr> 
      <td height="25" align="center" class="thinborderBOTTOMLEFTRIGHT"><span class="thinborderTOPLEFT"><%=iCount%></span></td>
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></span></td>
			<input type="hidden" name="user_id_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>">
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = "";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%> </span></td>
			<%
				strTemp = CommonUtil.formatFloat(strMonthly,true);
				if(WI.fillTextValue("with_schedule").equals("1"))
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 9), strTemp);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
				
				if(bolAllowOverride)
					strTemp2 = "";
				else
					strTemp2 = "readonly";				
			%>
 			<td align="center" class="thinborderBOTTOMRIGHT">
			<input type="text" class="<%=strTxtClass%>" size="8" maxlength="8" name="monthly_<%=iCount%>" 
			value="<%=strTemp%>" style="text-align:right;font-size:11px;"
			onFocus="style.backgroundColor='#D3EBFF'" <%=strTemp2%>
			onBlur="AllowOnlyFloat('form_','monthly_<%=iCount%>');style.backgroundColor='white'"
	    onKeyUp="AllowOnlyFloat('form_','monthly_<%=iCount%>');"></td>
			<%
				strTemp = CommonUtil.formatFloat(strDaily,true);
				if(WI.fillTextValue("with_schedule").equals("1"))
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 10), strTemp);
				strTemp = ConversionTable.replaceString(strTemp, ",","");

				if(bolAllowOverride)
					strTemp2 = "";
				else
					strTemp2 = "readonly";
			%>			
 			<td align="center" class="thinborderBOTTOMRIGHT">
			<input type="text" class="<%=strTxtClass%>" size="8" maxlength="8" name="daily_<%=iCount%>" 
			value="<%=strTemp%>" style="text-align:right;font-size:11px;"
			onFocus="style.backgroundColor='#D3EBFF'" <%=strTemp2%>
			onBlur="AllowOnlyFloat('form_','daily_<%=iCount%>');style.backgroundColor='white'"
	    onKeyUp="AllowOnlyFloat('form_','daily_<%=iCount%>');"></td>
			<%
 				strTemp = strHourly;
				//strTemp = CommonUtil.formatFloat(strHourly, true);
				if(WI.fillTextValue("with_schedule").equals("1"))
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 11), strTemp);	
				strTemp = ConversionTable.replaceString(strTemp, ",","");

				if(bolAllowOverride)
					strTemp2 = "";
				else
					strTemp2 = "readonly";
 			%>			
 			<td align="center" class="thinborderBOTTOMRIGHT">
			<input type="text" class="<%=strTxtClass%>" size="8" maxlength="8" name="hourly_<%=iCount%>" 
			value="<%=strTemp%>" style="text-align:right;font-size:11px;"
			onFocus="style.backgroundColor='#D3EBFF'" <%=strTemp2%>
			onBlur="AllowOnlyFloat('form_','hourly_<%=iCount%>');style.backgroundColor='white'"
	    onKeyUp="AllowOnlyFloat('form_','hourly_<%=iCount%>');"></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+12);
				if(strTemp != null && strTemp.length() > 0){
					strTemp = strTemp + WI.getStrValue((String)vRetResult.elementAt(i+13), "-","","-present");
				}
				strTemp = WI.getStrValue(strTemp, "n/a");
			%>
 			<td align="center" class="thinborderBOTTOMRIGHT"><%=strTemp%></td>
 			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">							
			<td align="center" class="thinborderBOTTOMRIGHT"><input type="checkbox" name="save_<%=iCount%>" value="1">      </td>
    </tr>
    <%}// end for loop%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">		
		<%if(bolCheckDate){// &&  !strReleaseSched.equals("0")  ){ //no need to check release schedule == updated Jan 21, 2015%>
    <tr> 
      <td height="18" colspan="2">  Effective date :
        <input name="date_from" type="text" class="textbox" id="date_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_from")%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" alt="Click to set " border="0"></a> 
        to 
         <input name="date_to" type="text" class="textbox" id="date_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("date_to")%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>&nbsp;
        <%if(WI.fillTextValue("with_schedule").equals("1")){
					strTemp = WI.fillTextValue("include_date");
					if(strTemp.length() > 0)
						strTemp = "checked";
					else
						strTemp = "";
					%>
				<input type="checkbox" name="include_date" value="1" <%=strTemp%>> include changes in effective date
				<%}%>
				<br>
        <strong>Notes :</strong> Leave blank if the allowance will not expire. <br>
        update is only allowed for the amount.</td>
    </tr>
		<%}%>
    <tr>
      <td height="18" colspan="2" align="center">&nbsp;</td>
    </tr>
    <tr> 
      <td height="35" colspan="2" align="center">  
        <% if (iAccessLevel > 1) {%>
 				<!--
				<a href="javascript:AddRecord()"><img src="../../../../images/edit.gif" width="48" height="28"  border="0"></a>
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to edit entries </font> 
				-->
				<!--
				<a href='javascript:DeleteRecord();'><img src="../../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
				-->
        <% if (iAccessLevel == 2 && WI.fillTextValue("with_schedule").equals("1")) {%>
				<input type="button" name="delete" value="Delete" style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
        <font size="1">Click to delete selected</font>
				<%}%>
				<!--<a href="javascript:AddRecord()"><img src="../../../../images/save.gif" width="48" height="28"  border="0"></a>-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to save entries </font> 				
				<%}%>
				<!--
        <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0"></a>
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
				<font size="1">click to cancel entries</font></td>
    </tr>
    <tr> 
      <td width="5%" height="10">&nbsp;</td>
      <td width="95%" height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>	
<%}//end vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_reloaded">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="searchEmployee_"> 
<input type="hidden" name="allowance_name" value="<%=WI.fillTextValue("allowance_name")%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>