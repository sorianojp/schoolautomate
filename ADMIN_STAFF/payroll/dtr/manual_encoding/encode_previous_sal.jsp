<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PREVIOUS SALARY ENCODING</title>
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

TD.thinborderBOTTOMLEFT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFTRIGHT {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_pg.value = "1";
	this.SubmitOnce('form_');
}

function PrevSal(strEmpID,strUserIndex){
	var pgLoc = "./salary_before_system.jsp?emp_id="+strEmpID+
							"&year_of="+document.form_.taxable_year.value+"&user_index="+strUserIndex+
							"&encoding_type=0";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=465,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
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
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasConfidential = false;	
	boolean bolHasTeam = false;	
	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Previous Salary Encoding","encode_previous_sal.jsp");
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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","DTR",request.getRemoteAddr(),
														"encode_previous_sal.jsp");
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

	Vector vRetResult = null;
	ReportPayrollExtn ReportExtn = new ReportPayrollExtn(request);

	String[] astrPtFt = {"PART-TIME","FULL-TIME"};
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName  = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal   = {"id_number","user_table.fname","lname","c_name","d_name"};

	int i = 0;
	
	if(WI.fillTextValue("searchEmployee").equals("1")){
		vRetResult = ReportExtn.getEmpWithUnloggedSalary(dbOP);
		if(vRetResult == null){
			strErrMsg = ReportExtn.getErrMsg();
		}else{	
			iSearchResult = ReportExtn.getSearchCount();
		}
	}
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="./encode_previous_sal.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr  bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL : PREVIOUS SALARY ENCODING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="23" colspan="5"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Taxable Year </td>
      <td colspan="3"><select name="taxable_year">
          <%=dbOP.loadComboYear(WI.fillTextValue("taxable_year"),2,1)%> 
      </select></td>
    </tr>
    
    	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
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
      <td colspan="3"><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
    </tr>
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>          
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
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
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label>			</td>
    </tr>
<%if(bolHasConfidential){%>
    <tr>
      <td height="25">&nbsp;</td>
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
      <td height="18">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    <tr> 
      <td width="2%" height="18">&nbsp;</td>
      <td width="20%">Employee ID </td>
      <td width="78%" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <strong><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></strong>
			<label id="coa_info"></label></td>
    </tr>
		
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
      <td height="10" colspan="3">OPTION:</td>
    </tr>
    <tr> 
      <td width="3%" height="10">&nbsp;</td>
      <td width="97%" height="10" colspan="2"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with encoded previous Salary
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View without encoded previous salary </td>
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
        <%=ReportExtn.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=ReportExtn.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=ReportExtn.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
        click to display employee list</font></td>
    </tr>
  </table>	
  <%if (vRetResult != null && vRetResult.size() > 0){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18">&nbsp;</td>
    </tr>
    <%		
	int iPageCount = iSearchResult/ReportExtn.defSearchSize;		
	if(iSearchResult % ReportExtn.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td align="right"><font size="2">Jump To page: 
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
	<%}%>
  </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="28" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><strong> PREVIOUS SALARY ENCODING OF SALARY BEFORE SYSTEM IMPLEMENTATION </strong></td>
    </tr>
    <tr bgcolor="#ffff99">
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="13%" height="24" align="center" class="thinborder">&nbsp;&nbsp;<strong>TIN</strong></td>
      <td width="37%" align="center" class="thinborder" >&nbsp;&nbsp;<strong>Employee Name</strong></td>
      <td width="37%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td width="9%" class="thinborder">&nbsp;</td>
    </tr>
    <%int iCount = 1;			
	for(i = 0; i < vRetResult.size(); i +=8,iCount++){
	%>
    <tr>
      <td class="thinborder">&nbsp;<%=iCount%></td>
      <td height="20" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+2)).toUpperCase(), (String)vRetResult.elementAt(i+3),
							(WI.getStrValue((String)vRetResult.elementAt(i+4))).toUpperCase(), 4)%></td>
      <%
				if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  		strTemp = " ";			
				}else{
					strTemp = " - ";
				}
			%>							
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%> </td>
      <td align="center" class="thinborder">
			<%if(iAccessLevel > 1){%>
			<a href='javascript:PrevSal("<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"0")%>","<%=WI.getStrValue((String)vRetResult.elementAt(i),"0")%>")'>
				<img src="../../../../images/update.gif" width="60" height="26" border="0"></a>
			<%}else{%>
				N/a
			<%}%>
			</td>
    </tr>
    <%}%>
  </table>
  <%} // if (vRetResult != null && vRetResult.size() > 0 )%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
	<input type="hidden" name="encoding_type" value="0"> 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>