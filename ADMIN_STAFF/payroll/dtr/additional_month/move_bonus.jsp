<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
boolean bolHasConfidential = false;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Bonus Forwarding</title>
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
function SearchEmployee(){
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	document.form_.bonus_name.value = document.form_.pay_index[document.form_.pay_index.selectedIndex].text;	
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

function loadSalPeriods() {
		var strMonth = document.form_.month_of.value;
		var strYear = document.form_.year_of.value;
		var strWeekly = null;
		
		if(document.form_.is_weekly){
			if(document.form_.is_weekly.checked)
				strWeekly = "1";
			else
				strWeekly = "";
		}
		
		var objCOAInput = document.getElementById("sal_periods");
		
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
								 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=SearchEmployee()";

		this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PRAddlPay, payroll.PReDTRME" %>
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
	<jsp:forward page="./bonus_emplist_print.jsp" />
	<% 
return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Forward Bonus to Salary","move_bonus.jsp");
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
														"PAYROLL","DTR",request.getRemoteAddr(),
														"move_bonus.jsp");
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

PRAddlPay prAddl = new PRAddlPay();
Vector vRetResult = null;
String strSchCode = dbOP.getSchoolIndex();
String strPageAction = WI.fillTextValue("page_action");
String[] astrCategory = {"Staff","Faculty","Employees"};
String[] astrStatus = {"Part-Time","Full-Time",""};
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
String[] astrSortByName    = {"Employee ID",strTemp, "Department/Office"};
String[] astrSortByVal     = {"id_number","c_name","d_name"};
int i = 0;

if(strPageAction.length() > 0){
	if(prAddl.operateOnBonusMove(dbOP,request,Integer.parseInt(strPageAction)) == null){
		strErrMsg = prAddl.getErrMsg();
	} else {
		if(strPageAction.equals("1"))
			strErrMsg = "Bonus successfully forwarded to salary.";		
		if(strPageAction.equals("0")){
			strErrMsg = "Bonus successfully removed.";		
		}			
	}
}

  if(WI.fillTextValue("searchEmployee").equals("1")){
	vRetResult = prAddl.operateOnBonusMove(dbOP,request, 4);
	  if(vRetResult == null && strErrMsg == null)
			strErrMsg = prAddl.getErrMsg();
	  else
			iSearchResult = prAddl.getSearchCount();

  }

Vector vSalaryPeriod = null;//detail of salary period.
PReDTRME prEdtrME = new PReDTRME();
String strTemp2  = null;
vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);   
if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./move_bonus.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: BONUS FORWARDING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td><select name="month_of" onChange="loadSalPeriods();">
        <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%>
      </select>
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Salary Period</td>
      <td><label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="SearchEmployee();">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");
		
		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10){
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
			
			if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
          <%}//end of if condition.
		 }//end of for loop.%>
        </select>
        </label></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="20%">Additional pay name </td>
      <%
		 strTemp = WI.fillTextValue("pay_index");
	  %>
      <td><select name="pay_index">
          <option value="">Select Additional Pay </option>
          <%=dbOP.loadCombo("pay_index","pay_name", " from pr_addl_pay_mgmt " +
		" where is_valid = 1 and is_del = 0 and is_verified = 1 " +
		" and year = " + WI.getStrValue(WI.fillTextValue("year_of"),"0"), strTemp,false)%> </select></td>
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
    <tr>
      <td height="24">&nbsp;</td>
      <td>Position</td>
      <td><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
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
      <td> <select name="employee_category" onChange="ReloadPage();">
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
      <td><%if(bolIsSchool){%>
        College 
        <%}else{%>
        Division 
        <%}%></td>
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
													" 	and user_index = " + strAuthID + ") order by group_name", WI.fillTextValue("group_index"), false)%> </select></td>
    </tr>
    <%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee ID </td>
      <td><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);"> 
        <label id="coa_info"></label></td>
    </tr>		
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
%> <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
        Bonus already forwarded to salary
        <%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%> <input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
        Bonus not yet forwarded to salary </td>
    </tr>
    <tr> 
      <td height="11" colspan="3"><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%> <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
        View ALL </td>
    </tr>
   </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :<strong></strong></td>
      <td height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%=prAddl.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=prAddl.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=prAddl.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
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
        <font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<% if(vRetResult != null && vRetResult.size() > 0  ) {%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/prAddl.defSearchSize;		
	if(iSearchResult % prAddl.defSearchSize > 0) ++iPageCount;
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
	    strTemp = "EMPLOYEES WITH ADDITIONAL PAY";
	  else
	    strTemp = "EMPLOYEES WITHOUT ADDITIONAL PAY";
	  
	  %>
      <td height="23" colspan="5" align="center"><strong><%=strTemp%></strong></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td width="12%" align="center" class="thinborder"><strong>EMPLOYEE 
        ID </strong></td>
      <td width="34%" height="25" align="center" class="thinborder"><strong>EMPLOYEE 
        NAME </strong></td>
      <td class="thinborder" width="36%" align="center"><strong>OFFICE</strong></td>
      <td class="thinborder" width="9%" align="center"><strong>AMOUNT</strong></td>
      <td align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
        </strong> 
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
        </font></td>
    </tr>
    <% int iCount = 1;
		for(i = 0; i < vRetResult.size(); i += 15,iCount++){		
		%>	
		<input type="hidden" name="emp_bonus_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+10)%>">
    <input type="hidden" name="user_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
		
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <%
		strTemp = (String)vRetResult.elementAt(i+1);
	  %>
			<input type="hidden" name="user_id_<%=iCount%>" value="<%=strTemp%>">
      <td class="thinborder" >&nbsp;<%=strTemp%><input type="hidden" name="is_released_<%=iCount%>" value="<%=vRetResult.elementAt(i+11)%>"></td>
      <%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+10));
	  %>
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
		  	strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7), true);
		  %>			
      <td align="right" class="thinborder" ><%=strTemp%>&nbsp;</td>
			<input type="hidden" name="amount_<%=iCount%>" value="<%=strTemp%>">
      <%
				strTemp2 = "1";
			
		  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+9),"0");
				if(vRetResult.elementAt(i+11) != null && ((String)vRetResult.elementAt(i+11)).equals("1")){
 					strTemp2 = "0";						
				} else if((String)vRetResult.elementAt(i+8) != null || Double.parseDouble(strTemp) > 0d){
 					strTemp2 = "0";
				}
		  %>
      <td width="9%" align="center" class="thinborder"> 
				<%if(strTemp2.equals("1")){%> 
				<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"> 
        <%}else{%>
        n/a 
        <%}%> </td>
    </tr>
    <%} // end for loop%>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>  
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" align="center" bgcolor="#FFFFFF">
				<%if(iAccessLevel > 1){%>
				<!--
				<a href='javascript:SaveData();'><img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
				-->
          <%if((WI.fillTextValue("with_schedule")).equals("1")){%>
					<%if(iAccessLevel == 2){%>
					<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
					<font size="1">Click to delete selected </font>
					<%}%>
        <%}else{%>
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
				<font size="1">Click to save entries</font>				
				<%}%>
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;"
				onClick="javascript:CancelRecord();">				
				<font size="1"> click to cancel or go previous</font>
				<%}%>
			</td>
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
  <input type="hidden" name="reset_page">
	<input type="hidden" name="bonus_name" value="<%=WI.fillTextValue("bonus_name")%>">
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>