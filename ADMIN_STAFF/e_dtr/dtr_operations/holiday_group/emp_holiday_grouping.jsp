<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(7);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Holiday Rate Grouping</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>

<script language="JavaScript">
function ReloadPage()
{	
	document.form_.pageReloaded.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../../images/blank.gif";
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
function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
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

function UpdatePeriod(){
	if(document.form_.new_period_index)
		document.form_.new_period_index.value = document.form_.period_index.value;
}

function ShowHideLabel(strShowHide){
	var iframe = document.getElementById('iframetop');
	var layer = document.getElementById("note");
	
	if(strShowHide == '1'){		
		layer.style.visibility = "visible";
		iframe.style.display = 'block';
		layer.style.display = 'block';	
		iframe.style.width = layer.offsetWidth-5;	
		iframe.style.left = layer.offsetLeft;
		iframe.style.top = layer.offsetTop;
		iframe.style.height = (layer.offsetHeight-5);				
	}else{
		layer.style.visibility = "hidden";
		iframe.style.display = 'none';
		layer.style.display = 'none';	
	}
	
}
</script>
<%@ page language="java" import="utility.*, java.util.Vector, eDTR.Holidays" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./salary_period_setting_print.jsp" />
	<% 
return;}


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-DTR OPERATIONS","emp_holiday_grouping.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"emp_holiday_grouping.jsp");
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
	Holidays HOL = new Holidays();
	Vector vRetResult = null;
	String strPageAction = WI.fillTextValue("page_action");
	boolean bolRetain = false;
	String[] astrCategory = {"Staff","Faculty","Employees"};
	String[] astrStatus = {"Part-Time","Full-Time",""};
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName    = {"Employee ID",strTemp, "Department/Office"};
	String[] astrSortByVal     = {"id_number","info_faculty_basic.c_index","info_faculty_basic.d_index"};
	int i = 0;

	if(strPageAction.length() > 0){
		if(HOL.operateOnEmpHolidayGrouping(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = HOL.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Grouping successfully posted.";
			if(strPageAction.equals("0"))
				strErrMsg = "Grouping successfully removed.";
		}
	}

  if(WI.fillTextValue("searchEmployee").equals("1")){
		vRetResult = HOL.operateOnEmpHolidayGrouping(dbOP, request, 4);
	  if(vRetResult == null)
			strErrMsg = HOL.getErrMsg();
	  else
			iSearchResult = HOL.getSearchCount();
  }

	if(strErrMsg == null)
		strErrMsg = "";
%>
<body class="bgDynamic">
<form name="form_" method="post" action="./emp_holiday_grouping.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: HOLIDAY RATE GROUPING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><strong><a href="./holiday_mgmt_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><%=strErrMsg%></strong></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td width="20%">Employee ID </td>
      <td width="78%">
			<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"><label id="coa_info"></label></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Position</td>
	  <%//System.out.println("size " +WI.fillTextValue("pageReloaded"));	
		  	strTemp = WI.fillTextValue("position");		
	  %>	  
      <td> <select name="position" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%> </select></td>
    </tr>	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
	  <%
		strTemp = WI.fillTextValue("pt_ft");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  
      <td><select name="pt_ft" onChange="ReloadPage();">
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
      <td>
	    <select name="employee_category" onChange="ReloadPage();">
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
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
	  <%
		  strTemp = WI.fillTextValue("d_index");
	  %>	  	  	  
      <td> 
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
      <td height="20">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
		
    <%if(bolHasConfidential){%>
    <tr> 
      <td width="2%" height="20">&nbsp;</td>
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
    <tr>
      <td height="11" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="11" colspan="3">OPTION:</td>
    </tr>
    <tr>
      <td height="11" colspan="3"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1" <%=strTemp%> onClick="ReloadPage();">
        View with group 
        <%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
	<input type="radio" name="with_schedule" value="0" <%=strTemp%> onClick="ReloadPage();">
View Employees without holiday group</td>
    </tr>
		<%if(WI.fillTextValue("with_schedule").equals("1")){%>
    <tr>
      <td height="11" colspan="3"><strong>
        Holiday Group : 
        <select name="holiday_group">
					<option value="">ALL</option>	
          <%if(WI.fillTextValue("holiday_group").equals("0")){%>
					<option value="0" selected>Default group</option>
					<%}else{%>
					<option value="0">Default group</option>
					<%}%>
          <%=dbOP.loadCombo("h_group_index","group_name"," from EDTR_HOLIDAY_GROUP " +
 					" order by group_name asc", WI.fillTextValue("holiday_group"), false)%>
        </select>
      </strong></td>
    </tr>
		<%}%>
    <tr>
      <td height="11" colspan="3"><%
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
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :<strong></strong></td>
      <td height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%=HOL.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=HOL.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=HOL.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
			<!--
			<a href="javascript:SearchEmployee()"> <img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"> </a> 
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
	<% if(vRetResult != null && vRetResult.size() > 0) {%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    
    <%
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/HOL.defSearchSize;		
	if(iSearchResult % HOL.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td height="18" align="right"><font size="2">Jump To page:
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
		    <%} // end if pages > 1
		}// end if not view all%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="5" align="center"><strong>HOLIDAY GROUPING </strong></td>	  
    </tr>
    <tr bgcolor="#ffff99" class="thinborder">
      <td width="12%" align="center" class="thinborder"><strong>EMP ID</strong></td> 
      <td width="37%" height="25" align="center" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
      <td class="thinborder" width="28%" align="center"><strong>OFFICE</strong></td>
		  <%if((WI.fillTextValue("with_schedule")).equals("1")){%>
      <td width="13%" align="center" class="thinborder"><strong>GROUP NAME </strong></td>
      <%}%>
		  <td align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </font></td>
	  
    </tr>
    <% int iCount = 1;
	for(i = 0; i < vRetResult.size(); i += 20,iCount++){		
		bolRetain = false;
	%>		
		<input type="hidden" name="emp_group_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
		<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
		<input type="hidden" name="emp_id_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>">
    <tr bgcolor="#FFFFFF" class="thinborder">
      <%
		  	strTemp = (String)vRetResult.elementAt(i+2);
	  %>
      <td class="thinborder" >&nbsp;<%=strTemp%></td> 

      <td height="25" class="thinborder" >&nbsp;<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>

      <%	   
	    if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
	  %>							
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7)," ")%> </td>
	   <%if((WI.fillTextValue("with_schedule")).equals("1")){
		 		strTemp = (String)vRetResult.elementAt(i+9);
		 %>		 
      <td class="thinborder" >&nbsp;<%=strTemp%></td>
     <%}%>
		  <td width="10%" align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1"></td>
    </tr>
    <%} // end for loop%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>  
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td width="20%" height="25" bgcolor="#FFFFFF"><strong>New Holiday Group </strong></td>
			<%
				strTemp = WI.fillTextValue("new_group_index");
			%>
      <td width="80%" height="25" bgcolor="#FFFFFF"><strong>
        <select name="new_group_index">
          <option value="">Default group</option>
          <%=dbOP.loadCombo("h_group_index","group_name"," from EDTR_HOLIDAY_GROUP " +
 					" order by group_name asc", strTemp, false)%>
        </select>
      </strong></td>
    </tr>
    <tr>
      <td height="25"  colspan="2" align="center" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="2" align="center" bgcolor="#FFFFFF">
				<%if(iAccessLevel > 1){%>
				<!--
				<a href='javascript:SaveData();'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
          <%if((WI.fillTextValue("with_schedule")).equals("1")){%>
          <!--
					<a href='javascript:DeleteRecord();'><img src="../../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
					-->
					<%if(iAccessLevel == 2){%>
					<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					<font size="1">Click to delete selected </font>
					<%}%>
        <%}%>
        <!--
				<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
				-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;"
				onClick="javascript:CancelRecord();">				
				<font size="1"> click to cancel or go previous</font>
				<%}%>			</td>
    </tr>
  </table>  
  <%} // end if vRetResult != null && vRetResult.size() %>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>	
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="pageReloaded">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>