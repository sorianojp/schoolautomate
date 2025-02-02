<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoJobDescription" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Job Description Search</title>
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
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	//all about ajax - to display student list with same name.
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <= 2) {
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
	}
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	function UpdateNameFormat(strName) {
		//do nothing.
	}

	function loadSearchDept() {
		var objCOA=document.getElementById("load_search_dept");
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=search_dept&all=1";
		this.processRequest(strURL);
	}
	
	function SearchJobDesc(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPage(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./hr_personnel_job_desc_search_print.jsp" />
	<% 
		return;}
	
	//add security here
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Personal Data","hr_personnel_job_desc_search.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection </font></p>
	<%
		return;
	}
	
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_personnel_job_desc_search.jsp");
															
	if(bolMyHome)
		iAccessLevel = 1;
		
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
	
	int iSearchResult = 0;
	HRInfoJobDescription jobDesc = new HRInfoJobDescription();
	Vector vRetResult = jobDesc.searchJobDescription(dbOP, request);
	if(vRetResult == null)
		strErrMsg = jobDesc.getErrMsg();
	else
		iSearchResult = jobDesc.getSearchCount();
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="hr_personnel_job_desc_search.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: SEARCH EMPLOYEE JOB DESCRIPTION ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	<%if(!bolMyHome){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3">
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("search_encoded"), "1");
				if(strTemp.equals("1")){
					strTemp = "checked";
					strErrMsg = "";
				}
				else{
					strTemp = "";
					strErrMsg = "checked";
				}
			%>
				<input type="radio" name="search_encoded" value="1" onChange="SearchJobDesc();" <%=strTemp%>>Show Employees w/ Job Descriptions
				<input type="radio" name="search_encoded" value="0" onChange="SearchJobDesc();" <%=strErrMsg%>>Show Employees w/o Job Descriptions</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>:</td>
			<td colspan="2">
				<%
					String strCollegeCon = WI.fillTextValue("search_college");
				%>
				<select name="search_college" onChange="loadSearchDept();">
          			<option value="0">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeCon, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department/Office:</td>
			<td colspan="2">
				<label id="load_search_dept">
				<select name="search_dept">
         			<option value="">ALL</option>
          		<%if ((strCollegeCon.length() == 0) || strCollegeCon.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("search_dept"), false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon,  WI.fillTextValue("search_dept"), false)%> 
         		 <%}%>
  	   			</select></label></td>
		</tr>
	<%}else{
		strTemp = "checked";
	%>
		<input type="hidden" name="search_encoded" value="1">
	<%}
	
	if(strTemp.length() > 0){
		if(!bolMyHome){%>
			<tr>
				<td height="25" width="3%">&nbsp;</td>
				<td width="17%">ID Number: </td>
				<td width="20%">
					<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
						onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();"></td>
				<td width="60%" valign="top"><label id="coa_info" style="position:absolute; width:300px"></label></td>
			</tr>
		<%}else{
			strTemp = (String)request.getSession(false).getAttribute("userId");
		%>
			 <tr>
      			<td colspan="4" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
					<input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
			</tr>
		<%}
	}%>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="20%">&nbsp;</td>
		    <td width="60%">&nbsp;</td>
		</tr>
	<%if(!bolMyHome){%>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:SearchJobDesc();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search employee job descriptions.</font></td>
		</tr>
	<%}%>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to print search results.</font>
		</tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="2" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SEARCH RESULTS :::</strong></div></td>
		</tr>
		<tr> 
			<td height="25" class="thinborderBOTTOMLEFT" width="50%">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(jobDesc.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" width="50%"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/jobDesc.defSearchSize;		
				if(iSearchResult % jobDesc.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+jobDesc.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchJobDesc();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Employee Name</strong></td>
		<%if(WI.getStrValue(WI.fillTextValue("search_encoded"), "1").equals("1")){%>
			<td width="26%" align="center" class="thinborder"><strong>Job Description</strong></td>
		<%}%>
			<td width="12%" align="center" class="thinborder"><strong><%if(bolIsSchool){%>College<%}else{%>Division<%}%></strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Department/Office</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4)%></td>
		<%if(WI.getStrValue(WI.fillTextValue("search_encoded"), "1").equals("1")){%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
		<%}%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>