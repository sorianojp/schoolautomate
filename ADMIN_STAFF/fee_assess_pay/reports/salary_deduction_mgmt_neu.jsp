<%@ page language="java" import="utility.*,java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
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
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script language="JavaScript">

function AjaxMapName() {		
	var strSearchCon = "&search_temp=2"

	strCompleteName = document.form_.stud_id.value;
	if(strCompleteName.length < 3) {
		document.getElementById("coa_info").innerHTML = "";
		return;
	}

	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);		
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//this.ReloadPage();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function PageAction(strAction, strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this information?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.page_action.value = strAction;	
	this.ShowData();
}

function PrepareToEdit(strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";	
	this.ShowData();
}

function CancelOperation(){
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.show_data.value = "";
	this.ReloadPage();
}	

function ShowData(){
	document.form_.show_data.value = "1";
	document.form_.submit();
}

function ReloadPage(){	
	document.form_.submit();
}

function PrintPage(){
	document.form_.print_page.value = "1";
	document.form_.page_action.value= "";
	this.ReloadPage();
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ShowSearch(){
	document.form_.view_search_option.value='1';
	document.form_.print_page.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
DBOperation dbOP = null;
WebInterface WI = new WebInterface(request);
String strErrMsg = null;
String strTemp   = null;

if(WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./salary_deduction_mgmt_neu_print.jsp"></jsp:forward>
<%return;}
try{
	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-Fee Assessment & Payments - Admission slip","salary_deduction_mgmt_neu.jsp");
	
}catch(Exception exp){
	exp.printStackTrace();%>
	<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
	<%return;
}

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"salary_deduction_mgmt_neu.jsp");														


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

String[] astrDropListEqual = {"Equal To","Starts With","Ends With","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName = {"SD Number","College","Last Name"};
String[] astrSortByVal = {"sal_ded_number","c_code","lname"};

Vector vRetResult = null;
Vector vEditInfo  = null;

enrollment.FAEmpSalaryDeduction faEmpSal = new enrollment.FAEmpSalaryDeduction();

int iSearchResult = 0;
int iElemCount = 0;
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(faEmpSal.operateOnSalaryDeduction(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = faEmpSal.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Information successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Information successfully recorded.";
		if(strTemp.equals("2"))
			strErrMsg = "Information successfully updated.";
		strPrepareToEdit = "0";
	}
}

if(strPrepareToEdit.equals("1")){
	vEditInfo = faEmpSal.operateOnSalaryDeduction(dbOP, request, 3);
	if(vEditInfo == null)
		strErrMsg = faEmpSal.getErrMsg();
}
	
//if(WI.fillTextValue("show_data").length() > 0){
	vRetResult = faEmpSal.getStudListInformation(dbOP, request);
	if(vRetResult == null){
		if(strErrMsg == null || strErrMsg.length() == 0)
		strErrMsg = faEmpSal.getErrMsg();
	}
	else{
		iElemCount = faEmpSal.getElemCount();
		iSearchResult = faEmpSal.getSearchCount();
	}
//}
	
%>
<form name="form_" action="salary_deduction_mgmt_neu.jsp" method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="header">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" align="center" style="font-weight:bold; color:#FFFFFF"> :::: EMPLOYEE DISCOUNT APPLICATION PAGE ::::</td>
    </tr>
  
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>	
	<tr>
	<td height="25">&nbsp;</td>
	<td width="17%">SY-TERM:</td>
      <td  colspan="2">
<%	strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>    <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%	strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>    <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
       <select name="semester" >
	   <%
	   strTemp =WI.fillTextValue("semester");
	 if(strTemp.length() ==0) 
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	   %><%=dbOP.loadSemester(false, strTemp , request)%>
        </select></td>
    </tr>	
	<tr>
     <td width="3%" height="25">&nbsp;</td>
      <td width="21%">Sponsorship Classification</td>
	  <%
	  strTemp = WI.fillTextValue("classification_index");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(5);
	  %>
      <td width="76%">
	  <select name="classification_index" style="width:200px;">
	  	<option value="">Select Classification</option>
		<%
		strErrMsg = " from NEU_SD_CLASSIFICATION order by CLASSIFICATION_NAME";
		%>
	  	<%=dbOP.loadCombo("classification_index","CLASSIFICATION_NAME",strErrMsg, strTemp, false)%>
	  </select>	 
	  <a href='javascript:viewList("NEU_SD_CLASSIFICATION","CLASSIFICATION_INDEX","CLASSIFICATION_NAME","CLASSIFICATION", 
	  		"NEU_SD", "CLASSIFICATION_INDEX"," and is_valid = 1","","classification_index");'> 
       <img src="../../../images/update.gif" border="0" /></a>
	   <font size="1">Click to update classification list</font>
	  </td>
	  </tr>
	  <tr>
	    <td height="25">&nbsp;</td>
	    <td>Sponsor Name</td>
		<%
		strErrMsg = "64";
		
	  strTemp = WI.fillTextValue("sponsor_name");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(3);
	  
		%>
	    <td>
		
		<textarea name="sponsor_name" cols="40" rows="2" class="textbox"
	  onfocus="CharTicker('form_','<%=strErrMsg%>','sponsor_name','count_sponsor');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','<%=strErrMsg%>','sponsor_name','count_sponsor');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','<%=strErrMsg%>','sponsor_name','count_sponsor');"><%=strTemp%></textarea>
	  &nbsp;
	  
	  Allowed Characters <input type="text" name="count_sponsor" class="textbox_noborder" readonly="yes" tabindex="-1">		
	 	<script>CharTicker('form_','<%=strErrMsg%>','sponsor_name','count_sponsor')</script>
		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Salary Deduction Number</td>	
		<%
		strErrMsg = "32";
		strTemp = WI.fillTextValue("sal_ded_number");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(1);
		%>	
	    <td><input name="sal_ded_number" type="text" class="textbox" 
		onfocus="CharTicker('form_','<%=strErrMsg%>','sal_ded_number','count_salded');style.backgroundColor='#D3EBFF'" 
	  onBlur ="CharTicker('form_','<%=strErrMsg%>','sal_ded_number','count_salded');style.backgroundColor='white'" 
	  onkeyup="CharTicker('form_','<%=strErrMsg%>','sal_ded_number','count_salded');"
	  value="<%=strTemp%>" size="16"
	  
	  >
	  Allowed Characters <input type="text" name="count_salded" class="textbox_noborder" readonly="yes" tabindex="-1">	  
	  <script>CharTicker('form_','<%=strErrMsg%>','sal_ded_number','count_salded')</script>
	  </td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>District/Department</td>
		
	    <td>
		<select name="district_index" style="width:200px;">
		<option value="">Select District</option>
	  	<%
		strTemp = WI.fillTextValue("district_index");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(4);
		
		strErrMsg = " from neu_sd_district order by district_name";
		%>
	  	<%=dbOP.loadCombo("district_index","district_name",strErrMsg, strTemp, false)%>
	  </select>		
	  <a href='javascript:viewList("NEU_SD_DISTRICT","DISTRICT_INDEX","DISTRICT_NAME","DISTRICT", 
	  		"NEU_SD", "DISTRICT_INDEX"," and is_valid = 1","","district_index");'> 
       <img src="../../../images/update.gif" border="0" /></a>
	   <font size="1">Click to update classification list</font>
	  </td>
	    </tr>
	
	
	    <td height="25">&nbsp;</td>
	    <td>Student ID</td>
		<%
		strTemp = WI.fillTextValue("stud_id");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(2);
		%>
	    <td>	
		<input name="stud_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="16" onKeyUp="AjaxMapName();">	
	  &nbsp; &nbsp;	
	  <label id="coa_info" style="position:absolute; width:300px;"></label>
	  </td>
	    </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Approved Date</td>	
			<%
		strTemp = WI.fillTextValue("approved_date");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(7);
		%>		
            <td height="25">
			<input name="approved_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.approved_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
        </font>			</td>
          </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>Remark</td>
		<%
		strTemp = WI.fillTextValue("remarks");
	  if(vEditInfo != null && vEditInfo.size() >  0)
	  	strTemp = (String)vEditInfo.elementAt(6);
		%>	
	    <td><textarea name="remarks" cols="50" rows="2"><%=strTemp%></textarea></td>
	</tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
		<%
		if(strPrepareToEdit.equals("0")){
		%>
		<a href="javascript:PageAction('1','')"><img src="../../../images/save.gif" border="0" /></a>
		<font size="1">Click to save information</font>
		<%}else{%>
		<a href="javascript:PageAction('2','')"><img src="../../../images/edit.gif" border="0" /></a>
		<font size="1">Click to update information</font>		
		<%}%>
		<a href="javascript:CancelOperation()"><img src="../../../images/cancel.gif" border="0" /></a>
		<font size="1">Click to cancel operation</font>

		</td>
	    </tr>
	<tr>
	    <td height="25">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
	    </tr>
  </table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td><hr width="100%" /></td></tr>
