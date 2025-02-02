<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,enrollment.ParentRegistration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>

<script language="JavaScript">

function Search(){
	document.form_.search_.value = "1";
	document.form_.submit();
}

function loadClassification() {	
		var objCOA=document.getElementById("load_classification");
		var header = "All";
		var selName = "classification";
		var onChange = "";
		var tableName = "bed_level_info";
		var fields = "g_level,level_name";
		var headerValue = "";
		
		var vCondition = '';
		var vClassValue = document.form_.book_catg.value;
		if(vClassValue.length == 0)
			vCondition = ' where edu_level@0';
		else{
			if(vClassValue == '1')
				vCondition = '';
			else//if college
				vCondition = ' where edu_level@0';
		}
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header+"&header_value="+headerValue;
	
		this.processRequest(strURL);
	}

</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PARENT REGISTRATION"),"0"));		
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID Number","Lastname","Firstname"};
String[] astrSortByVal     = {"id_number","lname","fname"};


int iSearchResult = 0;

Vector vRetResult = new Vector();
Vector vParentDetail = new Vector();

ParentRegistration prSMS = new ParentRegistration();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = prSMS.getStudentDetailParentNotRegistered(dbOP, request);
	if(vRetResult == null)
		strErrMsg = prSMS.getErrMsg();
	else	
		iSearchResult = prSMS.getSearchCount();
}


