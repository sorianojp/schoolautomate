<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRSalaryRate, payroll.PRAllowances" %>
<%
	//added code for HR/companies.
	boolean bolIsSchool = false;
	WebInterface WI = new WebInterface(request);
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasConfidential = false;
	boolean bolHasTeam = false;
	String[] strColorScheme = {};
	
	if(WI.fillTextValue("from_pr").equals("1"))
		strColorScheme = CommonUtil.getColorScheme(6);
	else
		strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg()
{
	document.form_.print_page.value="1";
	document.form_.show_list.value="1";
	document.form_.show_all.value="1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.show_list.value="1";
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}


//  about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
//		var iframe = document.getElementById('iframetop');
		var layer_ = document.getElementById("processing_");
		var objCOAInput = document.getElementById("coa_info");
		 
		
		if(strCompleteName.length <=2) {
  		layer_.style.display = 'none';	
//		  iframe.style.display = 'none';
			objCOAInput.innerHTML = "";
			return ;
		}

		layer_.style.display = 'block';
//		iframe.style.display = 'block';

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
						 		 "&name_format=4&complete_name="+escape(strCompleteName);

		this.processRequest(strURL);
		
		//iframe.style.width = layer_.offsetWidth-5;	
		//iframe.style.height = layer_.offsetHeight-5;
 		//iframe.style.left = layer_.offsetLeft;
		//iframe.style.top = layer_.offsetTop;
  	//window.setTimeout("setHeight()", 500); 
		//alert("layerw " + (layer_.offsetWidth-5));
		//alert("layerh " + (layer_.offsetHeight-5));	
		//alert("iframew " + (iframe.style.width));
		//alert("iframeh " + (iframe.style.height));		
}
//function setHeight(){
//	if(document.getElementById("processing_"))
//	document.getElementById('iframetop').style.height = (document.getElementById("processing_").offsetHeight)-5;
//}
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

function UpdateSalaryRate(strEmpID) {
	var pgLoc = "./salary_rate.jsp?view=1&emp_id="+strEmpID;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./salary_rate_search_print.jsp" />
<% return;	}
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-SALARY RATE-Salary Rate Search","salary_rate_search.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasConfidential = (readPropFile.getImageFileExtn("HAS_CONFIDENTIAL","0")).equals("1");
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"PAYROLL","SALARY RATE",
											request.getRemoteAddr(),"salary_rate_search.jsp");
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


PRSalaryRate hrStat = new PRSalaryRate(request);
PRAllowances prAllow = new PRAllowances();

String[] astrSortByName    = {"Last Name","First Name","Tax Status", "Salary Period","Bank Code", "Account No"};
String[] astrSortByVal     = {"lname","fname","tax_status", "salary_period","bank_code", "bank_account"};
boolean[] abolShowList={false,false,false, false,false,false, false, false, false, false, false, false};
int iIndex =1;

String[] astrTaxStatus={" N / A","Z","S","HF","ME"};
String[] astrSalaryPeriod = {"N / A","Daily","Weekly","Bi-Monthly","Monthly"};
String[] astrExemptionName    = {"Zero", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};
String strStatus = null;
String strDependent = null;

boolean bolOneSelected = false;


for(; iIndex <= 10; iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
		abolShowList[iIndex] = true;
		if ( iIndex <= 5){
			bolOneSelected = true;
		}
	}
}

// force the basic monthly to be selected in case
// none of the rates is selected.. 
if(!bolOneSelected){
	abolShowList[1] = true;
}