<tr>
	<%
	strTemp = WI.fillTextValue("view_search_option");
	if(strTemp.equals("1"))
		strErrMsg = "checked";
	else
		strErrMsg = "";
	%>
	<td><input type="checkbox" name="view_search_option" value="1" <%=strErrMsg%> 
		onclick="ShowSearch()" />View Search Option
		  <%if(strTemp.equals("1")){%>
  			<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<%
					strTemp = WI.fillTextValue("is_basic");
					if(strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
				    <td colspan="2"><input type="checkbox" name="is_basic" value="1" <%=strErrMsg%> 
						onclick="ShowSearch()" />View basic student</td>
				    
				    </tr>
			<%
			if(WI.fillTextValue("is_basic").length() == 0){
			%>
				<tr>
					<td width="23%">College</td>
					<td width="77%"><select name="c_index_search" style="width:300px;" onchange="ReloadPage();">
					<option value="">Select college</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del = 0 order by c_name" , WI.fillTextValue("c_index_search"), false)%>
					</select></td>
				</tr>
				<tr>
					<td>Course</td>
					<td><select name="course_index_search" style="width:300px;">
					<option value="">Select course</option>
					<%
					strTemp = " from course_offered where is_valid =1 and is_offered = 1 ";
					if(WI.fillTextValue("c_index_search").length() > 0)
						strTemp += " and c_index = "+WI.fillTextValue("c_index_search");
					strTemp += " order by  course_name";
					%>
					<%=dbOP.loadCombo("course_index","course_name", strTemp , WI.fillTextValue("course_index_search"), false)%>
					</select></td>
				</tr>
			<%}else{%>
				<tr>
					<td>Educational Level</td>
					<td><select name="edu_level_search" style="width:300px;">
					<option value="">Select Educational Level</option>
					<%
					strTemp = " from bed_level_info order by edu_level";
					%>
					<%=dbOP.loadCombo("distinct edu_level","edu_level_name", strTemp , WI.fillTextValue("edu_level_search"), false)%>
					</select></td>
				</tr>
				
				<tr>
					<td>Grade Level</td>
					<td><select name="year_level_search" style="width:200px;">
					<option value="">Select Grade Level</option>
					<%
					strTemp = " from bed_level_info order by g_level";
					%>
					<%=dbOP.loadCombo("g_level","level_name", strTemp , WI.fillTextValue("year_level_search"), false)%>
					</select></td>
				</tr>
			<%}%>
				<tr>
					<td>Classification</td>
					<td><select name="classification_index_search" style="width:200px;">
	  	<option value="">Select Classification</option>
		<%
		strErrMsg = " from NEU_SD_CLASSIFICATION order by CLASSIFICATION_NAME";
		%>
	  	<%=dbOP.loadCombo("classification_index","CLASSIFICATION_NAME",strErrMsg, WI.fillTextValue("classification_index_search"), false)%>
	  </select>	</td>
				</tr>
				<tr>
					<td>District</td>
					<td><select name="district_index_search" style="width:200px;">
		<option value="">Select District</option>
	  	<%		
		strErrMsg = " from neu_sd_district order by district_name";
		%>
	  	<%=dbOP.loadCombo("district_index","district_name",strErrMsg, WI.fillTextValue("district_index_search"), false)%>
	  </select></td>
				</tr>
				<tr>
				    <td>&nbsp;</td>
					
				    <td>
					<%
					strTemp = WI.fillTextValue("is_temp_stud_search");
					if(strTemp.length() == 0)
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<input type="radio" name="is_temp_stud_search" value="" <%=strErrMsg%> 
						onclick="ShowSearch()" />View ALL Student
					<%
					if(strTemp.equals("1"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<input type="radio" name="is_temp_stud_search" value="1" <%=strErrMsg%> 
						onclick="ShowSearch()" />View Temporary Student
					<%					
					if(strTemp.equals("0"))
						strErrMsg = "checked";
					else
						strErrMsg = "";
					%>
					<input type="radio" name="is_temp_stud_search" value="0" <%=strErrMsg%> 
						onclick="ShowSearch()" />View Permanent Student					</td>
				    </tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=faEmpSal.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=faEmpSal.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=faEmpSal.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
            	</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>
		
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="4">
				<a href="javascript:ShowData();"><img src="../../../images/refresh.gif" border="0" /></a></td>
		</tr>
		<tr>
		    <td height="25" colspan="2">&nbsp;</td>
		    <td colspan="4">&nbsp;</td>
		    </tr>
	</table>
      <%}%>
	</td>
</tr>
</table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	    <td class="thinborderBOTTOMLEFT" colspan="3">
		<input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#FFFFFF; border:solid 1px #000000;	" />Permanent Student
			<br><input type="button" name="_2" disabled="disabled" border="0" 
				style="font-size:11px; height:25px; width:25px; background-color:#CCCCCC; border:solid 1px #000000;	" />Temporary Student			
		</td>
	    <td class="thinborderBOTTOM" height="25" colspan="5" align="right">
		Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 30;
if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i =25; i < 60; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	  <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
		<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0" /></a>
		<font size="1">Click to print report(Only permanent student will be listed)</font>
		</td>
	    </tr>
	<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="3">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(faEmpSal.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				if(!WI.fillTextValue("view_all").equals("1")){
					iPageCount = iSearchResult/faEmpSal.defSearchSize;		
					if(iSearchResult % faEmpSal.defSearchSize > 0)
						++iPageCount;
				}
				strTemp = " - Showing("+faEmpSal.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
		</tr>
	<tr>
		<td width="8%" height="25" valign="top" class="thinborder"><strong>SD #</strong></td>
		<td width="15%" valign="top" class="thinborder"><strong>SPONSOR NAME</strong></td>
		<td width="15%" valign="top" class="thinborder"><strong>DISTRICT/ DEPT.</strong></td>
		<td width="22%" valign="top" class="thinborder"><strong>STUDENT NAME</strong></td>
		<td width="15%" valign="top" class="thinborder"><strong>COLLEGE/ DEPT.</strong></td>
		<td width="14%" valign="top" class="thinborder"><strong>COURSE/ YEAR LEVEL</strong></td>
		<td width="11%" align="center" valign="top" class="thinborder"><strong>OPTION</strong></td>
	</tr>
	<%
	String strColor = "CCCCCC";
	for(int i = 0 ; i < vRetResult.size() ; i+=iElemCount){
	if(WI.getStrValue(vRetResult.elementAt(i+6)).equals("0"))
		strColor = "FFFFFF";
	else
		strColor = "CCCCCC";
	%>
	<tr bgcolor="#<%=strColor%>">
		<td class="thinborder" height="22"><%=vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+8)%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+10),"NA")%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),4);
		%>
		<td class="thinborder"><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"(",")","")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+13),"NA")%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+15);
		if(WI.getStrValue(vRetResult.elementAt(i+18)).equals("1"))
			strTemp = "";
		%>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+14),"&nbsp;")%>
			<%=WI.getStrValue(strTemp," - ","","")%></td>
		<td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0" height="22" width="40" /></a>
			&nbsp; &nbsp;
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"  height="22" width="40"  /></a>		</td>
	</tr>
	<%}%>
</table>

<%}%>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
<tr bgcolor="#FFFFFF"><td height="25"></td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="page_action" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>" />
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
<input type="hidden" name="show_data" value="" />
<input type="hidden" name="print_page" value="" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
