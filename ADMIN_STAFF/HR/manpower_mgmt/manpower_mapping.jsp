<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManpowerMgmt" %>
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
<title>Encode AWOL Amount</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../pr_css/table_format.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
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
	this.SubmitOnce('form_');
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
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
	//this.SubmitOnce('form_');
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
 
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
 
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function filterRequests(strComboName, strField, strLabel, strOnchange, strOption) {
		var strCompleteName = eval('document.form_.'+strField+'.value');
		var objCOAInput = document.getElementById(strLabel);

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3008&has_all=1&onchange="+strOnchange+
									"&sel_name="+strComboName+"&req_filter="+escape(strCompleteName)+
									"&search_opt="+strOption;

		this.processRequest(strURL);
}

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas na numbers
			110 - period sa main
			190 - period sa numpad
			111 - / sa keypad
			191 - / sa main
	*/
	//alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46)
		return;
	
	AllowOnlyFloat(strFormName, strFieldName);
}

function viewDetails(strInfoIndex) {
	var pgLoc = "./request_details.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=670,height=280,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	boolean bolHasTeam = false;	 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-ManpowerManagement-ManpowerMapping","manpower_mapping.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"HR MANAGEMENT","MANPOWER MANAGEMENT",request.getRemoteAddr(),
														"manpower_mapping.jsp");
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
	HRManpowerMgmt manpower = new HRManpowerMgmt();
	int iSearchResult = 0;
	int i = 0;
	String strWithSched = WI.getStrValue(WI.fillTextValue("with_schedule"),"1");
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(manpower.operateOnManpowerMapping(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg = manpower.getErrMsg();
		else
			strErrMsg = "Operation success!";				
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = manpower.operateOnManpowerMapping(dbOP,request, 4);
		if(vRetResult == null)
			strErrMsg = manpower.getErrMsg();
		else
			iSearchResult = manpower.getSearchCount();
	}	

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="manpower_mapping.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A"> 
		<td height="25" colspan="5" align="center" class="footerDynamic">
		<font color="#FFFFFF"><strong>:::: PAYROLL: MANUAL ABSENCES ENCODING PAGE ::::</strong></font></td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr> 
		<td width="770" height="10">&nbsp;</td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
		<%if(strWithSched.equals("1")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Manpower Request </td>
      <td colspan="3">
			<label id="search_label">
			<select name="search_req_index" onChange="ReloadPage();">
         <option value="">Select Request</option>
        <%=dbOP.loadCombo("request_index","request_no, purpose"," from hr_manpower_request " +
				" where IS_DEL = 0 and request_stat = 1 and num_filled > 0 " + 
				WI.getStrValue(WI.fillTextValue("search_filter"),"and  (request_no like '%","%')","") +
				" order by request_no asc", WI.fillTextValue("search_req_index"), false)%>				 
      </select>
			</label>
			<input type="text" name="search_filter" value="<%=WI.fillTextValue("search_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" 
		onKeyUp="filterRequests('search_req_index','search_filter', 'search_label','ReloadPage()','1');">
			<%if(WI.fillTextValue("search_req_index").length() > 0){%>
			<a href="javascript:viewDetails('<%=WI.fillTextValue("search_req_index")%>');">INFO</a> 
			<%}%>
			</td>
    </tr>
		<%}%>
    <tr>
      <td width="4%" height="24">&nbsp;</td>
      <td width="21%">Status</td>
      <td width="75%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
		  <td colspan="3"><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
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
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
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
			</label></td>
    </tr>
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
      <td height="10">Office/Dept filter<br></td>
      <td height="10" colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
			<label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION:</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4"><%
	if(strWithSched.equals("1")) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with manpower mapping 
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees w/out mapping </td>
    </tr>
    
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        View ALL </td>
    </tr>		
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=manpower.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=manpower.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=manpower.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<!--
    <tr>   
      <%// if (vRetResult != null && vRetResult.size() > 0 ){%>
      <td height="10"><div align="right"><font size="2">Number of Employees / rows Per 
        Page :</font><font>
                  <select name="num_rec_page">
                    <% //int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
		//	for(i = 10; i <=40 ; i++) {
			//	if ( i == iDefault) {%>
                    <option selected value="<%//=i%>"><%//=i%></option>
                    <%//}else{%>
                    <option value="<%//=i%>"><%//=i%></option>
                    <%//}}%>
                  </select>
                  <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%//}%>
    </tr>
		-->
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/manpower.defSearchSize;		
	if(iSearchResult % manpower.defSearchSize > 0) ++iPageCount;
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="9" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">EMP ID </font></strong></td> 
      <td width="31%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="30%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
			<%if(strWithSched.equals("1")){%>
			<td width="12%" align="center" class="thinborder"><strong><font size="1">DETAILS</font></strong></td>
			<%}%>
			<%if(WI.fillTextValue("viewOption").equals("1")){%>
      <!--
			<td width="5%" align="center" class="thinborder"><strong><font size="1">HOURS ABSENT <br>
            <a href="javascript:CopyHour();">Copy all</a></font></strong></td>
			<td width="5%" align="center" class="thinborder"><strong><font size="1">MINUTES ABSENT <br>
            <a href="javascript:CopyMinute();">Copy all</a></font></strong></td>
			-->			
			<%}else{%>
      <%}%>
      <td width="12%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+= 15,iCount++){
		 %>
    <tr id="_rowData">
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="id_number_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="hidden" name="req_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
			<%if(strWithSched.equals("1")){%>
			<td align="center" class="thinborder"><a href="javascript:viewDetails('<%=vRetResult.elementAt(i + 7)%>');">view</a></td>
			<%}%>
			<%if(WI.fillTextValue("viewOption").equals("1")){%>
		  <%
				strTemp = "";
				if(strWithSched.equals("1") && !WI.fillTextValue("copy_all").equals("1"))
					strTemp = (String)vRetResult.elementAt(i + 7);
				else{
					if(WI.fillTextValue("copy_all").equals("1"))
						strTemp = WI.fillTextValue("days_");
				}
				strTemp = WI.getStrValue(strTemp,""); 			
  		%>
		  <!--
		  <%
				strTemp = "";
				if(strWithSched.equals("1") && !WI.fillTextValue("copy_all").equals("1"))
					strTemp = (String)vRetResult.elementAt(i + 9);
				else{
					if(WI.fillTextValue("copy_all").equals("1"))
						strTemp = WI.fillTextValue("hours_");
				}
				strTemp = WI.getStrValue(strTemp,""); 			
  		%>			
			<td align="center" class="thinborder"><strong>
			  <input name="hours_<%=iCount%>" type="text" size="4" maxlength="5" class="textbox"
			value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="AllowOnlyInteger('form_','hours_<%=iCount%>');style.backgroundColor='white'"
	    onKeyUp="AllowOnlyInteger('form_','hours_<%=iCount%>');" style="text-align : right">
			</strong></td>
		  <%
				strTemp = "";
				if(strWithSched.equals("1") && !WI.fillTextValue("copy_all").equals("1"))
					strTemp = (String)vRetResult.elementAt(i + 10);
				else{
					if(WI.fillTextValue("copy_all").equals("1"))
						strTemp = WI.fillTextValue("minutes_");
				}
				strTemp = WI.getStrValue(strTemp,""); 			
  		%>			
			<td align="center" class="thinborder"><strong>
			  <input name="minutes_<%=iCount%>" type="text" size="4" maxlength="5" class="textbox"
			value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="AllowOnlyInteger('form_','minutes_<%=iCount%>');style.backgroundColor='white'"
	    onKeyUp="AllowOnlyInteger('form_','minutes_<%=iCount%>');" style="text-align : right">
			</strong></td>
			-->
			<%}else{%>
		  <%
			strTemp = "";
			if(strWithSched.equals("1") && !WI.fillTextValue("copy_all").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 8);
			else{
				if(WI.fillTextValue("copy_all").equals("1"))
					strTemp = WI.fillTextValue("amount_");
			}						
		  %>
      <%}%>
      <td align="center" class="thinborder">        
			<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">			</td>
    </tr>
    <%} //end for loop%>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
		<%if(!strWithSched.equals("1")){%>
    <tr>
      <td width="3%">&nbsp;</td>
			<td width="18%">Request mapping </td> 
      <td width="79%" height="25">
			<label id="save_label">
			<select name="request_index">
        <option value="">Select Request</option>
        <%=dbOP.loadCombo("request_index","request_no, purpose"," from hr_manpower_request " +
				" where IS_DEL = 0 and request_stat = 1 and num_filled < num_approved " + 
				WI.getStrValue(WI.fillTextValue("req_filter"),"and  (request_no like '%","%')","") +
				" order by request_no asc", WI.fillTextValue("request_index"), false)%>
      </select>
			</label>			<input type="text" name="req_save_filter" value="<%=WI.fillTextValue("req_filter")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" 
		onKeyUp="filterRequests('request_index','req_save_filter', 'save_label','', '0');"></td>
    </tr>
		<%}%>
    <tr>
      <td height="25" colspan="3" align="center">
				<%if(iAccessLevel > 1){%>
				<!--
					<a href='javascript:SaveData();'><img src="../../../images/save.gif" border="0" id="hide_save"></a> 
					-->
				<%if(!strWithSched.equals("1")){%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
				<%}%>
          <%if(strWithSched.equals("1") && iAccessLevel == 2){%>
          <!--
						<a href='javascript:DeleteRecord();'><img src="../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
						-->
					<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					<font size="1">Click to delete selected </font>
        <%}%>
        <!--
					<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
					-->
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
				  <font size="1"> click to cancel</font>
				<%}%>			</td>
    </tr>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
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