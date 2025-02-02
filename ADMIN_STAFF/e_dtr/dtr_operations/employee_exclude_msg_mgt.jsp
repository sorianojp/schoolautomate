<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour, payroll.PayrollConfig" buffer="16kb"%>
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
<title>Employee Late/UT Error Message Posting Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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

TD.noBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.smallFont{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

TD.smallFontTop{
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function SearchEmployee(){	
	document.form_.searchEmployee_.value="1";
	document.form_.print_page.value=""; 	
	this.SubmitOnce("form_");
}

function ReloadPage(){
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
	location ="./employee_ndf_management.jsp";
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


//select all to delete
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


function SaveRequests(){
	document.form_.page_action.value = "1";
	//document.dtr_op.viewAll.value="1";
	document.form_.submit();
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
	boolean bolCheckDate = false;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="employee_allowances_print.jsp" />
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
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Variable Allowance-Variable Allowance Management","employee_allowances.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolAllowOverride = (readPropFile.getImageFileExtn("ALLOWANCE_OVERRIDE","0")).equals("1");
		bolCheckDate = (readPropFile.getImageFileExtn("CHECK_ALLOWANCES_DATE","0")).equals("1");
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
	WorkingHour WH = new WorkingHour();
 	
 	String strPageAction = WI.fillTextValue("page_action");
	String strTemp2 = null;
	String strEmpCatg = null;
	String[] astrCategory = {"Staff","Faculty","Employees"};
	String[] astrStatus = {"Part-Time","Full-Time","Contractual",""}; 
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
	boolean bolHasItems = false;
	int iCount = 1;
	int i = 0;
	int iSearchResult = 0;
	boolean bolFixed = false;	
	double dTemp = 0d;
	String strLine = null;
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		vRetResult = WH.operateOnLateUTErrMsgExcludeList(dbOP, request, Integer.parseInt(strTemp));
		if(vRetResult == null)
			strErrMsg = WH.getErrMsg();
		else
			strErrMsg = "Operation Succesful";
	}
		 	
	if(WI.fillTextValue("searchEmployee_").length() > 0){
		vRetResult = WH.operateOnLateUTErrMsgExcludeList(dbOP,request,4);
		
		if (vRetResult == null){
			strErrMsg = WH.getErrMsg();	
		}else{
			iSearchResult = WH.getSearchCount();
		}
	}		
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="employee_exclude_msg_mgt.jsp" name="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      EDTR: EMPLOYEE LATE/UT AND LACKING TIMEOUT MESSAGE MANAGEMENT ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0"> 
  	<tr> 
      <td height="28" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>  
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee ID </td>
			<%
				strTemp = WI.fillTextValue("emp_id");
			%>
      <td colspan="3"><input name="emp_id" type="text" class="textbox" value="<%=WI.getStrValue(strTemp,"")%>" size="16" maxlength="16"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
			<label id="coa_info"></label></td>
   </tr>
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
  <% String strCollegeIndex = WI.fillTextValue("c_index");%>
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
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters) </td>
    </tr>
    <tr>
      <td height="11" colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td height="11" colspan="5">OPTION:</td>
    </tr> 
	 <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				strTemp = WI.fillTextValue("without_err");
				strTemp = WI.getStrValue(strTemp,"1");
				if(strTemp.compareTo("1") == 0) 
					strTemp = " checked";
				else	
					strTemp = "";	
			%>
        <input type="radio" name="without_err" value="1"<%=strTemp%> onClick="ReloadPage();">
View Employees without Error message 
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="without_err" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees with Error message </td>
    </tr>   
    <tr>
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
      <td height="24" colspan="5"><input name="view_all" type="checkbox" value="1"<%=strTemp%>>View ALL</td>
    </tr> 
  </table>	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=WH.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=WH.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=WH.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
  
 <% if (vRetResult != null && vRetResult.size() > 0) {%> 
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
                  <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></div></td>
      <%}%>
    </tr>
    <%	
	if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/WH.defSearchSize;		
	if(iSearchResult % WH.defSearchSize > 0) ++iPageCount;	
	if(iPageCount > 1){	
	%>
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
    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#B9B292"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr> 
      <td width="2%" height="24" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="9%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE ID </strong></font></td>
      <td width="20%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td width="31%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>DEPARTMENT/OFFICE </strong></font></td>	  

		 <td width="16%" height="24" align="center" class="thinborderBOTTOMRIGHT">
	   		<font size="1">
				<strong>SELECT ALL<br />
					<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
			</strong>
		   </font>
	  </td>	  
    </tr>
    <% 
		int j = 0;
		for (i = 0; i< vRetResult.size() ; i+=7, iCount++) {
		%>
    <tr> 
      <td height="25" align="center" class="thinborderBOTTOMLEFTRIGHT">
	  	<span class="thinborderTOPLEFT"><%=iCount%>
			<input type="hidden" name="user_<%=iCount%>" value="<%=vRetResult.elementAt(i)%>">
			<input type="hidden" name="emp_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">	
		</span>
	</td>
			<td class="thinborderBOTTOMRIGHT"><span class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></span></td>
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>       						
			<td class="thinborderBOTTOMRIGHT">
				<span class="thinborder">
					&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>
				</span>
			</td>	 
	  <td width="16%" height="24" align="center" class="thinborderBOTTOMRIGHT">
			<%
				strTemp = WI.fillTextValue("save_"+iCount);
				if(strTemp.length() > 0)
					strTemp = " checked";
				else
					strTemp = "";
			%>
			<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>>		
	  </td>	 
	</tr>
    <%}// end for loop%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table> 
  
  <!---------------- start of buttons -------------->
   <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="7" align="center">

			<%if((WI.fillTextValue("without_err")).equals("1")){
					if(iAccessLevel == 2){%>
				<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord();">
				<font size="1">Click to delete selected </font>
				<%}
				}else{
					if(iAccessLevel > 1){%>				
        <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRequests();">
        <font size="1">click to save entries</font>			  
        <%}
				}%>
        <input type="button" name="1223" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
        <font size="1"> click to cancel</font>			</td>
    </tr>   
  </table>
  
  <!-- end of buttons -->
   <%}//end vRetResult != null%>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="print_page">
<input type="hidden" name="searchEmployee_"> 
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>