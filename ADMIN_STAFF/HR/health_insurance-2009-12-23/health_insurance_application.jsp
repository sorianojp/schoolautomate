<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInsuranceTracking" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(6);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Health Insurance Application</title>
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
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function CopyInsuranceName(){
	document.form_.insurance_name.value = document.form_.hr_benefit_type[document.form_.hr_benefit_type.selectedIndex].text;
}

function ReloadPage()
{
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	document.form_.submit();
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	var bolIsSelAll = document.form_.selAllSave.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function PrintPg() {
	document.form_.print_page.value = "1";
	document.form_.submit()
}

function DeleteRecord(){
	var vProceed = confirm('Remove selected records?');
	if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}	
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.submit();
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.submit()
}

function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2 ) {
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
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing
}

function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./health_insurance_application_print.jsp" />
	<% 
		return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-PERSONNEL"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}	
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null){
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Personnel-Health Insurance Application","health_insurance_application.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	HRInsuranceTracking hriTracker = new HRInsuranceTracking();
	int iSearchResult = 0;
	int i = 0;
	
	String strWithSched = WI.getStrValue(WI.fillTextValue("with_benefits"),"1");

	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
		
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
	
	String[] astrBalanceCon    = {"Equal to","Less Than","Greater Than"};
	String[] astrBalanceVal    = {"=","<","'>'"};
		
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(hriTracker.operateOnHealthInsuranceTracking(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = hriTracker.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Insurance successfully added";		
			if(strPageAction.equals("0"))
				strErrMsg = "Insurance successfully removed.";	
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	    vRetResult = hriTracker.searchHealthInsurances(dbOP,request);
		if(vRetResult == null && strPageAction.length()==0)
			strErrMsg = hriTracker.getErrMsg();
		else
			iSearchResult = hriTracker.getSearchCount();
	}	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="CopyInsuranceName()">
<form action="health_insurance_application.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: HEALTH INSURANCE APPLICATION PAGE ::::</strong></font>
			</td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td><a href="health_insurance_tracking.jsp" ><img src="../../../../images/go_back.gif" border="0" align="right"></a></td>
			<td width="50">&nbsp;</td>
		</tr>
		<tr>
			<td>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font>
			</td>
			<td width="50">&nbsp;</td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Year</td>
			<td colspan="2">
				<select name="year_of">
					<%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
				</select></td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="20%">Benefit</td>
			<td colspan="2">
			<%
				strTemp =  " from hr_benefit_incentive where coverage_unit = 2 order by sub_type";
				strErrMsg = WI.fillTextValue("hr_benefit_type");
			%>
				<select name="hr_benefit_type" size="1" id="hr_benefit_type" onChange="CopyInsuranceName()">
					<%=dbOP.loadCombo("benefit_index","sub_type",strTemp,strErrMsg,false)%>
				</select></td>
		</tr>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Status</td>
			<td colspan="2">
				<select name="pt_ft" onChange="ReloadPage();">
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
				</select>			</td>
		</tr>
		<%if(bolIsSchool){%>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Employee Category</td>
			<td colspan="2">
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
				</select>			</td>
		</tr>
		<%}%>
		<% 	
			String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
		<tr> 
			<td height="24">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<td colspan="2">
				<select name="c_index" onChange="ReloadPage();">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
				</select></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Department/Office</td>
			<td colspan="2">
				<select name="d_index" onChange="ReloadPage();">
					<option value="">ALL</option>
					<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
					<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
					<%}%>
				</select>			</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
			<td height="10">Employee ID </td>
			<td width="25%" height="10">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();">
					<a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a>
		  </td>
		    <td width="52%" height="10" valign="middle"><label id="coa_info"></label>&nbsp;</td>
	    </tr>
		<tr> 
			<td height="10" colspan="4"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
			<td height="10" colspan="4">OPTION:</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
		  	<td height="10" colspan="3">
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("with_benefits"),"1");
				if(strTemp.compareTo("1") == 0) {
					strTemp = " checked";
					strErrMsg = "";
				}
				else {
					strTemp = "";	
					strErrMsg = " checked";
				}
			%>
			<input type="radio" name="with_benefits" value="1"<%=strTemp%> onClick="ReloadPage();"> View Employees With Benefits
		    <input type="radio" name="with_benefits" value="0"<%=strErrMsg%> onClick="ReloadPage();"> View Employees w/out Benefits </td>
		</tr>
		<tr>
			<td height="10">&nbsp;</td>
			<td height="10" colspan="3">
			<%
				if(WI.fillTextValue("view_all").length() > 0)
					strTemp = " checked";				
				else
					strTemp = "";
			%>
			<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> View ALL</td>
		</tr>
		<%
			if(WI.getStrValue(WI.fillTextValue("with_benefits"),"1").equals("1")){
		%>
		<tr>
			<td height="10">&nbsp;</td>
			<td height="10" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="10">&nbsp;</td>
			<td height="10" colspan="3">
				BALANCE &nbsp;&nbsp;
				<select name="balance_checker">
					<%=hriTracker.constructSortByDropList(WI.fillTextValue("balance_checker"),astrBalanceCon,astrBalanceVal)%>
      			</select>
				&nbsp;&nbsp;
				<%	
					strTemp = WI.fillTextValue("check_balance_field");
					strTemp = ConversionTable.replaceString(strTemp, ",", "");
				%>
				<input type="text" name="check_balance_field" value="<%=strTemp%>" class="textbox" size="16" 
					onfocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyFloat('form_','check_balance_field')"
					onBlur="AllowOnlyFloat('form_','check_balance_field');style.backgroundColor='white'">
			</td>
		</tr>
		<tr>
			<td height="10">&nbsp;</td>
			<td height="10" colspan="3">&nbsp;</td>
		</tr>	
		<%}%>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr> 
      		<td width="3%" height="29">&nbsp;</td>
      		<td>SORT BY :</td>
      		<td height="29">
				<select name="sort_by1">
        			<option value="">N/A</option>
					<%=hriTracker.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      			</select>
			</td>
      		<td height="29">
				<select name="sort_by2">
        			<option value="">N/A</option>
					<%=hriTracker.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select>
			</td>
	      	<td height="29">
				<select name="sort_by3">
        			<option value="">N/A</option>        
					<%=hriTracker.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      			</select>
			</td>
    	</tr>
    	<tr> 
      		<td height="15">&nbsp;</td>
      		<td width="11%" height="15">&nbsp;</td>
      		<td>
				<select name="sort_by1_con">
       				<option value="asc">Ascending</option>
        			<%
						if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        					<option value="desc" selected>Descending</option>
        				<%}else{%>
        					<option value="desc">Descending</option>
        				<%}%>
      			</select>
			</td>
      		<td>
				<select name="sort_by2_con">
        			<option value="asc">Ascending</option>
        			<%
						if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
				</select>
			</td>
			<td>
				<select name="sort_by3_con">
					<option value="asc">Ascending</option>
					<%
						if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
				</select>
			</td>
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
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
				onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
		</tr>
  	</table>    
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>   
		<% if (vRetResult != null && vRetResult.size() > 0 ){%>
			<td height="10" colspan="2"><div align="right"><font size="2">Number of Employees / rows Per Page :</font><font>
				<select name="num_rec_page">
				<% int iDefault = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
					for(i = 10; i <=40 ; i++) {
						if ( i == iDefault) {%>
							<option selected value="<%=i%>"><%=i%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%></option>
				<%}}%>
				</select>
				<a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
				<font size="1">click to print</font></font></div></td>
		<%}%>
		</tr>
		<%
			int iPageCount = 1;
			if(vRetResult!=null && vRetResult.size() > 0){
				if(WI.fillTextValue("view_all").length() == 0){
					iPageCount = iSearchResult/hriTracker.defSearchSize;		
					if(iSearchResult % hriTracker.defSearchSize > 0) 
						++iPageCount;
					strTemp = " - Showing("+hriTracker.getDisplayRange()+")";
				}
				else
					strTemp = " - Showing All";
		%>
			<td><strong>TOTAL RESULT: <%=iSearchResult%><%=strTemp%></strong></td>
		<%}
			if(iPageCount > 1){
		%>
		    <td><div align="right"><font size="2">Jump To page:
				<select name="jumpto" onChange="SearchEmployee();">
				<%
					strTemp = request.getParameter("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
				}%>
				</select>
				</font></div></td>
		</tr>
		<%}%>
	</table>
