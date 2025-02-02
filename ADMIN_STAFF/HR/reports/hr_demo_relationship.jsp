<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRStatsReports" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
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

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AjaxMapName(strKeyCode) {
 
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
</script>

<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./hr_demo_relationship_print.jsp" />
<% return;	}
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-REPORTS AND STATISTICS-Dependents","hr_demo_relationship.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_demo_relationship.jsp");
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


HRStatsReports hrStat = new HRStatsReports(request);
String strSchCode = dbOP.getSchoolIndex();
if(bolIsSchool)
   strTemp = "College";
else
   strTemp = "Division";
String[] astrSortByName    = {strTemp,"Department","Emp. Status"};
String[] astrSortByVal     = {"c_code","d_code","user_status.status",};

boolean[] abolShowList={false,false,false,false};							
boolean bolShowOneDetail = false;
int iIndex =1;
String[] astrRelation = {"Spouse","Child","Brother", "Sister", "Parent/Guardian"};

for(; iIndex <= 2; iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
		abolShowList[iIndex] = true;
		bolShowOneDetail = true;
	}	
}

Vector vRetResult = null;

if (WI.fillTextValue("show_list").equals("1")){

	vRetResult = hrStat.hrDemoRelationships(dbOP);
	
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount(); 		
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
}
%>
<form action="./hr_demo_relationship.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
      DEMOGRAPHIC REPORTS (RELATIONSHIP) ::::</strong></font></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
    <tr> 
      <td width="3%" height="25"><strong><font color="#0000FF">&nbsp;Check Columns 
        To Show in the Report : </font> </strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#E4EFFA">
    <tr> 
      <td width="34%" height="18">&nbsp;</td>
      <td width="33%">&nbsp;</td>
    </tr>
    <tr> 
      <td width="34%" height="18"> <% iIndex = 1;
			if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%> 
			<input type="checkbox" name="checkbox1" value="1" <%=strTemp%> id="check1">
			<label for="check1">Birth Date</label>
			</td>
      <td width="33%"> <% if (abolShowList[iIndex++])  strTemp = "checked";
	  	else strTemp = "";%> 
			
			<input type="checkbox" name="checkbox2" value="1" <%=strTemp%> id="check2">
        <label for="check2">Age</label>
				</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%">&nbsp;</td> 
      <td width="17%" height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td> 
      <td height="25" class="fontsize10">&nbsp;Emp. ID </td>
      <td width="22%"><input name="emp_id"  type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16" maxlength="32" onKeyUp="AjaxMapName();"></td>
      <td width="59%"><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td>
      <td height="25" class="fontsize10">Relationship</td>
