<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee Without Finger Data</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
</style>
</head>
<script language="JavaScript" src="../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../jscript/td.js"></script>
<script language="JavaScript">
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.search_util.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.search_util.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		eval('document.search_util.'+strOthFieldName+'.value=\'\'');
		hideLayer(strTextBoxID);
		eval('document.search_util.'+strOthFieldName+'.disabled=true');
	}
	//if dob to is disabled, i am sure, it is hidden. 
	if(document.search_util.dob_to.disabled)
		hideLayer("dob_to_cal_");
	else	
		showLayer("dob_to_cal_");
}
function ReloadPage()
{
	document.search_util.searchEmployee.value = "";
	document.search_util.print_page.value = "";
	document.search_util.submit();
}
function SearchEmployee()
{
	document.search_util.searchEmployee.value = "1";
	document.search_util.print_page.value = "";
	document.search_util.submit();	
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SetIDToCopy(strStudID) {
	document.search_util.id_to_copy.value = strStudID;
}
function CopyIDNumber() {
	if(document.search_util.opner_info.value.length ==0) {
		alert("Proceed copies ID to the caller page. Click Proceed only if search page is called clicking Search ICON.");
		return;
	}
	eval('window.opener.document.'+document.search_util.opner_info.value+'.value=\''+document.search_util.id_to_copy.value+'\'');
	window.opener.focus();
	self.close();
}
function PrintPg() {
	document.search_util.print_page.value = 1;
	document.search_util.submit();
}
function focusID() {
	document.search_util.id_number.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%@ page language="java" import="utility.*,java.util.Vector, search.EmpFingerInfo" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_emp_finger_data_print.jsp" />
		return;
	<%}
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Employees","srch_emp_finger_data.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	// allow search employee only if the user is not a student / parent. 
	strTemp = (String)request.getSession(false).getAttribute("userId");
	if(strTemp == null)
		strErrMsg = "You are already logged out. Please login again.";
	else {
		strTemp = dbOP.mapOneToOther("user_table","id_number","'"+strTemp+"'","AUTH_TYPE_INDEX"," and is_valid = 1 and is_del = 0");
		if(strTemp == null || strTemp.compareTo("4") ==0 || strTemp.compareTo("6") ==0)//student or parent or not having any access
			strErrMsg = "You are not authorized to view Employee Finger Data search page.";		
	}
	if(strErrMsg != null) {
		dbOP.cleanUP();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
			

//end of authenticaion code.
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=","greater","less"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","user_status.status","HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME"};
String[] astrDropListBetween = {"Between","Equal to","Less than","More than"};
String[] astrDropListValBetween = {"BETWEEN","=","greater","less"};//check for between
String[] astrDropListValBetweenAGE = {"BETWEEN","=","less","greater"};//for age, less than and greater than is swapped.

int iSearchResult = 0;

EmpFingerInfo empFinger = new EmpFingerInfo(request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = empFinger.operateOnViewEmpFingerInfo (dbOP);
	if(vRetResult == null)
		strErrMsg = empFinger.getErrMsg();
	else	
		iSearchResult = empFinger.getSearchCount();
}

%>
<form action="./srch_emp_finger_data.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH EMPLOYEE W/O FINGER DATA PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Employee ID </td>
      <td width="9%"><select name="id_number_con">
          <%=empFinger.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> </select> </td>
      <td width="19%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
      <td width="47%"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=empFinger.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
      <td></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=empFinger.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" size="16"></td>
      <td></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employment Status</td>
      <td colspan="2"> <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Employment Type</td>
      <td colspan="2"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>College</td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");

if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Office/Dept</td>
      <td colspan="2"><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4"><input type="checkbox" name="checkbox" value="checkbox">
        view employees without finger data record</td>
    </tr>
    <tr> 
      <td height="25" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%">Sort by</td>
      <td width="25%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=empFinger.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="24%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=empFinger.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="40%"><select name="sort_by3">
          <option value="">N/A</option>
          <%=empFinger.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by3_con">
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
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"> <input type="image" src="../images/refresh.gif" onClick="SearchEmployee();">
        <font size="1">Click to search Employee</font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right">Number of Employess per Print 
          Page: 
          <select name="num_emp_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_emp_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select><a href="javascript:PrintPg();">
          <img src="../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">LIST 
          OF EMPLOYEES WITHOUT FINGER DATA</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%> - Showing(<%=empFinger.getDisplayRange()%>)</b></td>
      <td width="34%">
        <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/empFinger.defSearchSize;
		if(iSearchResult % empFinger.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%>
        <div align="right">Jump To page:
          <select name="jumpto" onChange="SearchEmployee();">
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
          <%}%>
        </div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="14%" height="25" ><div align="center"><strong><font size="1">EMPLOYEE 
          ID</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">NAME (LNAME,FNAME 
          MI) </font></strong></div></td>
      <td width="14%"><div align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></div></td>
      <td width="14%"><div align="center"><strong><font size="1">EMPLOYMENT TYPE</font></strong></div></td>
      <td width="26%"><div align="center"><strong><font size="1">COLLEGE/ OFFICE</font></strong></div></td>
    </tr>
    <%
for(int i = 0 ; i < vRetResult.size(); i +=17){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25"><%=WI.formatName((String)vRetResult.elementAt(i + 2) ,(String)vRetResult.elementAt(i + 3) , (String)vRetResult.elementAt(i + 4),4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 16)%></td>
      <td><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td>
	  <% if(vRetResult.elementAt(i + 9) != null) {
	  		//outer loop.
		  if(vRetResult.elementAt(i + 10) != null) {//inner loop.%>
		     <%=(String)vRetResult.elementAt(i + 9)%>/<%=(String)vRetResult.elementAt(i + 10)%> 
     		<%}else{%> 
	    	<%=(String)vRetResult.elementAt(i + 9)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 10) != null){//outer loop else%> 
	  <%=(String)vRetResult.elementAt(i + 10)%>  
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </td>
	  </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right">
	  <a href="javascript:CopyIDNumber();"><img src="../images/form_proceed.gif" border="0"></a>
	  <font color="#0000FF" size="1">Click to copy Employee ID </font></div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"><a href="javascript:PrintPg();">
	  	<img src="../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print result</font></div></td>
    </tr>
  </table>
<%}//only if vRetResult not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="selectValue">
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="id_to_copy">
<!--`opner info is formname.fieldname of the opener -->
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<input type="hidden" name="print_page">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>