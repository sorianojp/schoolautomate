<%@ page language="java" import="utility.*,enrollment.EnrollmentStatusUC,java.util.Vector" %>
<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
	if(strSchCode.startsWith("NEU")){
		response.sendRedirect("./other/neu/master_list_neu.jsp");
		return;
	}
%>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("print_page").length() > 0){
		if(strSchCode.startsWith("SPC")){%>
			<jsp:forward page="./master_list_print_spc.jsp" />
		<%}else{%>
			<jsp:forward page="./master_list_print_uc.jsp" />
		<%}
		
		return;
	}


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Master List</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>



<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<script language="JavaScript">


function PrintPg()
{	
	document.form_.print_page.value = '1';	
	document.form_.submit();
}

function Search(){
	document.form_.search_.value = '1';
	document.form_.print_page.value = '';
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ENROLLMENT"),"0"));
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
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of security



	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-UC Master List","master_list_uc.jsp");
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
	
	
String[] astrSortByName = {"ID Number","Name","Year Level","College","Course"};
String[] astrSortByVal = {"id_number","lname","stud_curriculum_hist.year_level", "course_offered.c_index", "stud_curriculum_hist.course_index"};
String[] astrConvertSem = {"SUMMER", "FIRST TRIMESTER", "SECOND TRIMESTER", "THIRD TRIMESTER", "FOURTH TRIMESTER"};

int iSearchResult = 0;

Vector vRetResult = new Vector();


EnrollmentStatusUC enrlStatus = new EnrollmentStatusUC();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlStatus.viewMasterList(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlStatus.getErrMsg();
	else
		iSearchResult = enrlStatus.getSearchCount();
}



%>
<form action="./master_list_uc.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          MASTER LIST ::::</strong></font></div></td>
    </tr>
	<tr bgcolor="#FFFFFF">
		<td height="25" width="3%">&nbsp;</td>
		<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	</tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
  	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">SY/Term:</td>
		<td width="80%" colspan="3">
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
				-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>

			<select name="offering_sem">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>
				
				
				</td>
	</tr>
	
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<td colspan="3"> 
		<select name="college_index" onChange="document.form_.submit();">
		<option value="">All</option>
		<%=dbOP.loadCombo("c_index","c_name, c_code", " from college where is_del = 0 order by c_name ", WI.fillTextValue("college_index"), false)%> 
		</select>
		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<%
		strTemp = WI.fillTextValue("college_index");
		
		if(strTemp.length() > 0)
			strTemp = " where is_valid = 1 and is_offered = 1 and c_index = "+strTemp+" order by course_name ";
		else
			strTemp = " where is_valid = 1 and is_offered = 1 order by course_name ";
		
		%>
		<td colspan="3"> 
		<select name="course_index">
		<option value="">All</option>
		<%=dbOP.loadCombo("course_index","course_name, course_code", " from course_offered "+strTemp , WI.fillTextValue("course_index"), false)%> 
		</select>
		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<%%>
		<td>Year</td>
		<td colspan="3">
		<select name="year_level">
		<option value="">All</option>
<%
strTemp = WI.fillTextValue("year_level");
if(strTemp.equals("1"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
		<option value="1" <%=strErrMsg%>>1</option>
<%if(strTemp.equals("2")){%>
		<option value="2" selected>2</option>
<%}else{%>
		<option value="2">2</option>
<%}if(strTemp.equals("3")){%>
		<option value="3" selected>3</option>
<%}else{%>
		<option value="3">3</option>
<%}if(strTemp.equals("4")){%>
		<option value="4" selected>4</option>
<%}else{%>
		<option value="4">4</option>
<%}if(strTemp.equals("5")){%>
		<option value="5" selected>5</option>
<%}else{%>
		<option value="5">5</option>
<%}if(strTemp.equals("6")){%>
		<option value="6" selected>6</option>
<%}else{%>
		<option value="6">6</option>
<%}%>
		</select>
		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Gender</td>
		<td colspan="3">
			<select name="gender">
			<option value="">All</option>
<%
strTemp = WI.fillTextValue("gender");
if(strTemp.equals("M"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
			<option value="M" <%=strErrMsg%>>Male</option>
<%
if(strTemp.equals("F"))
	strErrMsg = "selected";
else	
	strErrMsg = "";
%>
			<option value="F" <%=strErrMsg%>>Female</option>
			</select>
		</td>
	</tr>
	
	
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
          	<td height="25" width="">&nbsp;</td>
		  	<td width="">Sort by: </td>
		  	<td width="">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=enrlStatus.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=enrlStatus.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=enrlStatus.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
	
	<tr><td colspan="6">&nbsp;</td></tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>&nbsp;</td>
		<td colspan="3">
		<a href="javascript:Search();">
		<img src="../../../images/form_proceed.gif" border="0">
		</a>
		</td>
	</tr>
  </table>
  
  
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0){
	
%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
	<tr><td colspan="3" align="right" valign="middle">
	Number of lines per page:
	<input type="text" name="line_per_page" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','line_per_page');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','line_per_page');" size="3" maxlength="5" value="<%=WI.fillTextValue("line_per_page")%>"/>
	&nbsp; &nbsp; 
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	</td></tr>
	<tr><td colspan="3">&nbsp;</td></tr>
	<%if(strSchCode.startsWith("UC")){%>
		<tr><td colspan="3" align="center"><font size="+3" color="#00CC33"><strong>University of the Cordilleras</strong></font></td></tr>
	<%}%>
	<tr>
		<td width="30%">&nbsp;</td>
		<td align="center"><font size="1"><strong>
			<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem")))]%> 
			<%=WI.getStrValue(WI.fillTextValue("sy_from"))%>-<%=WI.getStrValue(WI.fillTextValue("sy_to"))%></strong></font></td>
		<td width="30%" align="right"><font size="1">Date and Time Printed: <%=WI.getTodaysDateTime()%></font></td>
	</tr>
</table>
 
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">	
	<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(enrlStatus.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="5"> &nbsp;
			<%
				int iPageCount = 1;
				if(!WI.fillTextValue("view_all").equals("1")){
					iPageCount = iSearchResult/enrlStatus.defSearchSize;		
					if(iSearchResult % enrlStatus.defSearchSize > 0)
						++iPageCount;
				}
				strTemp = " - Showing("+enrlStatus.getDisplayRange()+")";
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="Search();">
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
<!--
		<td height="25" align="center" width="5%" class="thinborder"><strong>Count</strong></td>
-->
		<td width="15%" align="center" class="thinborder" height="25"><strong>Student ID</strong></td>
		<td width="25%" align="center" class="thinborder"><strong>Student Name</strong></td>
		<td width="15%" align="center" class="thinborder"><strong>Gender</strong></td>
		<td width="20%" align="" class="thinborder"><strong>Course</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Year</strong></td>
		<td width="10%" align="center" class="thinborder"><strong> Units Enrolled </strong></td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+= 9, iCount++){
	%>
	<tr>
<!--
		<td height="25" align="center" class="thinborder"><%=iCount%></td>
-->		
		<td height="25" align="" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
		<td height="25" align="left" class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4)%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+8);
		if(strTemp.equals("M"))
			strTemp = "Male";
		else
			strTemp = "Female";
		%>		
		<td height="25" align="center" class="thinborder"><%//=(String)vRetResult.elementAt(i+8)%><%=strTemp%></td>
		<td height="25" align="left" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"- ","","")%></td>
		<td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%></td>
		<td height="25" align="center" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 7))%></td>
	</tr>
	<%}%>
	
</table>



<%}%>

  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable4">
  <tr>
    <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
  </tr>
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="page_action" />
<input type="hidden" name="print_page" />
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>