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
<title>Max Time Difference</title>
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
	document.form_.pageReloaded.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../images/blank.gif";
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

function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.max_diff_'+i+'.value=document.form_.max_diff_1.value');			
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
<%@ page language="java" import="utility.*,java.util.Vector, eDTR.WorkingHour" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Dtr Operations-Emp Max Difference","max_diff_setting.jsp");
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
														"max_diff_setting.jsp");
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

WorkingHour wHour = new WorkingHour();
Vector vRetResult = null;
String strPageAction = WI.fillTextValue("page_action");
String[] astrCategory = {"Staff","Faculty","Employees"};
String[] astrStatus = {"Part-Time","Full-Time",""};
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
String[] astrSortByName    = {"Employee ID",strTemp, "Department/Office"};
String[] astrSortByVal     = {"id_number","info_faculty_basic.c_index","info_faculty_basic.d_index"};
if(WI.fillTextValue("with_schedule").equals("1")){
	astrSortByName = new String[4];
	astrSortByName[0] = "Employee ID";
	astrSortByName[1] = strTemp;
	astrSortByName[2] = "Department/Office";
	astrSortByName[3] = "Date";
	
	
	astrSortByVal = new String[4];
	astrSortByVal[0] = "id_number";
	astrSortByVal[1] = "info_faculty_basic.c_index";
	astrSortByVal[2] = "info_faculty_basic.d_index";
	astrSortByVal[3] = "date_";
	
	
}

int i = 0;