<% if (vRetResult != null &&  vRetResult.size() > 0) {
boolean bolIsWthBenefit = WI.fillTextValue("with_benefits").equals("1");
%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="8" bgcolor="#B9B292" class="thinborder" align="center"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
    	<tr>
			<td width="3%"  class="thinborder" align="center" height="23"><strong><font size="1">SL#</font></strong></td>
			<td width="8%"  class="thinborder" align="center"><strong><font size="1">EMP. ID</font></strong></td> 
			<td width="31%" class="thinborder" align="center"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
			<td width="29%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
			<%if(bolIsWthBenefit){%>
			<td width="12%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
			<td width="9%"  class="thinborder" align="center"><strong><font size="1">BALANCE </font></strong></td>
			<%}%>
			<td width="8%"  class="thinborder" align="center">
				<font size="1"><strong>SELECT ALL<br></strong>
        		<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font>			</td>
    	</tr>
    	<% 
			int iCount = 1;
	   		for (i = 0; i < vRetResult.size(); i+=10,iCount++){
		%>
    	<tr>
      		<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      		<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
	  			<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
					(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
				<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
				<input type="hidden" name="info_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+9)%>">
				<%
					if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
      		<td class="thinborder">&nbsp;
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>
			</td>
		<%if(bolIsWthBenefit){%>
	   		<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 7), true)%> </td>	
      		<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 8), true)%></td>
		<%}%>
     		<td align="center" class="thinborder">        
				<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">			</td>
    	</tr>
    	<%} //end for loop%>
    </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td>&nbsp;</td>
		</tr>
    	<tr>
      		<td height="25" colspan="8"><div align="center">
				<%if(!bolIsWthBenefit && iAccessLevel > 1){%>
					<a href="javascript:SaveData();"><img src="../../../../images/save.gif" border="0"></a> 
					<font size="1">Click to save entries</font>
            	<%}if(bolIsWthBenefit && iAccessLevel == 2){%>
					<a href="javascript:DeleteRecord();"><img src="../../../../images/delete.gif" border="0"></a> 
					<font size="1">Click to delete selected </font>
          		<%}%>
				<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
				<font size="1"> click to cancel or go previous</font></div>			</td>
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
	<input type="hidden" name="insurance_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>