<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
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
<title>Employee Benefits</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle_small.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
TD{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript"> 
function ReloadPage(){
	document.form_.reload_page.value = "1";
	document.form_.submit();
}

function SearchEmployee(){	
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value="1";
	this.SubmitOnce("form_");
}

function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
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
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
///ajax here to load major..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iCtr = 0;
	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./emp_benefits_print.jsp" />
	<% 
return;}	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Personnel","emp_benefits.jsp.jsp");
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
														
if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"emp_benefits.jsp.jsp");
}else{
  iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
	 											(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"hr_personnel_service_rec_benefit.jsp");
}														
														
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
int iIndexOf = 0;
int i = 0 ;
int iSearchResult = 0;
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";	
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};

hr.hrAutoInsertBenefits hrAuto = new hr.hrAutoInsertBenefits();

if(WI.fillTextValue("searchEmployee").length() > 0){
	vRetResult = hrAuto.getEmployeeBenefitIncentive(dbOP,request);
 	if (vRetResult == null) 
		strErrMsg = hrAuto.getErrMsg();
	else
		iSearchResult = hrAuto.getSearchCount();
}

Vector vEmpBenefits = null;

String[] astrTemp = null;
Vector vSelected = new Vector();
%>

<body bgcolor="#663300" class="bgDynamic">
<form action="./emp_benefits.jsp" method="post" name="form_">
  <table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="6" align="center"><font color="#FFFFFF" ><strong>:::: 
      INCENTIVE MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" align="right"> </td>
    </tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr> 
				<td height="23" colspan="3"><font size="2" color="#FF0000"><strong><font size="1"><a href="./sal_ben_incent_mgmt_main.jsp"><img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></font><%=WI.getStrValue(strErrMsg)%></strong></font></td>
			</tr>
			
			<tr>
				<td width="3%" height="24">&nbsp;</td>
				<td width="20%">Status</td>
				<td width="77%"><select name="pt_ft">
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
			 <select name="employee_category">          
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
				<td> <select name="c_index" onChange="ReloadPage();">
						<option value="">N/A</option>
						<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
			</tr>
			<tr> 
				<td height="25">&nbsp;</td>
				<td>Department/Office</td>
				<td>
				<select name="d_index">
						<option value="">ALL</option>
						<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
						<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
						<%}%>
					</select>	  </td>
			</tr>
			<tr>
			  <td height="10">&nbsp;</td>
			  <td height="10">Benefit</td>
				<%
					astrTemp = request.getParameterValues("multiple_benefits");
					if(astrTemp != null && astrTemp.length > 0){
						for(i = 0; i < astrTemp.length; i++)
							vSelected.addElement(astrTemp[i]);						
					}
 				%>
			  <td height="10">
				<select name="multiple_benefits" size="5" multiple>
					<%if(vSelected == null || vSelected.size() == 0){
							strTemp2 = "selected";
						}else{
							strTemp2 = "";
							iIndexOf = vSelected.indexOf("0");
							if(iIndexOf != -1)
								strTemp2 = "selected";
						}
					%>
					<option value="0" <%=strTemp2%>>ALL</option>					
          <%
					String strSQLQuery = "select BENEFIT_INDEX, BENEFIT_NAME, sub_type  from hr_benefit_incentive " +
					" join hr_preload_benefit_type on (hr_benefit_incentive.benefit_type_index = hr_preload_benefit_type.benefit_type_index) " +
					" where is_del = 0 order by BENEFIT_NAME, sub_type";
					java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
					StringBuffer strBuf = new StringBuffer();
					while(rs.next()) {
						strTemp = rs.getString(1);
						strTemp2 = "";
						iIndexOf = vSelected.indexOf(strTemp);
						if(iIndexOf != -1)
							strTemp2 = "selected";
						strBuf.append("<option value='"+rs.getString(1)+"' " + strTemp2 + ">("+ rs.getString(2)+ ") - "+rs.getString(3)+"</option>");
					}
					rs.close();			
					%>
              <%=strBuf.toString()%>
          </select>
				<br>
				To select multiple benefits. Press and hold <strong>Ctrl key </strong>then select the benefits. </td>
	  </tr>
			<tr> 
				<td height="10">&nbsp;</td>
				<td height="10">Employee ID </td>
				<td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"   onKeyUp="AjaxMapName(1);">
				<strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
				<a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   			<label id="coa_info"></label>
				</strong></td>
			</tr>
			<tr> 
				<td height="18" colspan="3"><hr size="1" color="#000000"></td>
			</tr>
	</table>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=hrAuto.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=hrAuto.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=hrAuto.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
      <td height="10" colspan="3"><input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
      <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>		
<%if (vRetResult != null && vRetResult.size() > 3) {  %>
		<table width="100%" border="0"cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td align="right"><font><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></font></td>
        </tr>
    <%if(WI.fillTextValue("view_all").length() == 0){
			int iPageCount = iSearchResult/hrAuto.defSearchSize;		
			if(iSearchResult % hrAuto.defSearchSize > 0) ++iPageCount;
			if(iPageCount > 1){%>				
        <tr>
          <td width="32%" align="right"><font size="2">Jump To page:
              <select name="jump_to" onChange="SearchEmployee();">
                <%
			strTemp = request.getParameter("jump_to");
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
      </table></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
	<%	
		int j = 0;
	 for (i = 0; i < vRetResult.size(); i+= 20, ++iCtr) {
	 	vEmpBenefits = (Vector)vRetResult.elementAt(i+12);
	 %>
    <tr>
      <td height="22" colspan="4">
	  <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0"> 
	  	<tr> 
		  	<td width="50%" height="25"> Name :<font color="#FF0000"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 
																																						(String)vRetResult.elementAt(i+4), 4)%> (<%=(String)vRetResult.elementAt(i+1)%>)</strong></font></td>	  
		  	<td width="50%">Date of Employment :<strong><font color="#0000FF"><%=(String)vRetResult.elementAt(i+5)%> </font></strong></td>
	    </tr>
	  </table></td>
    </tr>
		<%if(vEmpBenefits != null && vEmpBenefits.size() > 0){%>
    <tr>
      <td width="6%" height="18">&nbsp;</td>
      <td width="94%" height="18" colspan="3"><table width="100%" border="0" cellspacing="0" cellpadding="0">
				<%for(j = 0; j < vEmpBenefits.size(); j+=10){%>
        <tr>					
          <td width="25%" height="21"><%=(String)vEmpBenefits.elementAt(j+2)%> </td>
					<% 
						strTemp =(String)vEmpBenefits.elementAt(j+4); 
					%>
          <td width="25%"><%=strTemp%></td>
					
          <td width="25%">&nbsp;</td>
          <td width="25%">&nbsp;</td>
        </tr>
				<%}%>
      </table></td>
      </tr>
		<%}
		}%>
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
<input type="hidden" name="print_page">
<input type="hidden" name="reload_page">
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