if(strPageAction.length() > 0){
	if(wHour.operateOnUserMaxDiff(dbOP, request, Integer.parseInt(strPageAction)) == null){
		strErrMsg = wHour.getErrMsg();
	} else {
		if(strPageAction.equals("1"))
			strErrMsg = "Max Difference Setting successfully posted.";		
		if(strPageAction.equals("0")){
			strErrMsg = "Max Difference Setting successfully removed.";		
		}			
	}
}

  if(WI.fillTextValue("searchEmployee").equals("1")){
	vRetResult = wHour.operateOnUserMaxDiff(dbOP, request, 4);
	  if(vRetResult == null)
			strErrMsg = wHour.getErrMsg();
	  else
			iSearchResult = wHour.getSearchCount();

  }

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./max_diff_setting.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      eDTR: MAX DIFFERENCE SETTING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3">
			<a href='javascript:ShowHideLabel("1")' title="click to see help">
			<img src="../../../images/online_help.gif" width="34" height="26" border="0"></a>
			<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;height:75;"> </iframe>
			<div id="note" style="position:absolute; visibility:hidden; width:550px; overflow:auto;">
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFCC">
				<tr>
					<td width="90%">
					NOTE : Use this page to override the max time difference<br>
					set under DTR OPERATIONS>Set DTR Settings
					</td>
					<td width="10%" align="center"><a href="javascript:ShowHideLabel('0');"><strong><font size="2" color="#FF0000">HIDE</font></strong></a></td>
				</tr>
				<tr>
					<td> <strong>2 Types :</strong></td>
					<td align="center"></td>
				</tr>				

				<tr>
					<td>1. <strong>Per day</strong> - Max time difference is valid only on the specified date. This setting is given higher priority.</td>
					<td></td>
				</tr>				
				<tr>
					<td>2. <strong>Recurring(no date)</strong> - No specified date. Will override the main setting for as long as it is valid.</td>
					<td></td>
				</tr>				
				</table>
			</div>
			<strong><%=strErrMsg%></strong></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td width="20%">Employee ID </td>
      <td><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> <label id="coa_info"></label></td>
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
				</label>
			</td>
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
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
        View with override 
        <%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
	<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View all Employees </td>
    </tr>
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
          <%=wHour.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=wHour.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=wHour.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
			<a href="javascript:SearchEmployee()"> <img src="../../../images/form_proceed.gif" width="81" height="21" border="0"> </a> 
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0  ) {%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    
    <%
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/wHour.defSearchSize;		
	if(iSearchResult % wHour.defSearchSize > 0) ++iPageCount;
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
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH MAX DIFFERENCE OVERRIDE ";
	  else
	    strTemp = "EMPLOYEES WITHOUT MAX DIFFERENCE OVERRIDE ";
	  
	  %>	
      <td height="23" colspan="6" align="center"><strong><%=strTemp%></strong></td>	  
    </tr>
    <tr bgcolor="#ffff99">
      <td width="13%" align="center" class="thinborder"><strong>EMPLOYEE ID </strong></td> 
      <td width="44%" height="25" align="center" class="thinborder"><strong>EMPLOYEE NAME</strong></td>
      <td class="thinborder" width="22%" align="center"><strong>OFFICE</strong></td>
	    <td align="center" class="thinborder"><strong>MAX DIFF</strong><br>
      <strong><font size="1"><a href="javascript:CopyAll();">Copy all</a></font></strong></td>
		  <%if(WI.fillTextValue("with_schedule").equals("1")){%>
			<td align="center" class="thinborder"><strong>DATE</strong></td>
			<%}%>			
		  <td align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% int iCount = 1;
		for(i = 0; i < vRetResult.size(); i += 15,iCount++){		
		%>
		<input type="hidden" name="user_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
		<input type="hidden" name="diff_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+8)%>">
		<input type="hidden" name="user_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
    <tr bgcolor="#FFFFFF">
      <%
		  	strTemp = (String)vRetResult.elementAt(i+1);
	  %>
      <td class="thinborder" >&nbsp;<%=strTemp%></td> 

      <td height="25" class="thinborder" >&nbsp;<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>

      <%	   
	    if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
	  %>							
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%> </td>
			<%
				if((WI.fillTextValue("with_schedule")).equals("1"))
					strTemp = (String)vRetResult.elementAt(i+7);
				else
					strTemp = WI.fillTextValue("max_diff_"+iCount);
			%>
	    <td width="10%" nowrap class="thinborder">
			<input type="text" name="max_diff_<%=iCount%>" value="<%=strTemp%>"
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','max_diff_<%=iCount%>');" 
			onKeyUp="AllowOnlyFloat('form_','max_diff_<%=iCount%>')"
			size="6" maxlength="5" style="text-align:right" >
			hrs</td>
      <%if(WI.fillTextValue("with_schedule").equals("1")){ 
				strTemp = (String)vRetResult.elementAt(i+9); %>
		  <td width="10%" align="center" class="thinborder"><%=WI.getStrValue(strTemp,"n/a")%></td>
			<%}%>
		  <td width="10%" align="center" class="thinborder"><input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"></td>	  
    </tr>
    <%} // end for loop%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>  
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td height="25"  colspan="2" align="center" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
		<%if(!WI.fillTextValue("with_schedule").equals("1")){%>
    <tr>
      <td width="18%" height="25" align="right" bgcolor="#FFFFFF">Inclusive Dates &nbsp;</td>
      <td width="82%" bgcolor="#FFFFFF">From :
        <input name="date_from" type="text"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white'" size="10" value="<%=WI.fillTextValue("date_from")%>">
&nbsp;<a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> &nbsp;&nbsp;&nbsp;To:
<input name="date_to" type="text"  class="textbox" id="date_to" onFocus="style.backgroundColor='#D3EBFF'" 
							onBlur="style.backgroundColor='white'" size="10" value="<%=WI.fillTextValue("date_to")%>">
&nbsp;<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
			 onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			 <img src="../../../images/calendar_new.gif" border="0"></a>
			 </td>
    </tr>
		<%}%>
    <tr>
      <td height="25"  colspan="2" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="2" align="center" bgcolor="#FFFFFF">
				<%if(iAccessLevel > 1){%>
				<!--
				<a href='javascript:SaveData();'><img src="../../../images/save.gif" border="0" id="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
          <%if((WI.fillTextValue("with_schedule")).equals("1")){%>
          <!--
					<a href='javascript:DeleteRecord();'><img src="../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
					-->
					<%if(iAccessLevel == 2){%>
					<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					<font size="1">Click to delete selected </font>
					<%}%>
        <%}%>
        <!--
				<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a> 
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