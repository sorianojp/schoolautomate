<%@ page language="java" import="utility.*,java.util.Vector, hr.HRLeaveSetting"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if ((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Start of leave increment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function CancelRecord(){
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.show_list.value = "1";
	document.form_.save.disabled = true;
	document.form_.submit();
//	this.SubmitOnce('form_');
}
function CopyStartYear(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.start_year_'+i+'.value=document.form_.start_year_1.value');			
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

function CopyStartDate(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.start_date_'+i+'.value=document.form_.start_date_1.value');			
}

function CopyLength(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.length_'+i+'.value=document.form_.length_1.value');			
}

function ShowAll(){
	document.form_.show_list.value= "1";
	document.form_.submit();
}

function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
		
//		alert (document.form_.jump_to.length);
//		alert (document.form_.jump_to.selectedIndex);		
		
		if (document.form_.jump_to.selectedIndex == document.form_.jump_to.length-1){
			document.form_.jump_to.selectedIndex--;	
		}
	}
	document.form_.submit();
}

 
function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}
function showList() {
	document.form_.showlist.value = '1';
	ReloadPage();
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
//	document.form_.submit();
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

function DeleteRecord(){
  var vProceed = confirm('Remove selected records?');
  if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.show_list.value = "1";
		document.form_.delete_btn.disabled = true;
 		this.SubmitOnce("form_");
  }	
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iCtr = 0;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel","leave_interval_start.jsp.jsp");
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
int iAccessLevel = -1;
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","PERSONNEL",request.getRemoteAddr(),
											"leave_interval_start.jsp.jsp");
 
														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home",
						"../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
int i = 0;

HRLeaveSetting hrInfo = new HRLeaveSetting();
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
String[] astrSortByName = {"Employee ID","Firstname","Lastname",strTemp,
													 "Department","Date of Employment"};
String[] astrSortByVal  = {"id_number","user_table.fname","lname","c_name","d_name","doe"};
String strBasis = WI.getStrValue(WI.fillTextValue("start_basis"), "0");

if (WI.fillTextValue("page_action").equals("1")){
	if (hrInfo.operateOnStartOfLeaveInterval(dbOP, request, 1) == null) 
		strErrMsg = hrInfo.getErrMsg();
}else if (WI.fillTextValue("page_action").equals("0")){
	if (hrInfo.operateOnStartOfLeaveInterval(dbOP, request, 0) == null) 
		strErrMsg = hrInfo.getErrMsg();
}
int iSearchResult = 0;
if(WI.fillTextValue("show_list").length() > 0) {
	int iTemp = 0;
	vRetResult = hrInfo.operateOnStartOfLeaveInterval(dbOP, request, 4);
	if (vRetResult == null) 
		strErrMsg = hrInfo.getErrMsg();
	else 	
		iSearchResult = hrInfo.getSearchCount();
}
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./leave_interval_start.jsp" method="post" name="form_">
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="3" align="center"><font color="#FFFFFF" ><strong>:::: LEAVE MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="97%"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
      <td><select name="c_index" onChange="loadDept();">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
      </select></td>
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
		<!--
		<%//if(bolHasTeam){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Team</td>
      <td colspan="3"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
		<%//}%>
		-->
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10">
			<input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" 
			class="textbox"onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			size="16" style="font-size:12px">
(enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td height="10" width="3%">&nbsp;</td>
      <td width="19%">Employee ID </td>
      <td width="78%">
			<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
			onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"
			style="font-size:12px"><label id="coa_info" style="position:absolute;width:400px;"></label>			</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Leave Type</td>
      <td><select name="benefit_index">
         <%=dbOP.loadCombo("benefit_index","sub_type"," from  hr_benefit_incentive " +
		 " join hr_preload_benefit_type on (hr_preload_benefit_type.benefit_type_index = hr_benefit_incentive.benefit_type_index)" +
		 " where is_benefit = 0 and benefit_name = 'leave' and is_valid = 1",WI.fillTextValue("benefit_index"),false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2">Entry Type  :
        <select name="start_basis" onChange="ShowAll();">
          <option value="0">Based on Year</option>
          <%if (strBasis.equals("1")){%>
          <option value="1" selected>Length of Service</option>
          <%}else{%>
          <option value="1">Length of Service</option>
          <%}if (strBasis.equals("2")){%>
          <option value="2" selected>Start Date</option>
          <%}else{%>
          <option value="2">Start Date</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with schedule for selected leave
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0" <%=strTemp%> onClick="ReloadPage();">
View Employees w/out schedule</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        
        View ALL Result in single page</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"><table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=hrInfo.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=hrInfo.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=hrInfo.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr> 
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
  </table></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td colspan="2"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ShowAll();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/hrInfo.defSearchSize;		
	if(iSearchResult % hrInfo.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td height="20" colspan="9" align="center" bgcolor="#B9B292" class="thinborder"><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="ShowAll();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() == 0) strTemp = "0";

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
		<%}
		}%>
    <tr> 
      <td height="20" colspan="9" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td> 
      <td width="30%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">EMPLOYMENT DATE </font></strong></td>
      <%if(strBasis.equals("2")){%>
			<td width="15%" align="center" class="thinborder"><strong><font size="1">START DATE<a href="javascript:CopyStartDate();"><br>
		  Copy</a></font></strong></td>
			<%}else if(strBasis.equals("0")){%>
 			<td width="11%" align="center" class="thinborder"><strong><font size="1">START YEAR<br>
      <a href="javascript:CopyStartYear();">Copy all</a> </font></strong></td>
			<%}else{%>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">LENGTH OF SERVICE<br>
      <a href="javascript:CopyLength();">Copy</a></font></strong></td>
			<%}%>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=20,iCount++){
		 %>
    <tr>
      <input type="hidden" name="info_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+10)%>">
			<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="hidden" name="emp_id_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="emp_doe_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">			
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%> </td>
			<%if(strBasis.equals("2")){%>
			<%
				if(WI.fillTextValue("with_schedule").equals("1"))
					strTemp = (String)vRetResult.elementAt(i+8);
				else
					strTemp = (String)vRetResult.elementAt(i+7);
				strTemp = WI.getStrValue(strTemp);
			%>
			<td align="center" class="thinborder"><input name="start_date_<%=iCount%>" type="text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" 
					 onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="11" maxlength="10" style="font-size:9px">
        <a href="javascript:show_calendar('form_.start_date_<%=iCount%>');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
			<%}else if(strBasis.equals("0")){%>
 		  <%
			strTemp = "";
			if(!WI.fillTextValue("copy_all").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 9);
			else{
				if(WI.fillTextValue("copy_all").equals("1"))
					strTemp = WI.fillTextValue("start_year_1");
			}
			strTemp = WI.getStrValue(strTemp);
 		%>			
      <td align="center" class="thinborder"><strong>
      <input name="start_year_<%=iCount%>" type= "text" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"			
			onKeyUp="AllowOnlyIntegerExtn('form_','start_year_<%=iCount%>','/')" 
			value="<%=strTemp%>" size="5" style="font-size:12px;text-align:right" maxlength="4">
      <a href="javascript:show_calendar('form_.start_year_<%=iCount%>');" 
				title="Click to select date" onMouseOver="window.status='Select date';return true;" 
				onMouseOut="window.status='';return true;"> </a></strong></td>
			<%}else{%>
			<%
 				strTemp = (String)vRetResult.elementAt(i + 11);
				strTemp = WI.getStrValue(strTemp);
			%>
       <td align="center" class="thinborder"><strong>
       <input name="length_<%=iCount%>" type= "text" class="textbox" 
	  		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"			
			onKeyUp="AllowOnlyInteger('form_','length_<%=iCount%>')" 
			value="<%=strTemp%>" size="3" style="font-size:12px;text-align:right" maxlength="2">
      </strong></td>
			 <%}%>
       <td align="center" class="thinborder">        
			<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">			</td>
    </tr>
    <%} //end for loop%>
    
    <tr>
      <td height="32" colspan="9" align="center">
				<%if(iAccessLevel > 1){%>
				<!--
					<a href='javascript:SaveData();'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>
         <%if((WI.fillTextValue("with_schedule")).equals("1") && iAccessLevel == 2){%>
				<input type="button" name="delete_btn" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
				<font size="1">Click to delete selected </font>
        <%}%>				
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
				  <font size="1"> click to cancel or go previous</font>
					<%}%>			</td>
    </tr>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	<%}%>
   <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="max_display"  value="<%=iCtr%>">
<input type="hidden" name="reload_page">
<input type="hidden" name="show_list">
<input type="hidden" name="copy_all">		
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