Vector vRetResult = null;
Vector vAllowances = null;
int iIndexOf = 0;
Long lIndex = null;
if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.searchSalaryRate(dbOP, true);
	vAllowances = prAllow.getAppliedAllowanceToEmp(dbOP, request);
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
%>
<form action="./salary_rate_search.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="footerDynamic"><font color="#FFFFFF"><strong>:::: 
        SALARY RATE OF EMPLOYEES::::</strong></font></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">
			<%if(WI.fillTextValue("from_pr").equals("1")){%>
			<a href="./salary_rate_main.jsp">
			<img src="../../../images/go_back.gif" width="50" height="27" border="0">
			</a>
			<%}%>
			<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td width="3%" height="25"><strong><font color="#0000FF">&nbsp;Check Columns 
        To Show in the Report : </font> </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#E4EFFA">
    <tr>
      <td width="27%" height="18">&nbsp;</td>
      <td width="32%">&nbsp;</td>
      <td width="41%">&nbsp;</td>
    </tr>
    <tr>
      <td width="27%" height="21"><% iIndex = 1;
	  if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
          <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
        Basic Monthly </td>
      <td width="32%"><% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
          <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
      Daily Rate </td>
      <td width="41%"><% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
          <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
      Hourly Rate  &nbsp;&nbsp;
      <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%>
      <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
      Allowances</td>
    </tr>
		<%if(bolIsSchool){%>
    <tr>
      <td height="21">
			<%if (abolShowList[iIndex++])  
					strTemp = "checked";	
				else 
				strTemp = "";%>
          <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
        Teaching Rate</td>
      <td>
			<%if (abolShowList[iIndex++])  
					strTemp = "checked";
		  	else 
					strTemp = "";
			%>
          <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
        Overload Rate</td>
      <td>&nbsp;</td>
    </tr>
		<%}else{
			iIndex++;
			iIndex++;
		%>			
			<input type="hidden" name="checkbox<%=iIndex-1%>" value="">			
			<input type="hidden" name="checkbox<%=iIndex-1%>" value="" >
		<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#E4EFFA">
    <tr>
      <td height="10" colspan="3"><hr align="center" width="98%" size="1"></td>
    </tr>
    <tr>
      <td width="27%" height="10">
			<% if (abolShowList[iIndex++])  
					strTemp = "checked";
		  	else 
					strTemp = "";
			%>
        <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>> 
        Tax Status</td>
      <td width="32%">
			<%if (abolShowList[iIndex++])  
					strTemp = "checked";	  	
				else 
					strTemp = "";%>
        <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>> 
      Salary Period</td>
      <td width="41%">
			<% 
			if (abolShowList[iIndex++])  
				strTemp = "checked";
	  	else 
				strTemp = "";
			%>
        <input type="checkbox" name="checkbox<%=iIndex-1%>" value="1" <%=strTemp%>>
Bank Info and Acct. No</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td width="16%" height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Employee ID </td>
      <td width="38%"><input name="emp_id" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16"></td>
      <td width="46%">
				<!--
				<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;">
				</iframe>
				-->
				<div style="position:absolute; overflow:auto; width:300px; height:225px; display:none;" id="processing_">
				<label id="coa_info"></label>
				</div>				
			</td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td colspan="2"><select name="d_index">
        <option value=""> &nbsp;</option>
        <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
        <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%>
      </select></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Tax Status</td>
	  <%
			strTemp = WI.fillTextValue("tax_status");
		%>
      <td colspan="2"><select name="tax_status">
        <option value="">ALL</option>
        <%for(int i = 0; i <= 11; ++i){
				if(astrExemptionVal[i].equals(strTemp)){%>
        <option selected value="<%=astrExemptionVal[i]%>"><%=astrExemptionName[i]%></option>
        <%}else{%>
        <option value="<%=astrExemptionVal[i]%>"> <%=astrExemptionName[i]%></option>
        <%}
			}%>
      </select></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10">&nbsp;Salary Period </td>
      <td colspan="2"><select name="salary_period">
        <option value="">ALL </option>
        <% strTemp =  WI.fillTextValue("salary_period");
		  if(strTemp.equals("1")){%>
        <option value="0" selected>Daily</option>
        <%}else{%>
        <option value="0">Daily</option>
        <%}if(strTemp.equals("1")){%>
        <option value="1" selected>Weekly</option>
        <%}else{%>
        <option value="1">Weekly</option>
        <%}if(strTemp.equals("2")) {%>
        <option value="2" selected>Bi-monthly</option>
        <%}else{%>
        <option value="2">Bi-monthly</option>
        <%}if(strTemp.equals("3")) {%>
        <option value="3" selected>Monthly</option>
        <%}else{%>
        <option value="3">Monthly</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="25" class="fontsize10"> &nbsp;Show Records </td>
      <td colspan="2"><select name="show_records">
        <option value="">With Salary Rate Only </option>
        <% strTemp =  WI.fillTextValue("show_records");
		  if(strTemp.equals("1")){%>
        <option value="1" selected>No Salary Rate</option>
        <%}else{%>
        <option value="1">No Salary Rate</option>
        <%}%>
      </select></td>
    </tr>
<%if(bolHasConfidential){%>
    <tr>
      <td height="10">Process option </td>
			<%
			String strAuthID = (String) request.getSession(false).getAttribute("userIndex");
			if(strAuthID == null || strAuthID.length() == 0)
				strAuthID = "0";				
			%>					
      <td colspan="2"><select name="group_index">
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
      <td>Team</td>
      <td colspan="2">
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>
      </td>
    </tr>
		<%}%>		
    <tr> 
      <td height="14" colspan="3" class="fontsize10"><hr size="1" noshade></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="12" colspan="5"></td>
    </tr>
    <tr> 
      <td  width="3%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="20%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="22%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="43%"><select name="sort_by3">
          <option value="">N/A</option>
      <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
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
      <td height="18" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">
<% if (WI.fillTextValue("show_all").length() > 0) strTemp = "checked";
else strTemp ="";%>	  
	  <input type="checkbox" name="show_all" value="1" <%=strTemp%>>Check to show all </td>
      <td height="25" align="right">&nbsp;	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292" align="center">
	  	<strong><font color="#FFFFFF">SEARCH RESULT</font></strong></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> 
	  	<% if (WI.fillTextValue("show_all").length() == 0) {%>
			 - Showing(<%=hrStat.getDisplayRange()%>)
		<%}%>
			 </b></td>
      <td width="51%" align="right">&nbsp;
        <%
		if (WI.fillTextValue("show_all").length() == 0){
		
			int iPageCount = iSearchResult/hrStat.defSearchSize;
			if(iSearchResult % hrStat.defSearchSize > 0) ++iPageCount;

			if(iPageCount > 1)
			{%>
Jump To page: 
        <select name="jumpto" onChange="showList();">
          <%
				strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
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
	          <%}
		  }// end if (WI.fillTextValue("show_all")%>	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
          <td width="14%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE 
            NAME</strong></font></td>
      <td width="7%" align="center"  class="thinborder"><font size="1"><strong>UNIT</strong></font></td>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <% iIndex = 1; if (abolShowList[iIndex++]){%>
      <td width="6%" class="thinborder"><strong><font size="1">&nbsp;BASIC</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" class="thinborder"><strong><font size="1">&nbsp;DAILY</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" class="thinborder"><font size="1"><strong>&nbsp;HOURLY</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>
      <td width="10%" class="thinborder"><font size="1"><strong>ALLOWANCES</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><font size="1"><strong>&nbsp;TEACHING</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="5%" align="center" class="thinborder"><strong><font size="1">&nbsp;OVER<br>
      LOAD</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>TAX<br>
      STATUS</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>SALARY PERIOD </strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="15%" class="thinborder"><font size="1"><strong>BANK INFO </strong></font></td>
      <%}%>
    </tr>
    <% 
		for (int i=0; i < vRetResult.size(); i+=25){
		iIndex = 1;
		lIndex = (Long)vRetResult.elementAt(i+16);
	%>
    <tr> 
      <td height="25" class="thinborder"><a href="javascript:UpdateSalaryRate('<%=(String)vRetResult.elementAt(i)%>')"><%=(String)vRetResult.elementAt(i)%></a><br>
  	  <%=WI.formatName((String)vRetResult.elementAt(i+1),
	  					(String)vRetResult.elementAt(i+2),
					    (String)vRetResult.elementAt(i+3),4)%></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+5);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+5)," :: ","","");
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <%if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){
				strTemp = "";
				if(vAllowances != null && vAllowances.size() > 0){
					iIndexOf = vAllowances.indexOf(lIndex);
					while(iIndexOf != -1){
						vAllowances.remove(iIndexOf); // user_index, , , , " +
						if(strTemp.length() > 0)
							strTemp += "<br>-"+(String)vAllowances.remove(iIndexOf); // allowance_name
						else
							strTemp = "-" +(String)vAllowances.remove(iIndexOf); // allowance_name
						
						vAllowances.remove(iIndexOf); // sub_type
						vAllowances.remove(iIndexOf); // cola_month
						vAllowances.remove(iIndexOf); // cola_daily
						vAllowances.remove(iIndexOf); // cola_hourly
						vAllowances.remove(iIndexOf); // release_sched
						vAllowances.remove(iIndexOf); // deduct_absent
						iIndexOf = vAllowances.indexOf(lIndex);
					}
				}
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+10),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
			  <%
				strStatus = WI.getStrValue((String)vRetResult.elementAt(i+12),"-1");
				strDependent = null;
 					if(strStatus.length() == 2){
						strDependent = strStatus.substring(1,2);
						strStatus = strStatus.substring(0,1);						
					}
				 
				%>
      <td class="thinborder"> <%=astrTaxStatus[Integer.parseInt(strStatus)  + 1]%><%=WI.getStrValue(strDependent)%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder">
	  		<%=astrSalaryPeriod[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+13),"-1")) + 1]%>	  </td>
      <%}if (abolShowList[iIndex++]){
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14));
		
		if (strTemp.length() == 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15));
		else
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+15),"::","","");
	  
	  	if (strTemp.length() ==0 || strTemp.equals("::0") || strTemp.equals("0")){
			strTemp = "No Record";
		}
		
		
	  
	  %>
      <td class="thinborder"><%=strTemp%></td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <%}%>
    </tr>
    <%}// end for loop%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <% if (vRetResult!= null) {%>
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1">
	  Number of Employees Per Page 
	  <select name="max_lines">
	  <% 
	  	for (int i =20; i <= 30; ++i){ 
		 if (WI.fillTextValue("max_lines").equals(Integer.toString(i))){
	  %>
	   <option selected><%=i%></option>	
	   <%}else{%>
	   <option><%=i%></option>		   
	  <%}
	  } // end for loop%>
	  </select>	  
	  <a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a>click 
          to print List</font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="from_pr" value="<%=WI.fillTextValue("from_pr")%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>