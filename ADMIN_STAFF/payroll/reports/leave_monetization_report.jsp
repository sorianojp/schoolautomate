<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRLeaveConversion,java.util.Date" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Monetization Report</title>
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
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
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

function PrintPg() {
	document.form_.print_page.value = "1";
	document.bgColor = "#FFFFFF";
	document.getElementById("tr_print_header").style.display = "table-row"; //header
	//document.getElementById("tbl_header").style.bgColor = "#FFFFFF";	
	document.getElementById("footer_tbl").style.backgroundColor = "#FFFFFF";	
	document.getElementById("boddyTag").style.backgroundColor = "#FFFFFF";	
	document.getElementById("table_head").style.backgroundColor = "#FFFFFF";
	document.getElementById('table1').deleteRow(0);
	document.getElementById('table2').deleteRow(0);	
	
		
	var oRows = document.getElementById('seardhTbl').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('seardhTbl').deleteRow(0);
		--iRowCount;
	}
	
	oRows = document.getElementById('filter_tbl').getElementsByTagName('tr');
	iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('filter_tbl').deleteRow(0);
		--iRowCount;
	}	
	alert("Click OK to print this page");	
	window.print();
}

function DeleteRecord(){
  var vProceed = confirm('Remove selected records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		this.SubmitOnce("form_");
  }	
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
	//this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
	if(eval(vItems) > 16){
		document.form_.copy_all.value = "1";
		document.form_.print_page.value = "";
		document.form_.searchEmployee.value = "1";		
		this.SubmitOnce('form_');
	}else{
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.conv_days_'+i+'.value=document.form_.conv_days_1.value');			
	}
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;	
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;	
	
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./leave_conversion_batch_print.jsp" />
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Leave Conversion(batch)","leave_conversion_batch.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","DTR",request.getRemoteAddr(),
														"leave_conversion_batch.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","LEAVE CONVERSION",request.getRemoteAddr(),"leave_conversion_batch.jsp");
}
														
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

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PRLeaveConversion prConversion = new PRLeaveConversion();
	int iSearchResult = 0;
	int i = 0;
	String strSchCode = dbOP.getSchoolIndex();
	
	String strPayrollPeriod  = null;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = prConversion.operateOnLeaveMonetization(dbOP,request, 6);
		if(vRetResult == null)
			strErrMsg = prConversion.getErrMsg();
		else
			iSearchResult = prConversion.getSearchCount();
	}	

%>
<body bgcolor="#D2AE72" class="bgDynamic" id="boddyTag">
<form action="leave_monetization_report.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table1">
    <tr bgcolor="#A49A6A" id="tbl_header"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        LEAVE MONETIZATION REPORT PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="770" height="10">&nbsp;</td>
    </tr>
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id='seardhTbl'>
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	 <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="19%">Year</td>
      <td width="78%"><select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,0)%> 
        </select></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Leave type </td>
			
      <td>
			<select name="benefit_index">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("benefit_index","sub_type", " from hr_benefit_incentive " +
				"join HR_PRELOAD_BENEFIT_TYPE on(hr_benefit_incentive.BENEFIT_TYPE_INDEX = HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX)" +
				" where (benefit_nature = 1 or  benefit_nature = 0) and is_valid = 1 and is_del= 0 and benefit_name = 'Leave'", 
				WI.fillTextValue("benefit_index"),false)%>
      </select>      </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>Position</td>
		  <td><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
	   <select name="employee_category" onChange="ReloadPage();">          
        <option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
				  <option value="0" selected>Non-Teaching</option>
        <%}else{%>
          <option value="0">Non-Teaching</option>				
        <%}if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else{%>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
		<%}%>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td>
			<label id="load_dept">
	  	<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
			</label></td>
    </tr>
<%if(bolHasConfidential){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Process Option</td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";		
			%>			
      <td><select name="group_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("group_index","group_name"," from pr_preload_group " +
													" where exists(select user_index from pr_group_proc " +
													" 	where pr_preload_group.group_index = pr_group_proc.group_index " +
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%>
      </select></td>
    </tr>
		<%}%>		
		<%if(bolHasTeam){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Team</td>
      <td height="10"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select> </td>
    </tr>
		<%}%>		
    <tr>
      <td height="10">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
        <label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="3">OPTION:</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
            <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        
        View ALL </td>
    </tr>   	
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="filter_tbl">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=prConversion.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=prConversion.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=prConversion.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
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
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="table2">
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
                  <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/prConversion.defSearchSize;		
	if(iSearchResult % prConversion.defSearchSize > 0) ++iPageCount;
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
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  
    <table width="100%" border="0" bgcolor="#FFFFFF" >
    <tr id="tr_print_header"  style="display:none" >
      <td width="100%" align="center">
			<h3><%=SchoolInformation.getSchoolName(dbOP,true,false)%></h3>		
			Leave Monetization Report<br>			
			<div align="right">Date and time printed: <%=WI.getTodaysDateTime()%></div>			
	  </td>
	</td>
    </tr>
</table>
  
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="8" align="center" bgcolor="#B9B292" class="thinborder" id="table_head"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="5%" class="thinborder">&nbsp;</td>
      <td width="11%" class="thinborder">&nbsp;</td> 
      <td width="26%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
      <!--<td width="16%" align="center" class="thinborder"><strong><font size="1">RATE</font></strong></td>-->
			
      <td width="12%" align="center" class="thinborder"><strong><font size="1">LEAVE TYPE</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">CONVERTED</font></strong></td>
	  <td width="12%" align="center" class="thinborder"><strong><font size="1">DATE CONVERTED</font></strong></td>
      <td width="19%" align="center" class="thinborder"><font size="1"><strong>REMARKS<br></strong></font></td>
    </tr>
    <% 	int iCount = 0;
		String strCurrentEmp = "";
	   for (i = 0; i < vRetResult.size(); i+=12){	%>
	   	<tr>
		<%
	   		if(!strCurrentEmp.equals((String)vRetResult.elementAt(i))){				
				iCount++;
				strCurrentEmp = (String)vRetResult.elementAt(i); %>
				<input type="hidden" name="emp_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">	
				<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
				<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
				<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
										(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font>
				</td>	
			<%}else{ //end of if not the same %>
		 		<td align="right" class="thinborder" height="25">&nbsp;</td>
				<td align="right" class="thinborder">&nbsp;</td>
		 		<td align="right" class="thinborder">&nbsp;</td>
		    <%}//end of else the same %>
			
			  <input type="hidden" name="avail_leave_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+7)%>">			  
			  <td align="center" class="thinborder">					
					 <%=WI.getStrValue((String)vRetResult.elementAt(i + 10),"")%>&nbsp;
			  </td>	
			  <td width="1%" align="right" class="thinborder">						
					 <%=WI.getStrValue((String)vRetResult.elementAt(i + 8),"0")%>&nbsp;
		  </td>
			  <td width="1%" align="right" class="thinborder">
					<%=vRetResult.elementAt(i + 11)%>&nbsp;&nbsp;	 
		  </td>
			  <td width="1%" align="center" class="thinborder">
					<%=WI.getStrValue((String)vRetResult.elementAt(i + 9),"")%>&nbsp;
		  </td>
    </tr>
    <% } //end for loop%>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic" id="footer_tbl">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
  <input type="hidden" name="page_action">	
	<input type="hidden" name="copy_all">		
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>