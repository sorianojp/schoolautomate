<%@ page language="java" import="utility.*, java.util.Vector, payroll.PayrollSheet" %>
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
<title>Faculty Salary Type</title>
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
	document.form_.submit();
//	this.SubmitOnce('form_');
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
	if(eval(vItems) > 21){
		document.form_.copy_all.value = "1";
		document.form_.print_page.value = "";
		document.form_.searchEmployee.value = "1";		
		this.SubmitOnce('form_');
	}else{
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.percent_'+i+'.value=document.form_.percent_1.value');			
	}
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
function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.order_no_'+i+'.value=document.form_.order_no_1.value');			
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Faculty Term Type","p_sheet_order.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();		
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"p_sheet_order.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PayrollSheet pSheet = new PayrollSheet(request);
	int iSearchResult = 0;
	int i = 0;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName = null;
	String[] astrSortByVal  = null;
	if(WI.fillTextValue("with_schedule").equals("1")){
		astrSortByName = new String[6];
		astrSortByVal = new String[6];
	}else{
		astrSortByName = new String[5];
		astrSortByVal = new String[5];	
	}
	astrSortByName[0] = "Employee ID";
	astrSortByName[1] = "Firstname";
	astrSortByName[2] = "Lastname";
	astrSortByName[3] = strTemp;
	astrSortByName[4] = "Department";

	astrSortByVal[0] = "id_number";
	astrSortByVal[1] = "user_table.fname";
	astrSortByVal[2] = "lname";
	astrSortByVal[3] = "c_name";
	astrSortByVal[4] = "d_name";
	if(WI.fillTextValue("with_schedule").equals("1")){
		astrSortByName[5] = "Order in Payroll Sheet";
		astrSortByVal[5] = "emp_order_no";
	}
	
	String strPageAction = WI.fillTextValue("page_action");

	if(strPageAction.length() > 0){
		if(pSheet.operateOnPSheetEmpOrder(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = pSheet.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Setting successfully posted.";		
			if(strPageAction.equals("0")){
				strErrMsg = "Setting successfully removed.";		
			}			
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = pSheet.operateOnPSheetEmpOrder(dbOP,request, 4);
		if(vRetResult == null)
			strErrMsg = pSheet.getErrMsg();
		else
			iSearchResult = pSheet.getSearchCount();
	}	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="p_sheet_order.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL :  PAYROLL SHEET ORDERING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="19%">Status</td>
      <td width="78%"><select name="pt_ft" onChange="ReloadPage();">
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
			</label>			</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Office/Dept filter</td>
      <td height="10"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
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
      <td height="10" colspan="2"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with set  order
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees without  set payroll sheet order </td>
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
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        View ALL </td>
    </tr>		
  </table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=pSheet.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=pSheet.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=pSheet.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
      <td height="10" colspan="3"><font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        click to display employee list to print.</font></td>
    </tr>
  </table>    
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <% if (vRetResult != null && vRetResult.size() > 0){%>
		<%
			if(WI.fillTextValue("with_schedule").equals("1")){
		%>
				
		<%}%>
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/pSheet.defSearchSize;		
	if(iSearchResult % pSheet.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td><div align="right">Jump To page:
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
      </div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
		<%}%>
  </table>
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"></td>
    </tr>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder">
      <td width="5%" class="thinborder">&nbsp;</td>
			<td width="11%" align="center" class="thinborder"><strong>EMPLOYEE ID </strong></td> 
      <td width="33%" height="25" align="center" class="thinborder"><strong>EMPLOYEE NAME </strong></td>
      <td width="32%" align="center" class="thinborder"><strong>OFFICE</strong></td>
 			<td width="8%" align="center" class="thinborder"><strong>ORDER # <br>
 			  <font size="1"><a href="javascript:CopyAll();">Copy all</a></font></strong></td>
       <td width="8%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <% int iCount = 1;
		for (i = 0; i < vRetResult.size(); i+=15,iCount++){ %>
    <tr>
      <td class="thinborder">&nbsp;<%=iCount%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 7);
				strTemp = WI.getStrValue(strTemp);
 			%>			
			<td align="center" class="thinborder">
			<input type="text" name="order_no_<%=iCount%>" size="5" maxlength="6" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"
	  onblur="AllowOnlyFloat('form_','order_no_<%=iCount%>');style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyFloat('form_','order_no_<%=iCount%>');"></td>
       <td align="center" class="thinborder"> <input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">      </td>
    </tr>
    <%} //end for loop%>
    <tr>
      <td height="20" colspan="6">Note : Employees who don't have any set order number will be displayed first. </td>
    </tr>
    <tr>
      <td height="14" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="6" align="center">
				<%if(iAccessLevel > 1){%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
          <font size="1"> click to save entries</font>
				<%}%>		
				<%if(iAccessLevel == 2 && WI.fillTextValue("with_schedule").equals("1")){%>
					<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					<font size="1">Click to delete selected </font>
				<%}%>
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
					<font size="1"> click to cancel or go previous</font>
			</td>
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