%>
<form action="./view_student_parent_not_reg.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT LIST WITH PARENT  NOT REGISTERED ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF">
		<td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
		<td align="right"><a href="main.jsp"><img src="../../images/go_back.gif" border="0"></a></td>
	</tr>
  </table>

  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
  <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="11%">ID Number</td>
      <td colspan="5"><select name="stud_id_con">
          <%=prSMS.constructGenericDropList(WI.fillTextValue("stud_id_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		  <input type="text" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td width="30%"><select name="lname_con">
          <%=prSMS.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>
		  <input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Firstname</td>
      <td><select name="fname_con">
        <%=prSMS.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
      <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td>Category:</td>
		<%
			String strCatg = WI.getStrValue(WI.fillTextValue("stud_catg"));
		%>
	  	<td colspan="3">
			<select name="stud_catg" onChange="document.form_.submit();">				
				<option value="">All</option>
				<%=dbOP.loadCombo("catg_index","catg_name", " from bs_book_catg where is_valid = 1 order by catg_name ", strCatg, false)%> 
			</select>
		</td>
	</tr>
	
	
	
	
	<tr>
			<td height="25">&nbsp;</td>
			<%
			if(strCatg.equals("1"))
				strTemp = "Grade";
			else
				strTemp = "Year";
			%>
			<td><%=strTemp%> Level:</td>			
			<td colspan="3">
				
				<select name="classification">
					<option value="">All</option>					
					<%
					if(strCatg.equals("1")){
					%>
					<%=dbOP.loadCombo("g_level","level_name", " from bed_level_info order by g_level", WI.fillTextValue("classification"), false)%> 
					<%
					}else{
						strTemp = WI.fillTextValue("classification");
						if(strTemp.equals("1"))
							strErrMsg = "selected";
						else
							strErrMsg = "";
						%><option value="1" <%=strErrMsg%>>1</option>					
						<%
						if(strTemp.equals("2"))
							strErrMsg = "selected";
						else
							strErrMsg = "";
						%><option value="2" <%=strErrMsg%>>2</option>
						<%
						if(strTemp.equals("3"))
							strErrMsg = "selected";
						else
							strErrMsg = "";
						%><option value="3" <%=strErrMsg%>>3</option>
						<%
						if(strTemp.equals("4"))
							strErrMsg = "selected";
						else
							strErrMsg = "";
						%><option value="4" <%=strErrMsg%>>4</option>
						<%
						if(strTemp.equals("5"))
							strErrMsg = "selected";
						else
							strErrMsg = "";
						%><option value="5" <%=strErrMsg%>>5</option>					
						
					<%}%>
				</select>
				</td>
		</tr>
	
	<%if(!strCatg.equals("1")){%>
	
		<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<%
		String strCollegeIndex = WI.fillTextValue("c_index");		
		%>
		<td colspan="3">
			<select name="c_index" onChange="document.form_.submit();">
				<option value=""></option>
				<%=dbOP.loadCombo("c_index", "c_name", " from college where is_del = 0 order by c_name", strCollegeIndex,false)%>
			</select>
		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<%		
		if(strCollegeIndex.length() > 0)
			strTemp = " from course_offered where c_index = "+strCollegeIndex+" and is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";
		else
			strTemp = " from course_offered where is_valid = 1 and is_del = 0 and is_offered = 1 order by course_code";		
		
		strErrMsg = WI.fillTextValue("course_index");
		
		%>
		<td colspan="3">
			<select name="course_index">
				<option value=""></option>
				<%=dbOP.loadCombo("course_index", "course_code, course_name ", strTemp, strErrMsg,false)%>
			</select>
		</td>
	</tr>
	
	<%}%>
	
	<tr><td colspan="5" height="10"></td></tr>
</table>	
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
	
</table>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"> 
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">Sort by: </td>
		<td width="20%">
			<select name="sort_by1">
				<option value="">N/A</option>
				<%=prSMS.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
			</select></td>
		<td width="20%">
			<select name="sort_by2">
				<option value="">N/A</option>
				<%=prSMS.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
			</select></td>
		<td width="40%">
			<select name="sort_by3">
				<option value="">N/A</option>
				<%=prSMS.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
			</select></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td>
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
		<td>
			<select name="sort_by2_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
		<td>
			<select name="sort_by3_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
				<option value="desc" selected="selected">Descending</option>
			<%}else{%>
				<option value="desc">Descending</option>
			<%}%>
			</select></td>
	</tr>
	
	<tr>
		<td height="15" colspan="5"></td>
	</tr>
	<tr>
		<td height="25" colspan="2">&nbsp;</td>
		<td colspan="4">
			<a href="javascript:Search();"><img src="../../images/form_proceed.gif" border="0" /></a>
		</td>
	</tr>
	<tr>
		<td height="15" colspan="5">&nbsp;</td>
	</tr>
</table>
  
  
  
  
<%
if(vRetResult != null && vRetResult.size() > 0){%>

 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	
	<tr><td align="center" height="25" colspan="6"  class="thinborder"><strong>SEARCH RESULT</strong></td></tr>
	
	<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="2">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(prSMS.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="7"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/prSMS.defSearchSize;		
				if(iSearchResult % prSMS.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+prSMS.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="document.form_.search_.value='1';document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i = 1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%> </td>
		</tr>
	
	<tr>		
		<td width="15%" height="20" class="thinborder"><strong>Student ID</strong></td>
		<td class="thinborder"><strong>Student Name</strong></td>
		<%
		if(strCatg.equals("1"))
			strTemp = "Year Level";
		else
			strTemp = "Course & Year";
		%>
		<td width="25%" class="thinborder"><strong><%=strTemp%></strong></td>
		<!--<td class="thinborder"><strong>Option</strong></td>-->
	</tr>
	
	<%	
	
	for(int i = 0; i < vRetResult.size() ; i+=8){
	%>
	<tr>		
		<td height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
		<td class="thinborder">
			<%=WebInterface.formatName(WI.getStrValue((String)vRetResult.elementAt(i+2)),WI.getStrValue((String)vRetResult.elementAt(i+3)), WI.getStrValue((String)vRetResult.elementAt(i+4)), 4)%>
			
		
		<%
		strTemp = "-"+(String)vRetResult.elementAt(i+7);
		
		if(((String)vRetResult.elementAt(i+5)).equals("0"))
			strTemp = "";
		
		strTemp = (String)vRetResult.elementAt(i+6) + strTemp;
		%>
		
		<td  class="thinborder"><%=WI.getStrValue(strTemp)%></td>		
	</tr>
	
	<%}%>
	
</table>
  
  
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>