<%				
				Vector vSelected = null;
				String strSelected = null;
			  String[] astrSelected = request.getParameterValues("relationship");
				 if (astrSelected != null && astrSelected.length > 0) {
					 vSelected = new Vector();
					 for (int i = 0; i < astrSelected.length; i++)
						 vSelected.addElement(astrSelected[i]);
				 } 
				if(request.getParameterValues("relationship") == null || astrSelected[0].length() == 0)
					strTemp = "selected";
				else
					strTemp = "";
			%>
      <td colspan="2">
			<select name="relationship" multiple size="3">
        <option value="" <%=strTemp%>>ALL</option>
				<%for(int i = 0 ; i < astrRelation.length;i++){	
					if(strSchCode.startsWith("AUF") && i >= 2)
						continue;
					 strSelected = "";
				 if (vSelected != null && vSelected.size() > 0) {
					 if (vSelected.indexOf(Integer.toString(i)) != -1)
						 strSelected = "selected";
				 }
				%>
				  <option value="<%=i%>" <%=strSelected%>><%=astrRelation[i]%></option>				
				<%}%>
      </select></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td> 
      <td height="25" class="fontsize10"> &nbsp;Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("emp_type_index", "emp_type_name"," from hr_employment_type where is_del =0 order by emp_type_name",WI.fillTextValue("emp_type_index"), false)%> </select></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td> 
      <td height="25" class="fontsize10">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage()">
          <option value=""> &nbsp;</option>
          <%=dbOP.loadCombo("c_index", "c_name"," from college where is_del =0 order by c_name",WI.fillTextValue("c_index"), false)%> </select></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td> 
      <td height="25" class="fontsize10">&nbsp;Dept / Office </td>
      <td colspan="2"><select name="d_index">
          <option value=""> &nbsp;</option>
          <%
			if (WI.fillTextValue("c_index").length() > 0) 
				strTemp = "  c_index = " + WI.fillTextValue("c_index");
			else 
				strTemp = "  (c_index is null or c_index  = 0)";

		%>
          <%=dbOP.loadCombo("d_index", "d_name"," from department where "+ strTemp  +" and is_del = 0 order by d_name",WI.fillTextValue("d_index"), false)%> </select></td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td>
      <td class="fontsize10">&nbsp;Office/Dept filter </td>
      <td colspan="2"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"> 
        (enter office/dept's first few characters) </td>
    </tr>
    <tr>
      <td class="fontsize10">&nbsp;</td> 
      <td height="25" class="fontsize10">&nbsp;Emp. Status</td>
      <td colspan="2"><select name="status_index">
          <option value=""> ALL</option>
          <%=dbOP.loadCombo("status_index", "status"," from user_status where IS_FOR_STUDENT = 0 order by status",
								WI.fillTextValue("status_index"), false)%> </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td> 
      <td height="10">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
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
      <td width="47%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=hrStat.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> </td>
      <td width="0%">&nbsp;</td>
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
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="18" colspan="5">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td><a href="javascript:showList()"%><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
      <td>&nbsp;</td>
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
      <td height="25" align="right">&nbsp;
 
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">SEARCH 
      RESULT</font></strong></td>
    </tr>
    <tr> 
      <td width="49%" height="25"><b>&nbsp;TOTAL RESULT : <%=iSearchResult%> 
	  	<% if (WI.fillTextValue("show_all").length() ==0 ) {%>
			 - Showing(<%=hrStat.getDisplayRange()%>)
		<%}%>
			 </b></td>
      <td width="51%">&nbsp;
        <%
		if (WI.fillTextValue("show_all").length() == 0){
		
			int iPageCount = iSearchResult/hrStat.defSearchSize;
			if(iSearchResult % hrStat.defSearchSize > 0) ++iPageCount;

			if(iPageCount > 1)
			{%>
    	    <div align="right">Jump To page: 
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
          </select></div>
          <%}
		  }// end if (WI.fillTextValue("show_all")%>
		  
		  
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="23%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE 
            NAME</strong></font></td>
      <td width="13%" align="center"  class="thinborder"><font size="1"><strong>OFFICE</strong></font></td>

      <td width="10%" align="center" class="thinborder"><strong><font size="1">EMP. 
          STATUS</font></strong></td>
      <td width="27%" align="center" class="thinborder"><font size="1"><strong>NAME</strong></font></td>
			<td width="10%" align="center" class="thinborder"><strong><font size="1">RELATION</font></strong> </td>
			<%iIndex = 1;if (abolShowList[iIndex++]){%>	  
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>BIRTHDATE</strong></font></td>
      <%}if (abolShowList[iIndex]){%>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">AGE</font></strong></td>
      <%}%>
    </tr>
<% 	String strCurrentUserIndex = "";
	boolean bolSameUser = false;
		for (int i = 0; i < vRetResult.size(); i+=20){
		 bolSameUser = false;
		if (i == 1) 
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
		
		if (i != 1 && strCurrentUserIndex.equals((String)vRetResult.elementAt(i)))
			bolSameUser = true;
		else
			strCurrentUserIndex = (String)vRetResult.elementAt(i);
			
		iIndex = 1;
		
		if (bolSameUser) 
			strTemp = "&nbsp;";
		else
			strTemp = WI.formatName((String)vRetResult.elementAt(i+2),
									(String)vRetResult.elementAt(i+3),
									(String)vRetResult.elementAt(i+4),4);
	%>
    <tr> 
      <td height="23" class="thinborder">&nbsp;<%=strTemp%></td>
   <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else{
			strTemp = (String)vRetResult.elementAt(i+5);
			if (strTemp == null) strTemp = (String)vRetResult.elementAt(i+6);
			else strTemp += WI.getStrValue((String)vRetResult.elementAt(i+6)," :: ","","");
		}
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
   <% 
	   if (bolSameUser) 
	   		strTemp = "&nbsp;";
		else
			strTemp = (String)vRetResult.elementAt(i+7);
	%>
	  
      <td class="thinborder"><%=strTemp%></td>
 			<%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+8),
	  										  (String)vRetResult.elementAt(i+9),
											  (String)vRetResult.elementAt(i+10),4);
 				if(strTemp == null || strTemp.length() == 0)
					strTemp = WI.formatName((String)vRetResult.elementAt(i+12),
	  										  (String)vRetResult.elementAt(i+13),
											  (String)vRetResult.elementAt(i+14),4);
			%>
      <td class="thinborder"><%=strTemp%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15), "0");
				strTemp = astrRelation[Integer.parseInt(strTemp)];
			%>
      <td class="thinborder"><%=strTemp%></td> 
      <%if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
      <%}if (abolShowList[iIndex]){
	  		if ((String)vRetResult.elementAt(i+11) != null) {
				strTemp = "&nbsp;" + 
						 ConversionTable.differenceInYearMonthDaysNow((String)vRetResult.elementAt(i+11));
				if (strTemp.indexOf("Y") != -1) 
					strTemp = strTemp.substring(0,strTemp.indexOf("Y"));
			}else
				strTemp = "&nbsp;";	  
	  %>
      <td class="thinborder"><%=strTemp%></td>
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
      <td>&nbsp;&nbsp;Report Title for Printing: 
        <input name="title_report" type="text" value="<%=WI.fillTextValue("title_report")%>" size="64"></td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"> Number of Lines Per 
          Page 
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
          to print List</font></div>
	  </td>
    </tr>
    <%}%>
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="show_list" value="0">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>